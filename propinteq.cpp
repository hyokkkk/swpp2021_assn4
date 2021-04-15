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
static vector<Value*> argVec;       // dyncast하고 변형해주기 귀찮아서 그냥 넣음.
static vector<Value*> instVec;
// TODO : cond같은 eq문이 여러개면 replace 여러개 해야 함.
// 근데 그래도 vector 만들 필요는 없다. 일단 대체될 것이 정해지면 대체작업 완료하고
// 다음으로 넘어가기 때문.
static Value* toBeReplaced;                
static Value* replacingVal;                

// 0. 기본적으로, function의 모든 instruction을 돌면서 icmp (%a, %b)를 찾을 때마다 
//    replace를 수행한다. 
// 1. arg는 그냥 vector 만들어서 담아놓는 게 나을 것 같은데. 몇 개 되지도 않을 것.
//    inst는 뭐가 comparing arg로 쓰일 지 모르니까 다 담아놓는 건 무리일 듯.
// 2. instruction을 다 돌면서 %cond = icmp i32 %a, %b인 것을 찾는다. by matcher
// 3. cmpOp %a, %b를 추출하여 각각이 arg인지 inst인지 판단. 
//    이걸 먼저 판단해야 replace 당할 reg의 user을 찾을 수 있다.
//    how? -> arg: argVec에 있는지 확인.
//         -> inst: arg 아니면 inst지 뭐. 누가 먼저 나왔는지 판단해야 함.
// 4. 그 user 중에서 2.의 %cond를 이용해(%cond의 user 찾아야 함)
//     br i1 %cond, label %true, label %false inst의 cmpOp[0]의 BB name get.
// 5. 3에서 구한 replaced 될 value의 user 구한다.
// 6. user 중에서 4에서 구한 true BB에게 dominate 당하는 user만 바꾼다. 
//        -> optimize 하려면 dummy block을 넣어야 함. printdom.cpp의 
//          'edge dominates block'은 dummy block 삽입과 동일한 기능을 한다. 
//        -> %cond의 user이 위치하는 BB과, true BB 사이의 edge가
//        -> %cond 문의 arg의 usr가 위치하는 BB를 dominate 하면 replace 가능.
namespace {
class PropagateIntegerEquality : public PassInfoMixin<PropagateIntegerEquality> {
 
// =========================== entry point ===================================
public:
    PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
        // 1. function argument부터 value로 받아서 user를 찾는다.
        for (Argument &Arg : F.args()){
            outs() << "[debug]     <argument run 시작>: " <<Arg<< "\n";
            replaceEquality(F, FAM, &Arg, true);
        }
        // 2. BB의 instruction들을 value로 받아 user를 찾는다. 
        for (auto &BB : F){
        outs() << "[debug] <BB label>: " << BB.getName() << "\n";
            for (auto &I : BB){
                outs() << "[debug]     <Instruction run 시작>: " << I << "\n";
                replaceEquality(F, FAM, &I, false);
            }
        }
        return PreservedAnalyses::all();
    }

//==============================================================================
    void replaceEquality(Function &F, FunctionAnalysisManager &FAM, Value *V, bool isArg) {
        // 1. push arguments in vector
        if (isArg){ 
            argVec.push_back(V);
            //--------------- delete
            for (int i = 0; i < argVec.size(); i++){
                outs() << "[debug] args in vec["<<i<<"]: " << *argVec[i] << "\n";
            }
            return ;
        }

        // 2. instruction 돌면서 `%cond = icmp i32 %a, %b` 형태인지 확인
        Instruction* inst = dyn_cast<Instruction>(V);
        Instruction &I = *inst;
        instVec.push_back(V);

        outs() <<"[debug]        this is value(inst): "<< *V << "\n";
        outs() << "[debug]              inst name:"<< (*inst).getName() << "\n";
        Value* cmpOp0, *cmpOp1;         // %a, %b를 가리킴
        ICmpInst::Predicate Pred;

        // Match '%cond = icmp eq (v1, v2)'
        if (match(&I, m_ICmp(Pred, m_Value(cmpOp0), m_Value(cmpOp1))) 
                                && Pred == ICmpInst::ICMP_EQ){
            outs() << "\n[debug] ****** I found compare inst!: " << I << "\n";
            //cond.push_back(inst);

        // 3. 각 cmpOp가 arg인지 inst인지 판단, replaced 되어야 할 value(arg/inst) 구함
            //cmpOp0= I.getOperand(0);
            //cmpOp1= I.getOperand(1);
            findToBeReplacedValue(I.getOperand(0), I.getOperand(1));
        
        // 4. %cond를 사용하는 user 찾는다(br i1 %cond, label %true, label %false).
            for (auto itr = V->use_begin(), end = V->use_end(); itr != end;) {
                // Conceptually, 'Use' is a triple (User, Used value, Operand index).
                Use &U = *itr++;
                User *br= U.getUser();        // br instruction   

                Instruction *brInst = dyn_cast<Instruction>(br);
                assert(brInst); // The user (e.g. op2) is an instruction

                // 와, 첫번째 lable이 왜 operand 2지??! 왜순서가 0, 2, 1 이지?
                outs() << "[debug] ** this is br user: "<< *brInst<< "\n";
                outs() << "[debug] num of operands: "<< brInst -> getNumOperands()<< "\n";
                outs() << "[debug] ---operand0: "<< brInst -> getOperand(0)->getName() << "\n";
                outs() << "[debug] ---operand1: "<< brInst -> getOperand(1)->getName() << "\n";
                outs() << "[debug] ---operand2: "<< brInst -> getOperand(2)->getName() << "\n";

                StringRef trueBBName = brInst->getOperand(2)->getName();
                outs() << "[debug] >>>>> 여기로 뛸거야 >>> " << trueBBName << "\n";

        // 5. toBeReplaced의 user를 구한다.
                for (auto ritr = toBeReplaced->use_begin(), rend = toBeReplaced->use_end(); ritr != end;){
                    Use& rU = *ritr++;
                    User* rUsr = rU.getUser();      // 바뀌어야 하는 reg를 사용하는 inst.
                    Instruction* replaceTargetInst = dyn_cast<Instruction>(rUsr);
                    assert(replaceTargetInst);

                    outs() << "[debug] 바뀌어야 하는 instruction: "<<*replaceTargetInst<<"\n";
                    for (int i = 0; i < replaceTargetInst->getNumOperands(); i++){
                        outs() << "[debug] ---target operand" << i <<": "<<
                        replaceTargetInst-> getOperand(i)->getName() << "\n";
                    }

                    // 6. replaceTargetInst 중에서 entry와 trueblock 사이의 edge에 의해
                    // dominated 되는 BB에 있는 것만 replace한다.
                    BasicBlock* targetUserBB = replaceTargetInst->getParent();
                    if (checkDominance(*(inst->getParent()), *targetUserBB, F, FAM)){
                        rU.set(replacingVal);       // toBeReplaced의 use를 replacingVal로 set.
                    }
                }
            }
        }
    }

//=================================================================================
    void findToBeReplacedValue(Value* cmpOp0, Value* cmpOp1){
            outs() << "[debug] cmpOp0: " << *cmpOp0 << "\n";
            outs() << "[debug] cmpOp0.getname(): " << (*cmpOp0).getName() << "\n";
            outs() << "[debug] cmpOp1: " << *cmpOp1 << "\n";
            outs() << "[debug] cmpOp1.getname(): " << (*cmpOp1).getName() << "\n";

            // each cmpOp's index if it is in the argVec
            int op0argVec = -1;
            int op1argVec = -1;
            for (int i = 0; i < argVec.size(); i++){
                // Value 자체의 값을 비교하고 싶었지만 그런 함수 못찾음
                // 어짜피 llvm ir에서는 var 이름 중복 안 되니 상관없다고 생각함.
                if ((*argVec[i]).getName().equals((*cmpOp0).getName())){
                    op0argVec = i;
                }else if((*argVec[i]).getName().equals((*cmpOp1).getName())){
                    op1argVec = i;
                }
            }

            outs() << "[debug]--" << *cmpOp0 << " is argv[" << op0argVec << "]\n";
            outs() << "[debug]--" << *cmpOp1 << " is argv[" << op1argVec << "]\n\n";

            // (1) 둘 다 inst 인 경우: 나중에 오는 애가 replaced.(first dominates last) 
            if (op0argVec == -1 && op1argVec == -1){
                int op0instVec = -1;
                int op1instVec = -1;
                for (int i = 0; i < instVec.size(); i++){
                    if ((*instVec[i]).getName().equals((*cmpOp0).getName())){
                        op0instVec= i;
                    }else if((*instVec[i]).getName().equals((*cmpOp1).getName())){
                        op1instVec= i;
                    }
                }
                outs() << "[debug]--" << *cmpOp0 << " is inst[" << op0instVec<< "]\n";
                outs() << "[debug]--" << *cmpOp1 << " is inst[" << op1instVec<< "]\n\n";

                toBeReplaced = op0instVec > op1instVec ? cmpOp0 : cmpOp1;
                replacingVal = op0instVec > op1instVec ? cmpOp1 : cmpOp0;
            // (2) 둘 다 arg 인 경우: 나중에 나오는 애가 replaced 
            }else if (op0argVec != -1 && op1argVec != -1){
                toBeReplaced = op0argVec > op1argVec ? cmpOp0 : cmpOp1;
                replacingVal = op0argVec > op1argVec ? cmpOp1 : cmpOp0;

            // (3) 하나는 arg, 하나는 inst: 무조건 arg replaces inst
            }else {
                // -1 인게 inst지. 
                toBeReplaced = op0argVec == -1 ? cmpOp0 : cmpOp1;
                replacingVal = op0argVec == -1 ? cmpOp1 : cmpOp0;
            }
            outs() << "[debug]  ** \'"<< *toBeReplaced << 
            "\' should be replaced by \'"<<*replacingVal<< "\'\n\n";
    }

//=================================================================================
    bool checkDominance(BasicBlock& startBB, 
                        BasicBlock& targetBB, Function& F, 
                        FunctionAnalysisManager& FAM) {
        DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
        BranchInst *TI = dyn_cast<BranchInst>(startBB.getTerminator());
        BasicBlock* destBB = TI->getSuccessor(0);   // 어짜피 entry -> true만 보면 된다.

       // BasicBlock* BBNext =
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
