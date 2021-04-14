#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;
using namespace std;

namespace {
class PropagateIntegerEquality : public PassInfoMixin<PropagateIntegerEquality> {
public:
//    void replaceSpecificUsesWithUndef(Value *V) {
//        //   V  = add x, y;
//        //   V2 = sub V, 1;
//        // From the example above, V2 is V's user!
//        outs() <<"        this is value:"<< *V << "\n"; 
//        bool flag = false;
//        for (auto itr = V->use_begin(), end = V->use_end(); itr != end;) {
//        flag = true;
//        // Conceptually, 'Use' is a triple (User, Used value, Operand index).
//        Use &U = *itr++;
//        User *Usr = U.getUser();
//
//        //outs() <<"this is use:"<< U << "\n";    // addr이 나온다. 
//
//        Instruction *UsrI = dyn_cast<Instruction>(Usr);
//        assert(UsrI); // The user (e.g. V2) is an instruction
//
//        BasicBlock *BB = UsrI->getParent();
//        if (BB->getName() == "undef_zone"){
//            outs() <<"          - undef_zone usr:"<< *Usr << "\n\n"; 
//            U.set(UndefValue::get(V->getType()));
//        }else{
//            outs() <<"          - normal user:"<< *Usr << "\n\n"; 
//        }
//    }
//    if (!flag){
//        outs() << "       !!! there is no user using this value.\n";
//    }
//    // Q: Can we use `for (auto &U : V->uses())`?
//    // A: Since we are changing use list, the for loop cannot be used.
//    // U.set() invalidates the iterator, so incrementing the iterator
//    // will crash.
//    }


    PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
       DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);

/*---------------------------------------------*/
       for (Function::iterator I = F.begin(), E = F.end(); I != E; ++I) {
          for (Function::iterator I2 = I; I2 != E; ++I2) {
             BasicBlock &B1 = *I;
             BasicBlock &B2 = *I2;
             if (DT.dominates(&B1, &B2)){
                outs() << B1.getName() << " dominates " << B2.getName() << "!\n";
             }else if (DT.dominates(&B2, &B1)){
                outs() << B2.getName() << " dominates " << B1.getName() << "!\n";
             }
          }
       }                 
/*---------------------------------------------*/
        return PreservedAnalyses::all();
    }

    // param을 어떻게 구성할 지 고민해야 함.
    // DT 사용하려면 FAM까지 전해줘야 함. 

    // 1. two args equal: 우리는 지금 동일한 상황만 살펴서 true에 dominant 한 block들의 
    //      use만 바꿔줘야 함. 
    //      그러니 matcher로 비교instruction인지 확인함. 
    //      그리고 그 다음 br inst 읽어서 true인 BB로 감.
    //      계속 BB 돌면서 true BB에 dominant인지 확인
    //      dominant이면 user 찾아서 %x, %y 이면 후자로 전자를 바꾼다. 
    bool checkDominance(BasicBlock& B1, BasicBlock& B2){

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
