; Write your own check here.
; Feel free to add arguments to @f, so its signature becomes @f(i32 %x, ...).
; But, this file should contain one function @f() only.
; FileCheck syntax: https://llvm.org/docs/CommandGuide/FileCheck.html

; Case : instruction vs. instruction.
; *** instruction dominance 따질 때 단순히 ir code상 선후관계로 판단하는 것을
;     catch 하기 위해 BB 순서를 control flow와 다르게 섞어놓음.
define i32 @f(i32 %x, i32 %y, i32 %z, i32 %w) {
; CHECK-LABEL:  @f(i32 %x, i32 %y, i32 %z, i32 %w) {
; CHECK:        entry:
; CHECK-NEXT:     [[A:%.*]] = add i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:     [[B:%.*]] = mul i32 [[Z:%.*]], [[W:%.*]]
; CHECK-NEXT:     [[COND1:%.*]] = icmp eq i32 [[A]], [[B]]
; CHECK-NEXT:     br i1 [[COND1]], label [[TRUE:%.*]], label [[EXIT:%.*]]
; CHECK:        true2:
; CHECK-NEXT:     call i32 @f(i32 [[A]], i32 [[A]], i32 [[A]], i32 [[A]])
; CHECK-NEXT:     br label [[EXIT]]
; CHECK:        exit:
; CHECK-NEXT:     call i32 @f(i32 [[A]], i32 [[B]], i32 [[X]], i32 [[Y]])
; CHECK-NEXT:     ret i32 0
; CHECK:        true1:
; CHECK-NEXT:     [[D:%.*]] = add i32 [[A]], [[Y]]
; CHECK-NEXT:     call i32 @f(i32 [[D]], i32 [[A]], i32 [[A]], i32 [[D]]
; CHECK-NEXT:     [[COND3:%.*]] = icmp eq i32 [[D]], [[A]]
; CHECK-NEXT:     br i1 [[COND3]], label [[TRUE2:%.*]], label [[EXIT]]
; CHECK:        true:
; CHECK-NEXT:     [[C:%.*]] = add i32 [[A]], [[X]]
; CHECK-NEXT:     call i32 @f(i32 [[C]], i32 [[A]], i32 [[C]], i32 [[A]])
; CHECK-NEXT:     [[COND2:%.*]] = icmp eq i32 [[A]], [[C]]
; CHECK-NEXT:     br i1 [[COND2]], label [[TRUE1:%.*]], label [[EXIT]]
;
entry:
  %a = add i32 %x, %y
  %b = mul i32 %z, %w
  %cond1 = icmp eq i32 %a, %b
  br i1 %cond1, label %true, label %exit
true2:
  call i32 @f(i32 %d, i32 %b, i32 %c, i32 %d)
  br label %exit
exit:
  call i32 @f(i32 %a, i32 %b, i32 %x, i32 %y)
  ret i32 0
true1:
  %d = add i32 %c, %y
  call i32 @f(i32 %d, i32 %b, i32 %c, i32 %d)
  %cond3 = icmp eq i32 %d, %c
  br i1 %cond3, label %true2, label %exit
true:
  %c = add i32 %a, %x
  call i32 @f(i32 %c, i32 %b, i32 %c, i32 %b)
  %cond2 = icmp eq i32 %b, %c
  br i1 %cond2, label %true1, label %exit
}
