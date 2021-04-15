#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include <vector>

using namespace llvm;
using namespace std;
using namespace llvm::PatternMatch;

   /* case 2. arg & arg
        define void @f(i32 %y, i32 %x){
            %cond = icmp eq i32 %x, %y
            br %cond, %BB_true, %BB_false
        BB_true:
            %a = add i32 %x, %y             // 먼저 등장한 %y로 %x를 바꾼다.
                -> %a = add i32 %y, %y
        }
   */
  // 0. arg는 그냥 vector 만들어서 담아놓는 게 나을 것 같은데. 몇 개 되지도 않을 것.
  //    inst는 뭐가 comparing arg로 쓰일 지 모르니까 다 담아놓는 건 무리일 듯.
  // 1. instruction을 다 돌면서 %cond = icmp i32 %a, %b인 것을 찾는다. by matcher
  // 2. operand %a, %b를 추출.
  // 3. operand가 arg인지 inst인지 판단.
  //    how? -> arg부터
  // 4. 가장 먼저 define한 value를 찾는다.(예시에는 define이 여러 번 돼있는데 오타인듯?)
  // 5. 그 value의 user를 찾음.
  // 6. 그 user 중에서 1.의 %cond를 이용해(%cond의 user 찾아야 함)
  //     br 하는 inst의 operand[0]의 BB name get.
  // 7. user 중에서 해당 BB에게 dominate 당하는 user만 바꾼다. (case별로 다름)
namespace {
class PropagateIntegerEquality : public PassInfoMixin<PropagateIntegerEquality> {
    void replaceEquality(Value *V, bool isArg) {
        // 1. push arguments in vector
        vector<Value*> argsVec;
        if (isArg){ 
            argsVec.push_back(V);
            //--------------- delete
            for (int i = 0; i < argsVec.size(); i++){
                outs() << "[debug] args in vec: " << *argsVec[i] << "\n\n";
            }
            return ;
        }
            outs() <<"[debug]        this is value:"<< *V << "\n";

        // 2. instruction 돌면서 %cond = icmp i32 %a, %b 형태인지 확인
        Instruction* inst = dyn_cast<Instruction>(V);
        Instruction &I = *inst;
        outs() << "inst 맞냐"<< *inst << "\n";
        Value* V1, *V2;
        ICmpInst::Predicate Pred;
        if (match(&I, m_ICmp(Pred, m_Value(V1), m_Value(V2))) 
            && Pred == ICmpInst::ICMP_EQ){
                outs() << "[debug]******I found compare inst!: " << I << "\n";
        }



//        bool flag = false;
//        for (auto itr = V->use_begin(), end = V->use_end(); itr != end;) {
//            flag = true;
//            // Conceptually, 'Use' is a triple (User, Used value, Operand index).
//            Use &U = *itr++;
//            User *Usr = U.getUser();
//
//            Instruction *UsrI = dyn_cast<Instruction>(Usr);
//            assert(UsrI); // The user (e.g. V2) is an instruction
//
//            BasicBlock *BB = UsrI->getParent();
//            if (BB->getName() == "undef_zone"){
//                outs() <<"          - undef_zone usr:"<< *Usr << "\n\n";
//                U.set(UndefValue::get(V->getType()));
//            }else{
//                outs() <<"          - normal user:"<< *Usr << "\n\n";
//            }
//        }
//        if (!flag){
//            outs() << "       !!! there is no user using this value.\n";
//        }
//            // Q: Can we use `for (auto &U : V->uses())`?
//            // A: Since we are changing use list, the for loop cannot be used.
//            // U.set() invalidates the iterator, so incrementing the iterator
//            // will crash.
    }

    
// ============================ function enterance ===================================
public:
    PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
       DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);

        // 1. function argument부터 value로 받아서 user를 찾는다.
        for (Argument &Arg : F.args()){
            outs() << "[debug]     <argument run 시작>: " <<Arg<< "\n";
            replaceEquality(&Arg, true);
        }
        // 2. BB의 instruction들을 value로 받아 user를 찾는다. 
        for (auto &BB : F){
        outs() << "[debug] <BB label>: " << BB.getName() << "\n";
            for (auto &I : BB){
                outs() << "[debug]     <Instruction run 시작>: " << I << "\n";
                replaceEquality(&I, false);
            }
        }

        return PreservedAnalyses::all();
    }

    // param을 어떻게 구성할 지 고민해야 함.
    // DT 사용하려면 FAM까지 전해줘야 함. 

    /* case 1. inst & inst
        entry:
            %x = ...
            br %BB1
        BB1:
            %y = ...
            %cond = icmp eq i32 %x, %y
            br %cond, %BB_true, %BB_false
        BB_true:
            %a = add i32 %x, %y             // %x가 %y를 dominate하니까 %y를 %x로 바꿈.
                -> %a = add i32 %x, %x      // 센 애로 바꾼다.  
    */


  /* case 3. arg & inst
    define void @f(i32 %a){
        %b = ...
        %cond = icmp eq i32 %a, %b
        br %cond, %BB_true, %BB_false
    BB_true:
        %a = add i32 %a, %b                // arg로 inst를 바꾼다. arg가 더 세다.
                -> %a - add i32 %a, %a
    }
  */
    // 1. two args equal: 우리는 지금 동일한 상황만 살펴서 true에 dominant 한 block들의 
    //      use만 바꿔줘야 함. 
    //      그러니 matcher로 비교instruction인지 확인함. 
    //      그리고 그 다음 br inst 읽어서 true인 BB로 감.
    //      계속 BB 돌면서 true BB에 dominant인지 확인
    //      dominant이면 user 찾아서 %x, %y 이면 후자로 전자를 바꾼다. 
//    bool checkDominance(BasicBlock& B1, BasicBlock& B2){
    // 1. 
    /*---------------------------------------------*/
//    // dominant 판별
//        for (Function::iterator I = F.begin(), E = F.end(); I != E; ++I) {
//            for (Function::iterator I2 = I; I2 != E; ++I2) {
//                BasicBlock &B1 = *I;
//                BasicBlock &B2 = *I2;
//                if (DT.dominates(&B1, &B2)){
//                    outs() << B1.getName() << " dominates " << B2.getName() << "!\n";
//                }else if (DT.dominates(&B2, &B1)){
//                    outs() << B2.getName() << " dominates " << B1.getName() << "!\n";
//                }
//            }
//        }                 
//    //*---------------------------------------------*
//    }
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
