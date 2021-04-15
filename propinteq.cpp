#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include <vector>
#include <string>

using namespace llvm;
using namespace std;
using namespace llvm::PatternMatch;

// < Algorithms >
// --- 이레의 숫자와 코드 설명에 쓰여진 숫자는 같은 내용을 설명한다.
// 0. 기본적으로, function의 모든 instruction을 돌면서 icmp eq (%a, %b)를 찾을 때마다 
//    replace를 수행한다. 
// 1. func arguments, instruction은 각각 vector를 만들어 담아놓는다.
//    무엇으로 replace할 지 결정할 때 defined order가 중요하기 때문.
// 2. 들어온 value가 `%cond = icmp i32 %a, %b`인 것을 찾는다 by matcher.
//    icmp inst가 아니라면 바로 return해서 다음 inst를 살핀다.
// 3. icmp의 operand("Op0", "Op1") 각각이 arg인지 inst인지 판단. 
//    ** how? -> arg: argV에 있는지 확인.
//            -> inst: argV에 없으면 inst. instV search해서 execute order 알아내야.
//    그 후에 replace 당할 register name("loser")과 replace를 하게 될 "winner"를 찾는다. 
// 4. `br i1 %cond, label %true, label %false`, 즉, %cond를 사용하는 "condUser" 찾아야 함.
//    condUser가 br instruction인 경우, 해당 BB를 BBEdge의 startBB로 만들어야 하므로.
// 5. 3에서 구한 "loser"를 instruction에 사용하고 있는 user("loserUser")를 찾는다.
// 6. "loserUser" 중에서 4에서 구한 startBB와 true BB 사이의 edge에게 dominate 당하는 
//    "loserUser"의 operand만 "winner"로 바꾼다. 
//        -> optimize 하려면 dummy block을 넣어야 함. printdom.cpp의 
//          'edge dominates block'이 dummy block 삽입과 동일한 기능을 한다. 
//        -> "condUser"이 위치하는 BB(startBB)와, true BB 사이의 edge가
//           "loserUserBB"를 dominate 하면 "winner"로 replace 가능.

static vector<Value*> argV;             // vectors for function arguments.
static vector<Value*> instV;            // vectors for instructions in function.
static Value* loser;                    // a syntax which will be replaced by "winner". 
static Value* winner;                   // a syntax which will replace "loser".

