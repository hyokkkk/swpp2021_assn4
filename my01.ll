define void @main(i32 %x, i32 %y) {
entry:
  %a = add i32 %x, %y
  %b = mul i32 %x, %y
  %cond1 = icmp eq i32 %a, %b
  br i1 %cond1, label %true, label %exit

true:
  %c = add i32 %a, %x
  call void @f(i32 %a, i32 %b, i32 %c)
  %cond2 = icmp eq i32 %b, %c
  br i1 %cond2, label %true1, label %exit
true1:
  %d = add i32 %c, %y
  call void @g(i32 %a, i32 %b, i32 %c, i32 %d)
  %cond3 = icmp eq i32 %d, %c
  br i1 %cond3, label %true2, label %exit
true2:
  call void @g(i32 %a, i32 %b, i32 %c, i32 %d)
  br label %exit

exit:
  call void @h(i32 %a, i32 %b)
  ret void

}

declare void @h(i32, i32)
declare void @f(i32, i32, i32)
declare void @g(i32, i32, i32, i32)
