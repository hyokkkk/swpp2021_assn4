#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include <vector>
#include <queue>
#include <string>

using namespace llvm;
using namespace std;
using namespace llvm::PatternMatch;

// < Algorithms >
// --- 아래의 숫자와 코드 설명에 쓰여진 숫자는 같은 내용을 설명한다.
// 0. 기존의 접근은 llvm ir code에 작성된 순서대로 instruction을 살핀다.
//      하지만 이는 실제 function의 control flow가 아니라 단순히 ir code 작성순서에
//      의존하여 replace하는 순서를 판단 하기 때문에 오류가 생길 수 있다.
//      ex) kia -> samsung -> zonber 로 바뀌어야 하는데 samsung->zonber inst가
//          kia->samsung 수행 inst보다 먼저 수행되면 오류가 난다.
//      => 따라서, getSuccessor()를 이용, BFS를 돌아 하위level node가
//         상위 level node보다 먼저 수행되는 것을 방지한다.
// 1. <push args into vector, BB into vector by BFS order>
//    - function arguments를 vector "argV"에 담아놓는다.
//    - 모든 ir code는 entryBB부터 시작하므로 getSuccessor()를 이용해 BB 방문 순서를
//    BFS 순서로 저장해 놓는다. BFS 돌면서 만나게 되는 instruction들을 vector "instV"에
//    push. 3번에서 dominance relationship between two instruction을 판단할 때 필요함.
// 2. <find icmp instruction>
//    BB내의 inst 하나씩 돌면서 matcher를 통해 `%cond = icmp i32 %a, %b`를 찾는다.
//    icmp inst가 아니라면 바로 return해서 다음 inst를 살핀다.
// 3. <decide Winner and loser>
//    icmp의 operand("Op0", "Op1") 각각이 arg인지 inst인지 판단.
//    ** how? -> arg: argV에 있는지 확인.
//            -> inst: argV에 없으면 inst.
//    ** 그 후에 replace 당할 register name("loser")과 replace를 하게 될 "winner"를 찾는다.
//            -> 1) inst vs. inst / 2) arg vs. arg / 3) arg vs. inst 인 경우가 있다.
//            -> BFS 순으로 inst가 "instV"에 저장되기 때문에 index로 dominance 판단 가능.
// 4. <find condUser>
//    condUser가 br instruction인 경우, 현재 BB를 BBEdge의 startBB로 만들어야 하므로
//    `br i1 %cond, label %true, label %false`, 즉, %cond를 사용하는 "condUser" 찾음.
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
static vector<BasicBlock*> BFS;         // queue for BasicBlock BFS
static Value* winner;                   // a syntax which will replace "loser".
static Value* loser;                    // a syntax which will be replaced by "winner".

