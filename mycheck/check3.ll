; Write your own check here.
; Feel free to add arguments to @f, so its signature becomes @f(i32 %x, ...).
; But, this file should contain one function @f() only.
; FileCheck syntax: https://llvm.org/docs/CommandGuide/FileCheck.html

define i32 @f(i32 %joker, i32 %king, i32 %queen) {
    %cond = icmp eq i32 %king, %queen
    br label %true
  true:
    %a = add i32 %king, %queen
    %b = add i32 %joker, %king
    %cond1 = icmp eq i32 %b, %a
    br i1 %cond1, label %true1, label %exit
  true1:
    %c = add i32 %a, %b 
    %d = add i32 %c, %b 
    %cond2 = icmp eq i32 %b, %c 
    br i1 %cond2, label %true2, label %exit
  true2:
    %e = add i32 %c, %d
    %g = add i32 %b, %c 
    %h = add i32 %g, %e
    %cond3 = icmp eq i32 %a, %joker
    br i1 %cond3, label %true, label %exit
  exit:
    call i32 @f(i32 %joker, i32 %a, i32 %b)
    ret i32 0
}