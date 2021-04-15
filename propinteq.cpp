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

// 0. 기본적으로, function의 모든 instruction을 돌면서 icmp eq (%a, %b)를 찾을 때마다 
//    replace를 수행한다. 
// 1. func arguments, instruction은 각각 vector를 만들어 담아놓는다.
//    무엇으로 replace할 지 결정할 때 defined order가 중요하기 때문.
// 2. 들어온 value가 `%cond = icmp i32 %a, %b`인 것을 찾는다 by matcher.
//    icmp inst가 아니라면 바로 return해서 다음 inst를 살핀다.
// 3. icmp의 operand("Op0", "Op1") 각각이 arg인지 inst인지 판단. 
//    ** how? -> arg: argV에 있는지 확인.
//            -> inst: argV에 없으면 inst. instV search해서 execute order 알아내야.
//    그 후에 replace 당할 register name("loser")과 replace를 하게 될
//    "winner"를 찾는다. 
// 4. `br i1 %cond, label %true, label %false`, 즉, %cond를 사용하는 "condUser" 찾아야 함.
//    condUser가 br instruction인 경우, 해당 BB를 BBEdge의 startBB로 만들어야 하므로.
// 5. 3에서 구한 loser를 instruction에 사용하고 있는 user("loserUser")를 찾는다.
// 6. "loserUser" 중에서 4에서 구한 startBB와 true BB 사이의 edge에게 dominate 당하는 
//    "loserUser"의 operand만 "winner"로 바꾼다. 
//        -> optimize 하려면 dummy block을 넣어야 함. printdom.cpp의 
//          'edge dominates block'이 dummy block 삽입과 동일한 기능을 한다. 
//        -> "condUser"이 위치하는 BB(startBB)와, true BB 사이의 edge가
//           "loserUserBB"를 dominate 하면 "winner"로 replace 가능.

static vector<Value*> argV; 
static vector<Value*> instV;
static Value* loser;                
static Value* winner;                