namespace {
class PropagateIntegerEquality : public PassInfoMixin<PropagateIntegerEquality> {
// =========================== entry point ===================================
public:
PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {

    // 1. <push args into vector>
    for (Argument &Arg : F.args()){
        Value* arg = &Arg;
        argV.push_back(arg);
    }
    // 1. <BB into BFS vector by BFS order>
    sortBBbyBFSorder(F);
    for (auto BBp : BFS){
        for (auto &I : *BBp){
            replaceEquality(F, FAM, &I);
        }
    }
    return PreservedAnalyses::all();
}
//============================================================================

// 1. <BB into BFS vector by BFS order>
void sortBBbyBFSorder(Function& F){
    // BFS는 control flow에 위배되지 않는 순서대로 BB를 정렬함. 이 순서대로 instruction을 탐색함.
    Function* fp = &F;
    BasicBlock& entryBB = F.getEntryBlock();
    BasicBlock* entryBBp = &entryBB;
    BFS.push_back(entryBBp);

    // BFS의 사이즈와 basicblocklist의 사이즈가 같아질 때까지 loop돈다.
    int BFSitr= 0;
    int BBLsize = fp->getBasicBlockList().size();
    while (BFSitr != BBLsize-1){
        Instruction* isRet = (*BFS[BFSitr]).getTerminator();

        // terminator inst가 `ret`이라면 successor를 받을 수 없기 때문에
        // 오류가 생기지 않도록 미리 cut해야 함.
        if ((StringRef)(isRet->getOpcodeName())==(StringRef)("ret")) {
            BFSitr++;
            continue;
        }
        BranchInst* terminator = dyn_cast<BranchInst>((*BFS[BFSitr++]).getTerminator());

        // successor(0), (1) 순서로 방문할 예정. BFS에 넣는다.
        // successor name은 BB name형태이므로 BBlist에서 해당 BB 주소를 찾는다.
        BasicBlock* BBp;
        StringRef succName;
        for (int i = 0; i < (*terminator).getNumSuccessors(); i++){
            succName = (*terminator->getSuccessor(i)).getName();
            BBp = findBasicBlockPointer(F, succName);

            // 이미 방문된 적 있으면 다시 방문할 필요 없음.
            if (!visited(succName)){
                BFS.push_back(BBp);
            }
        }
    }
}
//============================================================================

BasicBlock* findBasicBlockPointer(Function& F, StringRef BBname){
    Function* fp = &F;
    for (auto iter = fp->getBasicBlockList().begin();
        iter != fp->getBasicBlockList().end(); iter++){
        if ((*iter).getName() == BBname){
            return &(*iter);
        }
    }
    return NULL;
}
//============================================================================

bool visited(StringRef succName){
    bool v = false;
    for (BasicBlock* bp : BFS){
        StringRef n = (*bp).getName();
        if (n == succName){
            v = true;
        }
    }
    return v;
}
//============================================================================
// The reason why "F" and "FAM" are in param is to use 'checkDominance()' function.
void replaceEquality(Function &F, FunctionAnalysisManager &FAM, Value *V ) {

    // 2. check the instruction is `%cond = icmp i32 %a, %b` or not.
    Instruction* inst = dyn_cast<Instruction>(V);
    assert(inst);
    instV.push_back(inst);
    Instruction &I = *inst;
    Value* Op0, *Op1;                   // Op0 : %a, Op1 : %b
    ICmpInst::Predicate Pred;

    // if not matched with '%cond = icmp eq (v1, v2)', return.
    if (!(match(&I, m_ICmp(Pred, m_Value(Op0), m_Value(Op1))) && Pred == ICmpInst::ICMP_EQ)) {
         return ;
    }
    /****** codes below are only executed when matched with `%cond = icmp eq (v1, v2)` ********/

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

        // 5. find "loserUsers"
        for (auto loserItr = loser->use_begin(), loserEnd = loser->use_end();
                                                        loserItr != loserEnd;){
            Use& loserUse = *loserItr++;
            User* loserUser = loserUse.getUser();
            Instruction* targetInst = dyn_cast<Instruction>(loserUser);
            assert(targetInst);

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
        // (1) inst vs. inst : first executed, become winner.
        //     - compare instV index. (first come, first executed.)
        if (op0argV == -1 && op1argV == -1){
            Instruction *instOp0, *instOp1;
            BasicBlock *op0BB, *op1BB;
            int op0instV = -1, op1instV = -1;

            // find BBs where each instruction is.
            for (int i = 0; i < instV.size(); i++){
                if ((*instV[i]).getName().equals((*Op0).getName())){
                    op0instV= i;
                }else if((*instV[i]).getName().equals((*Op1).getName())){
                    op1instV= i;
                }
            }
                loser = op0instV > op1instV ? Op0 : Op1;
                winner = op0instV > op1instV ? Op1 : Op0;

        // (2) arg vs. arg : first defined, become winner. @f(i32 %y, i32 %x) -> %y wins.
        }else if (op0argV != -1 && op1argV != -1){
            loser = op0argV > op1argV ? Op0 : Op1;
            winner = op0argV > op1argV ? Op1 : Op0;
        // (3) arg vs. inst : arg always wins.
        }else {
            loser = op0argV == -1 ? Op0 : Op1;
            winner = op0argV == -1 ? Op1 : Op0;
        }
}

//============================================================================
bool checkBBEDominance(BasicBlock& startBB, BasicBlock& targetBB,
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
//============================================================================
int checkInstDominance(BasicBlock& B0, BasicBlock& B1, Function& F, FunctionAnalysisManager& FAM){
    DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
    if (DT.dominates(&B0, &B1)){
        // [param index] BB dominates the other BB.
        return 0;
    }else if (DT.dominates(&B1, &B0)){
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
