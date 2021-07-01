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
// 4. <find loserUser>
//    3에서 구한 "loser"를 instruction에 사용하고 있는 user("loserUser")를 찾는다.
// 5. <replace>
//    "loserUser" 중에서 4에서 구한 startBB와 true BB 사이의 edge에게 dominate 당하는
//    "loserUser"의 operand만 "winner"로 바꾼다.
//        -> optimize 하려면 dummy block을 넣어야 함. printdom.cpp의
//          'edge dominates block'이 dummy block 삽입과 동일한 기능을 한다.
//        -> "condUser"이 위치하는 BB(startBB)와, true BB 사이의 edge가
//           "loserUserBB"를 dominate 하면 "winner"로 replace 가능.

static vector<Value*> instV;            // vectors for instructions in function.
static vector<BasicBlock*> BFS;         // queue for BasicBlock BFS
static Value* winner;                   // a syntax which will replace "loser".
static Value* loser;                    // a syntax which will be replaced by "winner".

namespace {
class PropagateIntegerEquality : public PassInfoMixin<PropagateIntegerEquality> {

public:
PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    // 1. <BB into BFS vector by BFS order>
    BFSorder(F);
    for (auto BBp : BFS){
        for (auto &I : *BBp){ replaceEquality(F, FAM, &I); }
    }
    return PreservedAnalyses::all();
}


bool visited(BasicBlock* BBp){
  for (BasicBlock* bp : BFS){
    if (bp != BBp){ continue; }
    return true;
  }
  return false;
}

void BFSorder(Function& F){
  BasicBlock* entryBBp = &F.getEntryBlock();
  BFS.push_back(entryBBp);

  // BFS의 사이즈와 basicblocklist의 사이즈가 같아질 때까지 loop돈다.
  int BFSitr= 0;
  int BBLsize = (&F)->getBasicBlockList().size();
  while (BFSitr+1 != BBLsize){
    // TI : ret
    Instruction* TI = (*BFS[BFSitr++]).getTerminator();
    if (!dyn_cast<BranchInst>(TI) && !dyn_cast<SwitchInst>(TI)){ continue; }

    // TI : br / switch
    for (int i = 0; i < (*TI).getNumSuccessors(); i++){
      BasicBlock* BBp = TI->getSuccessor(i);
      // never visit again.
      if (visited(BBp)){ continue; }
      BFS.push_back(BBp);
    }
  }
}


void replaceEquality(Function &F, FunctionAnalysisManager &FAM, Value *V ) {
    // 2. check the instruction is `%cond = icmp i32 %a, %b` or not.
    DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
    Instruction* inst = dyn_cast<Instruction>(V);
    assert(inst);

    instV.push_back(inst);
    Value* Op0, *Op1;                   // Op0 : %a, Op1 : %b
    ICmpInst::Predicate Pred;

    // if not matched with '%cond = icmp eq (v1, v2)', return.
    if (!(match(inst, m_ICmp(Pred, m_Value(Op0), m_Value(Op1))) && 
        Pred == ICmpInst::ICMP_EQ)) { return ; }

    // 3. arg? inst?
    decideWinnerLoser((*inst).getOperand(0), (*inst).getOperand(1));

    // 4. find "loserUsers"
    for (auto loserItr = loser->use_begin(), loserEnd = loser->use_end();
                                                    loserItr != loserEnd;){
        Use& loserUse = *loserItr++;
        Instruction* targetInst = dyn_cast<Instruction>(loserUse.getUser());
        assert(targetInst);

        // 5. replace "loser"s in "targetBB"s with "winner", only when
        //    "targetBB" is dominated by BBEdge(entryBB, trueBB).
        //    it works same as "dummy block"
        BasicBlock* startBB = inst->getParent();
        BranchInst *TI = dyn_cast<BranchInst>(startBB->getTerminator());
        BasicBlockEdge BBE(startBB, TI->getSuccessor(0));

        // loser가 use되는 곳을 winner로 set
        if (DT.dominates(BBE, targetInst->getParent())){ loserUse.set(winner); }
    }
}


void decideWinnerLoser(Value* X, Value* Y){
    auto isXArg = dyn_cast<Argument>(X);
    auto isYArg = dyn_cast<Argument>(Y);
    int NoX = -1, NoY = -1;

    if (isXArg && isYArg){
        loser = (NoX = isXArg->getArgNo()) > (NoY = isYArg->getArgNo()) ? X : Y;
        winner = NoX < NoY ? X : Y;
    }else if (!isXArg && !isYArg){
        // find the index each instruction is in.
        for (int i = 0; i < instV.size(); i++){
            if ((*instV[i]).getName().equals((*X).getName())){ NoX = i; }
            else if((*instV[i]).getName().equals((*Y).getName())){ NoY = i; }
        }
        winner = NoX > NoY ? Y : X;
        loser = NoX > NoY ? X : Y;
    }else {
        winner = isXArg ? X : Y;
        loser = isXArg ? Y : X;
    }
}
};
}


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
