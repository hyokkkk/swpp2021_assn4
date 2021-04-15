#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include<vector>
#include <iostream>

using namespace llvm;
using namespace std;

// This example shows how to visit uses of an instruction, and selectively
// replace use with UndefValue.
// After it is run, all non-constant operands in "undef_zone" block will be
// replaced with undef.

namespace {
class FillUndef : public PassInfoMixin<FillUndef> {
    void replaceSpecificUsesWithUndef(Value *V) {
        //   V  = add x, y;
        //   V2 = sub V, 1;
        // From the example above, V2 is V's user!
        outs() <<"        this is value:"<< *V << "\n";
        bool flag = false;
        for (auto itr = V->use_begin(), end = V->use_end(); itr != end;) {
            flag = true;
            // Conceptually, 'Use' is a triple (User, Used value, Operand index).
            Use &U = *itr++;
            User *Usr = U.getUser();

            //outs() <<"this is use:"<< U << "\n";    // addr이 나온다.

            Instruction *UsrI = dyn_cast<Instruction>(Usr);
            assert(UsrI); // The user (e.g. V2) is an instruction

            BasicBlock *BB = UsrI->getParent();
            if (BB->getName() == "undef_zone"){
                outs() <<"          - undef_zone usr:"<< *Usr << "\n\n";
                U.set(UndefValue::get(V->getType()));
            }else{
                outs() <<"          - normal user:"<< *Usr << "\n\n";
            }
        }
        if (!flag){
            outs() << "       !!! there is no user using this value.\n";
        }
            // Q: Can we use `for (auto &U : V->uses())`?
            // A: Since we are changing use list, the for loop cannot be used.
            // U.set() invalidates the iterator, so incrementing the iterator
            // will crash.
    }

public:
    PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
        for (Argument &Arg : F.args()){
            outs() << "     <argument run 시작>: " <<Arg<< "\n";
            replaceSpecificUsesWithUndef(&Arg);
        }

        for (auto &BB : F){
            outs() << "<BB label>: " << BB.getName() << "\n";
            for (auto &I : BB){
                outs() << "     <Instruction run 시작>: " << I << "\n";
                replaceSpecificUsesWithUndef(&I);
            }
        }
        return PreservedAnalyses::all();
    }
};
}

extern "C" ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
    return {
        LLVM_PLUGIN_API_VERSION, "FillUndef", "v0.1",
        [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                ArrayRef<PassBuilder::PipelineElement>) {
                if (Name == "fill-undef") {
                    FPM.addPass(FillUndef());
                    return true;
                }
                return false;
                }
            );
        }
    };
}
