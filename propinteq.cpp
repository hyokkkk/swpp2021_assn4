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
// --- 아래의 숫자와 코드 설명에 쓰여진 숫자는 같은 내용을 설명한다.
// 1. function을 한 번 돌면서 모든 arg, instruction을 각각 vector에 넣어놓는다
//    3.번 단계를 할 때 필요함. 
// 2. instruction을 하나씩 돌면서 `%cond = icmp i32 %a, %b`인 것을 찾는다 by matcher.
//    icmp inst가 아니라면 바로 return해서 다음 inst를 살핀다.
// 3. <decide Winner and loser>
//    icmp의 operand("Op0", "Op1") 각각이 arg인지 inst인지 판단.
//    ** how? -> arg: argV에 있는지 확인.
//            -> inst: argV에 없으면 inst. 
//    ** 그 후에 replace 당할 register name("loser")과 replace를 하게 될 "winner"를 찾는다.
//            -> 1) inst vs. inst / 2) arg vs. arg / 3) arg vs. inst 인 경우가 있다.
//            -> 1)가 좀 까다로운데 `decideWinnerLoser()`에 기술해놓음.
// 4. <find condUser>
//    `br i1 %cond, label %true, label %false`, 즉, %cond를 사용하는 "condUser" 찾아야 함.
//    condUser가 br instruction인 경우, 해당 BB를 BBEdge의 startBB로 만들어야 하므로.
// 5. <find loserUser>
//    3에서 구한 "loser"를 instruction에 사용하고 있는 user("loserUser")를 찾는다.
// 6. <replace>
//    "loserUser" 중에서 4에서 구한 startBB와 true BB 사이의 edge에게 dominate 당하는
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

    // 1. push arguments, instructions into vectors
    for (Argument &Arg : F.args()){ 
        completeVector(&Arg, true);
    }
    for (auto &BB : F){
        for (auto &I : BB){
            completeVector(&I, false);
        }
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
void completeVector(Value* V, bool isArg){
    if (isArg){
        argV.push_back(V);
        return ;
    }
    instV.push_back(V);
}

//============================================================================
// The reason why "F" and "FAM" are in param is to use 'checkDominance()' function.
void replaceEquality(Function &F, FunctionAnalysisManager &FAM, Value *V, bool isArg) {

    // 2. check the instruction is `%cond = icmp i32 %a, %b` or not.
    Instruction* inst = dyn_cast<Instruction>(V);
    assert(inst);
    Instruction &I = *inst;
    Value* Op0, *Op1;                   // Op0 : %a, Op1 : %b
    ICmpInst::Predicate Pred;
    outs() <<"[debug]        this is value(inst): "<< *V << "\n";
    outs() << "[debug]              inst name:"<< (*inst).getName() << "\n";
    // if not matched with '%cond = icmp eq (v1, v2)', return.
    if (!(match(&I, m_ICmp(Pred, m_Value(Op0), m_Value(Op1))) && Pred == ICmpInst::ICMP_EQ)) {
         return ;
    }
    /****** codes below are only executed when matched with `%cond = icmp eq (v1, v2)` ********/
 outs() << "\n[debug] ****** I found compare inst!: " << I << "\n";
 outs() << "\n[debug] ****** icmp일 때에만 이 문장 나와야 함" << "\n";
    // 3. check Op0, Op1 are whether 'arg' or 'inst', and decide who's the "winner" and "loser"
    decideWinnerLoser(I.getOperand(0), I.getOperand(1), F, FAM);

    // 4. find "condUser" which uses %cond in its insturction.
    //     ex) `br i1 %cond, label %true, label %false`
    //     Use a loop to find "condUser" for preventing erorrs, 
    //     althoguh it is guaranteed that there exists only one "condUser" in our assn.
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
        outs() << "\n[debug] ** 4. find condUser: "<< *brInst<< "\n";
        outs() << "[debug] num of operands: "<< brInst -> getNumOperands()<< "\n";
        outs() << "[debug] ---operand0: "<< brInst -> getOperand(0)->getName() << "\n";
        outs() << "[debug] ---operand1: "<< brInst -> getOperand(1)->getName() << "\n";
        outs() << "[debug] ---operand2: "<< brInst -> getOperand(2)->getName() << "\n";
        outs() << "[debug] >>> 여기로 뛸거야 >>> " << brInst->getOperand(2)->getName()<< "\n";

        // 5. find "loserUsers"
        for (auto loserItr = loser->use_begin(), loserEnd = loser->use_end();
                                                        loserItr != loserEnd;){
            Use& loserUse = *loserItr++;
            User* loserUser = loserUse.getUser();
            Instruction* targetInst = dyn_cast<Instruction>(loserUser);
            assert(targetInst);
            outs() << "[debug] ** 5. loserUsers: "<<*targetInst<<"\n";
            // 6. replace "loser"s which are in "targetBB"s with "winner" only when
            //    "targetBB" is dominated by BBEdge(entryBB, trueBB).
            //    it works same as "dummy block"
            BasicBlock* targetBB = targetInst->getParent();
            if (checkBBEDominance(*(inst->getParent()), *targetBB, F, FAM)){
                // loser가 use되는 곳을 winner로 set
                loserUse.set(winner);
            }
        }
    }
}