namespace {
class PropagateIntegerEquality : public PassInfoMixin<PropagateIntegerEquality> {
 
// =========================== entry point ===================================
public:
PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    for (Argument &Arg : F.args()){
        outs() << "\n\n[debug]=======<argument run 시작>: " <<Arg<< "\n";
        replaceEquality(F, FAM, &Arg, true);
    }
    for (auto &BB : F){
    outs() << "[debug]================ <BB label>: " << BB.getName() << "\n";
        for (auto &I : BB){
            outs() << "[debug]=====<Instruction run 시작>: " << I << "\n";
            replaceEquality(F, FAM, &I, false);
        }
    }
    return PreservedAnalyses::all();
}

//==============================================================================
void replaceEquality(Function &F, FunctionAnalysisManager &FAM, Value *V, bool isArg) {

// 1. push arguments into a vector
    if (isArg){ 
        argV.push_back(V);
        //--------------- delete
        for (int i = 0; i < argV.size(); i++){
            outs() << "[debug] args in vec["<<i<<"]: " << *argV[i] << "\n";
        }
        return ;
    }

// 2. check the instruction is `%cond = icmp i32 %a, %b`
    Instruction* inst = dyn_cast<Instruction>(V);
    Instruction &I = *inst;
    instV.push_back(V);

    outs() <<"[debug]        this is value(inst): "<< *V << "\n";
    outs() << "[debug]              inst name:"<< (*inst).getName() << "\n";
    Value* Op0, *Op1;                   // Op0 : %a, Op1 : %b 
    ICmpInst::Predicate Pred;

    // if not matched with '%cond = icmp eq (v1, v2)', return.
    if (!(match(&I, m_ICmp(Pred, m_Value(Op0), m_Value(Op1)))
                        && Pred == ICmpInst::ICMP_EQ)) { return ; }

            
    /* codes below are only executed when matched with `%cond = icmp eq (v1, v2)` */
        
    outs() << "\n[debug] ****** I found compare inst!: " << I << "\n";

// 3. check Op0, Op1 are 'arg' or 'inst'. Assign value to var 'winner' and var 'loser'.
    decideWinnerLoser(I.getOperand(0), I.getOperand(1));

// 4. %cond를 사용하는 "condUser" 찾는다. ex) `br i1 %cond, label %true, label %false`
//    - loop to find users since cannot assure that just one condUser exists.
    for (auto itr = V->use_begin(), end = V->use_end(); itr != end;) {
        Use &U = *itr++;
        User *condUser = U.getUser();        

        Instruction *brInst = dyn_cast<Instruction>(condUser);
        assert(brInst); // The user (e.g. op2) is an instruction

        // condUser shoud be "br instruction".
        Value* C;
        BasicBlock* TrueBB;
        BasicBlock* FalseBB;
        if (!(match(brInst, m_Br(m_Value(C), m_BasicBlock(TrueBB), m_BasicBlock(FalseBB))))){
            return ;
        }


        // br i1 %cond, label %true, label %false
        //   operand(0), operand(2), operand(1)
        outs() << "[debug] ** this is br user: "<< *brInst<< "\n";
        outs() << "[debug] num of operands: "<< brInst -> getNumOperands()<< "\n";
        outs() << "[debug] ---operand0: "<< brInst -> getOperand(0)->getName() << "\n";
        outs() << "[debug] ---operand1: "<< brInst -> getOperand(1)->getName() << "\n";
        outs() << "[debug] ---operand2: "<< brInst -> getOperand(2)->getName() << "\n";
        outs() << "[debug] >>> 여기로 뛸거야 >>> " << brInst->getOperand(2)->getName()<< "\n";

// 5. find "loserUsers"
        for (auto loserItr = loser->use_begin(), loserEnd = loser->use_end(); loserItr != loserEnd;){
            Use& loserUse = *loserItr++;
            User* loserUser = loserUse.getUser();      
            Instruction* targetInst = dyn_cast<Instruction>(loserUser);
            assert(targetInst);

            outs() << "[debug] 바뀌어야 하는 instruction: "<<*targetInst<<"\n";
            for (int i = 0; i < targetInst->getNumOperands(); i++){
                outs() << "[debug] ---target operand" << i <<": "<<
                targetInst-> getOperand(i)->getName() << "\n";
            }

// 6. only replace "loser" which is in targetBB with "winner"
//    when targetBB is dominated by BBEdge(entryBB, trueBB). 
// it works as "dummy block"
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
        outs() << "[debug] Op0: " << *Op0 << "\n";
        outs() << "[debug] Op0.getname(): " << (*Op0).getName() << "\n";
        outs() << "[debug] Op1: " << *Op1 << "\n";
        outs() << "[debug] Op1.getname(): " << (*Op1).getName() << "\n";

        // -1 : instruction (not in the argV)
        // 0, 1, 2... : index in argV
        int op0argV = -1;
        int op1argV = -1;
        for (int i = 0; i < argV.size(); i++){
            // compare with names.
            if ((*argV[i]).getName().equals((*Op0).getName())){
                op0argV = i;
            }else if((*argV[i]).getName().equals((*Op1).getName())){
                op1argV = i;
            }
        }

        outs() << "[debug]--" << *Op0 << " is argv[" << op0argV << "]\n";
        outs() << "[debug]--" << *Op1 << " is argv[" << op1argV << "]\n\n";

        // (1) inst vs. inst : first come, wins.
        if (op0argV == -1 && op1argV == -1){
            int op0instV = -1;
            int op1instV = -1;
            for (int i = 0; i < instV.size(); i++){
                if ((*instV[i]).getName().equals((*Op0).getName())){
                    op0instV= i;
                }else if((*instV[i]).getName().equals((*Op1).getName())){
                    op1instV= i;
                }
            }
            outs() << "[debug]--" << *Op0 << " is inst[" << op0instV<< "]\n";
            outs() << "[debug]--" << *Op1 << " is inst[" << op1instV<< "]\n\n";

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
        outs() << "[debug]  ** \'"<< *loser << 
        "\' should be replaced by \'"<<*winner<< "\'\n\n";
}

//=================================================================================
bool checkDominance(BasicBlock& startBB, BasicBlock& targetBB, 
                    Function& F, FunctionAnalysisManager& FAM) {
    DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
    BranchInst *TI = dyn_cast<BranchInst>(startBB.getTerminator());
    // br i1 %cond, label %successor(0), label %successor(1)
    BasicBlock* destBB = TI->getSuccessor(0);   

    outs() << "\n[debug] 일단 실험해보자 : successor 갯수: " <<  TI->getNumSuccessors() << "\n";
    outs() << "[debug] successor[0]: " <<  TI->getSuccessor(0)->getName() << "\n";
    outs() << "[debug] successor[1]: " <<  TI->getSuccessor(1)->getName() << "\n";

    BasicBlockEdge BBE(&startBB, destBB);
    if (DT.dominates(BBE, &targetBB)){
        outs() << "***** Edge (entry" << startBB.getName() <<","<< destBB->getName()
        << ") dominates " << targetBB.getName() << "!!!!!!!\n\n";
        return true;
    }
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
