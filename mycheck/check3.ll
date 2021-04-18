; 1. arg vs arg       : king vs queen     @ entry
; 2. inst in same BB  : a vs b            @ true
; 3. inst in diff BB  : c vs d            @ true1
; 4. arg vs inst      : a vs joker
; 5. longer loop than supported testcase
; 6. mixed order

define i32 @f(i32 %joker, i32 %queen, i32 %king) {
;CHECK-LABEL: @f(i32 %joker, i32 %queen, i32 %king) {
;CHECK-NEXT: [[COND:%.*]] = icmp eq i32 [[KING:%.*]], [[QUEEN:%.*]]
;CHECK-NEXT: br i1 [[COND]], label [[TRUE:%.*]], label [[FALSE:%.*]]
;CHECK:  exit:
;CHECK-NEXT: call i32 @loop(i32 [[JOKER:%.*]], i32 [[A:%.*]], i32 [[B:%.*]])
;CHECK-NEXT: ret i32 0
;CHECK:  true2:
;CHECK-NEXT: [[E:%.*]] = add i32 [[A]], [[D:%.*]]
;CHECK-NEXT: [[G:%.*]] = add i32 [[A]], [[A]]
;CHECK-NEXT: [[H:%.*]] = add i32 [[G]], [[E]]
;CHECK-NEXT: [[COND3:%.*]] = icmp eq i32 [[A]], [[JOKER]]
;CHECK-NEXT: br i1 [[COND3]], label [[TRUE]], label [[EXIT:%.*]]
;CHECK:  true1:
;CHECK-NEXT: [[C:%.*]] = add i32 [[A]], [[A]]
;CHECK-NEXT: [[D]] = add i32 [[C]], [[A]]
;CHECK-NEXT: [[COND2:%.*]] = icmp eq i32 [[A]], [[C]]
;CHECK-NEXT: br i1 [[COND2]], label [[TRUE2:%.*]], label [[EXIT]]
;CHECK: false:
;CHECK-NEXT: ret i32 0
;CHECK:  true:
;CHECK-NEXT: [[A]] = add i32 [[QUEEN]], [[QUEEN]]
;CHECK-NEXT: [[B]] = add i32 [[JOKER]], [[QUEEN]]
;CHECK-NEXT: [[COND1:%.*]] = icmp eq i32 [[B]], [[A]]
;CHECK-NEXT: br i1 [[COND1]], label [[TRUE1:%.*]], label [[EXIT]]


    %cond = icmp eq i32 %king, %queen
    br i1 %cond, label %true, label %false
  exit:
    call i32 @loop(i32 %joker, i32 %a, i32 %b)
    ret i32 0
  true2:
    %e = add i32 %c, %d
    %g = add i32 %b, %c
    %h = add i32 %g, %e
    %cond3 = icmp eq i32 %a, %joker
    br i1 %cond3, label %true, label %exit
  true1:
    %c = add i32 %a, %b
    %d = add i32 %c, %b
    %cond2 = icmp eq i32 %b, %c
    br i1 %cond2, label %true2, label %exit
  false:
    ret i32 0
  true:
    %a = add i32 %king, %queen
    %b = add i32 %joker, %king
    %cond1 = icmp eq i32 %b, %a
    br i1 %cond1, label %true1, label %exit
}

declare i32 @loop(i32, i32, i32)