//============================================================================
void decideWinnerLoser(Value* Op0, Value* Op1, Function& F, FunctionAnalysisManager& FAM){
    outs() << " [debug]** 3. decideWinnerLoser\n";
        outs() << "[debug] Op0: " << *Op0 << "\n";
        outs() << "[debug] Op0.getname(): " << (*Op0).getName() << "\n";
        outs() << "[debug] Op1: " << *Op1 << "\n";
        outs() << "[debug] Op1.getname(): " << (*Op1).getName() << "\n";
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
        outs() << "[debug]--" << *Op0 << " is argv[" << op0argV << "]\n";
        outs() << "[debug]--" << *Op1 << " is argv[" << op1argV << "]\n\n";
        // (1) inst vs. inst : first executed, become winner.
        //      i) instructions in same BB : compare instV index. (first come, first executed.)
        //      ii) instructions in diff BB : check the dominance of two BBs. Instruction in 
        //                                  dominant BB dominates instruction in non-dominant BB.
        if (op0argV == -1 && op1argV == -1){
            Instruction *instOp0, *instOp1;
            BasicBlock *op0BB, *op1BB;
            int op0instV = -1, op1instV = -1;

            // find BBs which each instruction is in. 
            for (int i = 0; i < instV.size(); i++){
                if ((*instV[i]).getName().equals((*Op0).getName())){
                    op0instV= i;
                    instOp0 = dyn_cast<Instruction>(instV[i]);
                    op0BB = instOp0->getParent();
                }else if((*instV[i]).getName().equals((*Op1).getName())){
                    op1instV= i;
                    instOp1 = dyn_cast<Instruction>(instV[i]);
                    op1BB = instOp1->getParent();
                }
            }
            outs() << "[debug]--" << *Op0 << " is inst[" << op0instV<< "]\n";
            outs() << "[debug]--" << *Op1 << " is inst[" << op1instV<< "]\n\n";

            // i) Op0, Op1 are in the same BB.
            if (op0BB->getName() == op1BB->getName()){
            outs() << "[debug]they are in the same BB \n";
                loser = op0instV > op1instV ? Op0 : Op1;
                winner = op0instV > op1instV ? Op1 : Op0;
            // ii) Op0, Op1 are in different BBs.
            } else {
                // opNdom : [param index]BB dominates the other BB.
            outs() << "[debug] **** checkInstdominance\n";
                int opNdom = checkInstDominance(*op0BB, *op1BB, F, FAM);
                if (!opNdom){
                    // op0 dominates op1
                    winner = Op0;
                    loser = Op1;
                
                }else if (opNdom == 1){
                    // op1 dominates op0
                    winner = Op1;
                    loser = Op0;
                   
                }
            }
outs() << "[debug]  ** \'"<< *loser << "\' should be replaced by \'"<<*winner<< "\'\n\n";;
        // (2) arg vs. arg : first defined, become winner. @f(i32 %y, i32 %x) -> %y wins.
        }else if (op0argV != -1 && op1argV != -1){
            loser = op0argV > op1argV ? Op0 : Op1;
            winner = op0argV > op1argV ? Op1 : Op0;
outs() << "[debug]  ** \'"<< *loser << "\' should be replaced by \'"<<*winner<< "\'\n\n";;
            return;
        // (3) arg vs. inst : arg always wins.
        }else {
            loser = op0argV == -1 ? Op0 : Op1;
            winner = op0argV == -1 ? Op1 : Op0;
outs() << "[debug]  ** \'"<< *loser << "\' should be replaced by \'"<<*winner<< "\'\n\n";;
            return;
        }
}

//============================================================================
bool checkBBEDominance(BasicBlock& startBB, BasicBlock& targetBB,
                    Function& F, FunctionAnalysisManager& FAM)
{
    DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
    BranchInst *TI = dyn_cast<BranchInst>(startBB.getTerminator());
    outs() << "\n[debug] ** 6. checkBBEdominance\n";

    // br i1 %cond, label %successor(0), label %successor(1)
    BasicBlock* destBB = TI->getSuccessor(0);
    outs() << "\n[debug] 일단 실험해보자 : successor 갯수: " <<  TI->getNumSuccessors() << "\n";
    outs() << "[debug] successor[0]: " <<  TI->getSuccessor(0)->getName() << "\n";
    outs() << "[debug] successor[1]: " <<  TI->getSuccessor(1)->getName() << "\n";
    BasicBlockEdge BBE(&startBB, destBB);

    if (DT.dominates(BBE, &targetBB)){ 
        outs() << "[debug] 이 문장 나오면 바뀌는거다.\n";
         outs() << "***** Edge (entry" << startBB.getName() <<","<< destBB->getName()
        << ") dominates " << targetBB.getName() << "!!!!!!!\n\n";
        return true; }
    return false;
}
//============================================================================
int checkInstDominance(BasicBlock& B0, BasicBlock& B1, Function& F, FunctionAnalysisManager& FAM){
    DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
    if (DT.dominates(&B0, &B1)){
        // todo : delete
        outs() << B0.getName() << " dominates " << B1.getName() << "!\n";
        // [param index] BB dominates the other BB.
        return 0;
    }else if (DT.dominates(&B1, &B0)){
        outs() << B1.getName() << " dominates " << B0.getName() << "!\n";
        return 1;
    }
    // no dominant relation
    return -1;
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
