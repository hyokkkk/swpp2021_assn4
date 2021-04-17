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
static Value* loser;                    // a syntax which will be replaced by "winner".
static Value* winner;                   // a syntax which will replace "loser".
static vector<BasicBlock*> BFS;     // queue for BasicBlock BFS
static vector<StringRef> visitedV;

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
void sortBBbyBFSorder(Function& F){
    // BFSqueue는 control flow에 위배되지 않는 순서대로 BB를 정렬함.
    // 탐색 순서만 나타내는 용도.
    Function* fp = &F;
    // 일단 방문한 애를 vector에 넣는 게 낫지. vector에 넣기 전에 visited 살펴서
    // 이미 존재하면 안 넣고 다음으로 넘어가면 되니까. 
    BasicBlock& entryBB = F.getEntryBlock();
    BasicBlock* entryBBp = &entryBB;
    visitedV.push_back(entryBB.getName());
    BFS.push_back(entryBBp);

    // BFS의 사이즈와 basicblocklist의 사이즈가 같아질 때까지 loop돈다.
    outs() << "[debug] basic block list size : " << fp->getBasicBlockList().size() << "\n";

    int BFSitr= 0;        // BFS iter
    int BBLsize = fp->getBasicBlockList().size();
    // 종료시키는 BB의 이름이어야 함. instruction name 이 ret인 경우. 
    while (BFSitr != BBLsize-1){
        // BB를 종료시키는 instruction : BR inst인지 확인. 
        // successor을 받아야 하기 때문. 

        Instruction* isRet = (*BFS[BFSitr]).getTerminator();
        outs() << "[debug] <<<이건 그냥 inst만 받은거>>>: " << *isRet << "\n\n";
        outs() << "이게 ret이 나와야 하는데"<< isRet->getOpcodeName() << "\n";
        // 마지막 BB라는 의미. 
        if ((StringRef)(isRet->getOpcodeName())==(StringRef)("ret")) {
            outs() << "오잉 여기 안 들어와??" << "\n";
            BFSitr++;
            continue;
        }
        outs() << "이게 마지막 BB의 이름이라는 것: " << isRet->getParent()->getName() << "\n";

        BranchInst* terminator = dyn_cast<BranchInst>((*BFS[BFSitr++]).getTerminator());
        outs() << "[debug] === 이게 branch instruction terminator: " << *terminator << "\n\n";
        // successor 받아서 앞에꺼부터 넣는다.
        // 이렇게 하면 Label의 내용이 나옴. 
        outs() << "[debug] === successor 갯수: " << (*terminator).getNumSuccessors() << "\n";
        outs() << "이거 타입이 뭐임 " << (*terminator->getSuccessor(0)).getName() << "\n";
        
        // 아.. label... 이면... 또 name으로 BB를 찾아가야하는 것인가. 
        BasicBlock* BBp;
        for (int i = 0; i < (*terminator).getNumSuccessors(); i++){
            // 이름으로 찾아야 함. 
            StringRef succName = (*terminator->getSuccessor(i)).getName();
            BBp = findBasicBlockPointer(F, succName);
            outs() << "[debug] ** BBlist에서 이름 같은 BB 찾음: " << BBp->getName() << "\n";
            // 이미 방문된 적 있으면 다시 방문할 필요 없음.
            if (!visited(succName)){
                BFS.push_back(BBp);
                visitedV.push_back(succName);
            }
        }

        outs() << "[debug] ++++++ BFS elements ++++++ \n";
        for (auto &B : BFS){
            outs() << "[debug] +++++++ " << (*B).getName() << "\n";
        }
        outs() << "\n[debug] ++++++ visited elements ++++++ \n";
        for (auto &B : visitedV){
            outs() << "[debug] +++++++ " << B<< "\n";
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
    for (StringRef& n : visitedV){
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