namespace {
class PropagateIntegerEquality : public PassInfoMixin<PropagateIntegerEquality> {
// =========================== entry point ===================================
public:
PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    for (Argument &Arg : F.args()){
        replaceEquality(F, FAM, &Arg, true);
    }
    for (auto &BB : F){
        for (auto &I : BB){
            replaceEquality(F, FAM, &I, false);
        }
    }
    return PreservedAnalyses::all();
}

//==============================================================================
// The reason why "F" and "FAM" are in param is to use 'checkDominance()' function.
void replaceEquality(Function &F, FunctionAnalysisManager &FAM, Value *V, bool isArg) {

// 1. push arguments into a vector
    if (isArg){ 
        argV.push_back(V);
        return ;
    }

// 2. check the instruction is `%cond = icmp i32 %a, %b` or not.
    instV.push_back(V);
    Instruction* inst = dyn_cast<Instruction>(V);
    Instruction &I = *inst;
    Value* Op0, *Op1;                   // Op0 : %a, Op1 : %b 
    ICmpInst::Predicate Pred;

    // if not matched with '%cond = icmp eq (v1, v2)', return.
    if (!(match(&I, m_ICmp(Pred, m_Value(Op0), m_Value(Op1))) && Pred == ICmpInst::ICMP_EQ)) {
         return ; 
    }
            
/******* codes below are only executed when matched with `%cond = icmp eq (v1, v2)` */

// 3. check Op0, Op1 are whether 'arg' or 'inst', and decide who's the "winner" and "loser"
    decideWinnerLoser(I.getOperand(0), I.getOperand(1));

// 4. find "condUser" which uses %cond in its insturction.
//     ex) `br i1 %cond, label %true, label %false`
//     Use a loop to find "condUser" since there just one "condUser" exists is not guranteed.
    for (auto itr = V->use_begin(), end = V->use_end(); itr != end;) {
        Use &U = *itr++;
        User *condUser = U.getUser();        

        Instruction *brInst = dyn_cast<Instruction>(condUser);
        assert(brInst); 

        // "condUser" shoud be "br instruction".
        Value* C;
        BasicBlock* TrueBB;
        BasicBlock* FalseBB;
        if (!(match(brInst, m_Br(m_Value(C), m_BasicBlock(TrueBB), m_BasicBlock(FalseBB))))){
            return ;
        }

// 5. find "loserUsers"
        for (auto loserItr = loser->use_begin(), loserEnd = loser->use_end(); loserItr != loserEnd;){
            Use& loserUse = *loserItr++;
            User* loserUser = loserUse.getUser();      
            Instruction* targetInst = dyn_cast<Instruction>(loserUser);
            assert(targetInst);


// 6. replace "loser" which is in targetBB with "winner" only when 
//    targetBB is dominated by BBEdge(entryBB, trueBB). 
//    it works same as "dummy block"
            BasicBlock* targetBB = targetInst->getParent();
            if (checkDominance(*(inst->getParent()), *targetBB, F, FAM)){
                // loser가 use되는 곳을 winner로 set
                loserUse.set(winner);       
            }
        }
    }
}

//=================================================================================
void decideWinnerLoser(Value* Op0, Value* Op1){

        // -1 : instruction (not in the argV)
        // 0, 1, 2... : index in argV
        int op0argV = -1;
        int op1argV = -1;
        for (int i = 0; i < argV.size(); i++){
            // compare by using names.
            if ((*argV[i]).getName().equals((*Op0).getName())){
                op0argV = i;
            }else if((*argV[i]).getName().equals((*Op1).getName())){
                op1argV = i;
            }
        }

        // (1) inst vs. inst : first come, wins.
        if (op0argV == -1 && op1argV == -1){
            int op0instV = -1;
            int op1instV = -1;
            // same algorithm as above
            for (int i = 0; i < instV.size(); i++){
                if ((*instV[i]).getName().equals((*Op0).getName())){
                    op0instV= i;
                }else if((*instV[i]).getName().equals((*Op1).getName())){
                    op1instV= i;
                }
            }
            loser = op0instV > op1instV ? Op0 : Op1;
            winner = op0instV > op1instV ? Op1 : Op0;

        // (2) arg vs. arg : first come, wins.
        }else if (op0argV != -1 && op1argV != -1){
            loser = op0argV > op1argV ? Op0 : Op1;
            winner = op0argV > op1argV ? Op1 : Op0;

        // (3) arg vs. inst : arg always wins.
        }else {
            loser = op0argV == -1 ? Op0 : Op1;
            winner = op0argV == -1 ? Op1 : Op0;
        }
}

//=================================================================================
bool checkDominance(BasicBlock& startBB, BasicBlock& targetBB, 
                    Function& F, FunctionAnalysisManager& FAM)
{
    DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
    BranchInst *TI = dyn_cast<BranchInst>(startBB.getTerminator());

    // br i1 %cond, label %successor(0), label %successor(1)
    BasicBlock* destBB = TI->getSuccessor(0);   
    BasicBlockEdge BBE(&startBB, destBB);

    if (DT.dominates(BBE, &targetBB)){ return true; }
    return false;
}
};
}

//============================================================================
extern "C" ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
    return {
        LLVM_PLUGIN_API_VERSION, "PropagateIntegerEquality", "v0.1",
        [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
            [](StringRef Name, FunctionPassManager &FPM,
            ArrayRef<PassBuilder::PipelineElement>) {
                if (Name == "prop-int-eq") {
                    FPM.addPass(PropagateIntegerEquality());
                    return true;
                }
                return false;
            }
            );
        }
    };
}
