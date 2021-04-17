----- test -----
== data/check1.ll ==
[debug] basic block list size : 4
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond, label %bb_true, label %bb_false

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: 
[debug] === 이게 branch instruction terminator:   br i1 %cond, label %bb_true, label %bb_false

[debug] === successor 갯수: 2
이거 타입이 뭐임 bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_false
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_true
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] +++++++ bb_exit
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_false
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] +++++++ bb_exit
[debug]        this is value(inst):   %cond = icmp eq i32 %a, %b
[debug]              inst name:cond

[debug] ****** I found compare inst!:   %cond = icmp eq i32 %a, %b

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0: i32 %a
[debug] Op0.getname(): a
[debug] Op1: i32 %b
[debug] Op1.getname(): b
[debug]--i32 %a is argv[0]
[debug]--i32 %b is argv[1]

[debug]  ** 'i32 %b' should be replaced by 'i32 %a'


[debug] ** 4. find condUser:   br i1 %cond, label %bb_true, label %bb_false
[debug] num of operands: 3
[debug] ---operand0: cond
[debug] ---operand1: bb_false
[debug] ---operand2: bb_true
[debug] >>> 여기로 뛸거야 >>> bb_true
[debug] ** 5. loserUsers:   ret i32 %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_true!!!!!!!

[debug] ** 5. loserUsers:   %cond = icmp eq i32 %a, %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug]        this is value(inst):   br i1 %cond, label %bb_true, label %bb_false
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %a)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 %b
[debug]              inst name:
== data/check10.ll ==
[debug] basic block list size : 4
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond, label %loop, label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: 
[debug] === 이게 branch instruction terminator:   br i1 %cond, label %loop, label %exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 loop
[debug] ** BBlist에서 이름 같은 BB 찾음: loop
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ loop
[debug] +++++++ exit
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond2, label %latch, label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: loop
[debug] === 이게 branch instruction terminator:   br i1 %cond2, label %latch, label %exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 latch
[debug] ** BBlist에서 이름 같은 BB 찾음: latch
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ loop
[debug] +++++++ exit
[debug] +++++++ latch
[debug] <<<이건 그냥 inst만 받은거>>>:   ret void

이게 ret이 나와야 하는데ret
오잉 여기 안 들어와??
[debug]        this is value(inst):   %cond = icmp eq i32 %a, %b
[debug]              inst name:cond

[debug] ****** I found compare inst!:   %cond = icmp eq i32 %a, %b

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0: i32 %a
[debug] Op0.getname(): a
[debug] Op1: i32 %b
[debug] Op1.getname(): b
[debug]--i32 %a is argv[0]
[debug]--i32 %b is argv[1]

[debug]  ** 'i32 %b' should be replaced by 'i32 %a'


[debug] ** 4. find condUser:   br i1 %cond, label %loop, label %exit
[debug] num of operands: 3
[debug] ---operand0: cond
[debug] ---operand1: exit
[debug] ---operand2: loop
[debug] >>> 여기로 뛸거야 >>> loop
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: loop
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: loop
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,loop) dominates latch!!!!!!!

[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: loop
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,loop) dominates loop!!!!!!!

[debug] ** 5. loserUsers:   %cond = icmp eq i32 %a, %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: loop
[debug] successor[1]: exit
[debug]        this is value(inst):   br i1 %cond, label %loop, label %exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %a, i32 %c)
[debug]              inst name:
[debug]        this is value(inst):   %cond2 = icmp eq i32 %a, %c
[debug]              inst name:cond2

[debug] ****** I found compare inst!:   %cond2 = icmp eq i32 %a, %c

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0: i32 %a
[debug] Op0.getname(): a
[debug] Op1: i32 %c
[debug] Op1.getname(): c
[debug]--i32 %a is argv[0]
[debug]--i32 %c is argv[2]

[debug]  ** 'i32 %c' should be replaced by 'i32 %a'


[debug] ** 4. find condUser:   br i1 %cond2, label %latch, label %exit
[debug] num of operands: 3
[debug] ---operand0: cond2
[debug] ---operand1: exit
[debug] ---operand2: latch
[debug] >>> 여기로 뛸거야 >>> latch
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: latch
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %a, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: latch
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryloop,latch) dominates latch!!!!!!!

[debug] ** 5. loserUsers:   %cond2 = icmp eq i32 %a, %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: latch
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %a, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: latch
[debug] successor[1]: exit
[debug]        this is value(inst):   br i1 %cond2, label %latch, label %exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b, i32 %c)
[debug]              inst name:
[debug]        this is value(inst):   ret void
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %a, i32 %a)
[debug]              inst name:
[debug]        this is value(inst):   br label %loop
[debug]              inst name:
== data/check11.ll ==
[debug] basic block list size : 3
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond, label %bb_true, label %bb_false

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: 
[debug] === 이게 branch instruction terminator:   br i1 %cond, label %bb_true, label %bb_false

[debug] === successor 갯수: 2
이거 타입이 뭐임 bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_false
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] <<<이건 그냥 inst만 받은거>>>:   ret void

이게 ret이 나와야 하는데ret
오잉 여기 안 들어와??
[debug]        this is value(inst):   %cond = icmp ne i32 %a, %b
[debug]              inst name:cond
[debug]        this is value(inst):   br i1 %cond, label %bb_true, label %bb_false
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   ret void
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   ret void
[debug]              inst name:
== data/check2.ll ==
[debug] basic block list size : 4
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond, label %bb_true, label %bb_false

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: 
[debug] === 이게 branch instruction terminator:   br i1 %cond, label %bb_true, label %bb_false

[debug] === successor 갯수: 2
이거 타입이 뭐임 bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_false
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_true
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] +++++++ bb_exit
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_false
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] +++++++ bb_exit
[debug]        this is value(inst):   %cond = icmp eq i32 %a, %b
[debug]              inst name:cond

[debug] ****** I found compare inst!:   %cond = icmp eq i32 %a, %b

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0: i32 %a
[debug] Op0.getname(): a
[debug] Op1: i32 %b
[debug] Op1.getname(): b
[debug]--i32 %a is argv[1]
[debug]--i32 %b is argv[0]

[debug]  ** 'i32 %a' should be replaced by 'i32 %b'


[debug] ** 4. find condUser:   br i1 %cond, label %bb_true, label %bb_false
[debug] num of operands: 3
[debug] ---operand0: cond
[debug] ---operand1: bb_false
[debug] ---operand2: bb_true
[debug] >>> 여기로 뛸거야 >>> bb_true
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_true!!!!!!!

[debug] ** 5. loserUsers:   %cond = icmp eq i32 %a, %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug]        this is value(inst):   br i1 %cond, label %bb_true, label %bb_false
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %b, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 %b
[debug]              inst name:
== data/check3.ll ==
[debug] basic block list size : 4
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond, label %bb_true, label %bb_false

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: 
[debug] === 이게 branch instruction terminator:   br i1 %cond, label %bb_true, label %bb_false

[debug] === successor 갯수: 2
이거 타입이 뭐임 bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_false
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_true
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] +++++++ bb_exit
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_false
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] +++++++ bb_exit
[debug]        this is value(inst):   %b = mul i32 %x, %y
[debug]              inst name:b
[debug]        this is value(inst):   %a = add i32 %x, %y
[debug]              inst name:a
[debug]        this is value(inst):   %cond = icmp eq i32 %a, %b
[debug]              inst name:cond

[debug] ****** I found compare inst!:   %cond = icmp eq i32 %a, %b

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %a = add i32 %x, %y
[debug] Op0.getname(): a
[debug] Op1:   %b = mul i32 %x, %y
[debug] Op1.getname(): b
[debug]--  %a = add i32 %x, %y is argv[-1]
[debug]--  %b = mul i32 %x, %y is argv[-1]

[debug]--  %a = add i32 %x, %y is inst[1]
[debug]--  %b = mul i32 %x, %y is inst[0]

[debug]  ** '  %a = add i32 %x, %y' should be replaced by '  %b = mul i32 %x, %y'


[debug] ** 4. find condUser:   br i1 %cond, label %bb_true, label %bb_false
[debug] num of operands: 3
[debug] ---operand0: cond
[debug] ---operand1: bb_false
[debug] ---operand2: bb_true
[debug] >>> 여기로 뛸거야 >>> bb_true
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_true!!!!!!!

[debug] ** 5. loserUsers:   %cond = icmp eq i32 %a, %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug]        this is value(inst):   br i1 %cond, label %bb_true, label %bb_false
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %b, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 %b
[debug]              inst name:
== data/check4.ll ==
[debug] basic block list size : 4
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond, label %bb_true, label %bb_false

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: 
[debug] === 이게 branch instruction terminator:   br i1 %cond, label %bb_true, label %bb_false

[debug] === successor 갯수: 2
이거 타입이 뭐임 bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_false
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_true
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] +++++++ bb_exit
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_false
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] +++++++ bb_exit
[debug]        this is value(inst):   %a = add i32 %x, %y
[debug]              inst name:a
[debug]        this is value(inst):   %b = mul i32 %x, %y
[debug]              inst name:b
[debug]        this is value(inst):   %cond = icmp eq i32 %a, %b
[debug]              inst name:cond

[debug] ****** I found compare inst!:   %cond = icmp eq i32 %a, %b

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %a = add i32 %x, %y
[debug] Op0.getname(): a
[debug] Op1:   %b = mul i32 %x, %y
[debug] Op1.getname(): b
[debug]--  %a = add i32 %x, %y is argv[-1]
[debug]--  %b = mul i32 %x, %y is argv[-1]

[debug]--  %a = add i32 %x, %y is inst[0]
[debug]--  %b = mul i32 %x, %y is inst[1]

[debug]  ** '  %b = mul i32 %x, %y' should be replaced by '  %a = add i32 %x, %y'


[debug] ** 4. find condUser:   br i1 %cond, label %bb_true, label %bb_false
[debug] num of operands: 3
[debug] ---operand0: cond
[debug] ---operand1: bb_false
[debug] ---operand2: bb_true
[debug] >>> 여기로 뛸거야 >>> bb_true
[debug] ** 5. loserUsers:   ret i32 %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_true!!!!!!!

[debug] ** 5. loserUsers:   %cond = icmp eq i32 %a, %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug]        this is value(inst):   br i1 %cond, label %bb_true, label %bb_false
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %a)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 %b
[debug]              inst name:
== data/check5.ll ==
[debug] basic block list size : 4
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond, label %bb_true, label %bb_false

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: 
[debug] === 이게 branch instruction terminator:   br i1 %cond, label %bb_true, label %bb_false

[debug] === successor 갯수: 2
이거 타입이 뭐임 bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_false
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_true
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] +++++++ bb_exit
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_false
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] +++++++ bb_exit
[debug]        this is value(inst):   %a = add i32 %x, %y
[debug]              inst name:a
[debug]        this is value(inst):   %cond = icmp eq i32 %a, %b
[debug]              inst name:cond

[debug] ****** I found compare inst!:   %cond = icmp eq i32 %a, %b

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %a = add i32 %x, %y
[debug] Op0.getname(): a
[debug] Op1: i32 %b
[debug] Op1.getname(): b
[debug]--  %a = add i32 %x, %y is argv[-1]
[debug]--i32 %b is argv[2]

[debug]  ** '  %a = add i32 %x, %y' should be replaced by 'i32 %b'


[debug] ** 4. find condUser:   br i1 %cond, label %bb_true, label %bb_false
[debug] num of operands: 3
[debug] ---operand0: cond
[debug] ---operand1: bb_false
[debug] ---operand2: bb_true
[debug] >>> 여기로 뛸거야 >>> bb_true
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_true!!!!!!!

[debug] ** 5. loserUsers:   %cond = icmp eq i32 %a, %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug]        this is value(inst):   br i1 %cond, label %bb_true, label %bb_false
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %b, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 %b
[debug]              inst name:
== data/check6.ll ==
[debug] basic block list size : 4
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond, label %bb_true, label %bb_false

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: 
[debug] === 이게 branch instruction terminator:   br i1 %cond, label %bb_true, label %bb_false

[debug] === successor 갯수: 2
이거 타입이 뭐임 bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_false
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_true
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] +++++++ bb_exit
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_false
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_false
[debug] +++++++ bb_exit
[debug]        this is value(inst):   %a = add i32 %x, %y
[debug]              inst name:a
[debug]        this is value(inst):   %cond = icmp eq i32 %b, %a
[debug]              inst name:cond

[debug] ****** I found compare inst!:   %cond = icmp eq i32 %b, %a

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0: i32 %b
[debug] Op0.getname(): b
[debug] Op1:   %a = add i32 %x, %y
[debug] Op1.getname(): a
[debug]--i32 %b is argv[2]
[debug]--  %a = add i32 %x, %y is argv[-1]

[debug]  ** '  %a = add i32 %x, %y' should be replaced by 'i32 %b'


[debug] ** 4. find condUser:   br i1 %cond, label %bb_true, label %bb_false
[debug] num of operands: 3
[debug] ---operand0: cond
[debug] ---operand1: bb_false
[debug] ---operand2: bb_true
[debug] >>> 여기로 뛸거야 >>> bb_true
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_true!!!!!!!

[debug] ** 5. loserUsers:   %cond = icmp eq i32 %b, %a

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_false
[debug]        this is value(inst):   br i1 %cond, label %bb_true, label %bb_false
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %b, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 %b
[debug]              inst name:
== data/check7.ll ==
[debug] basic block list size : 5
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond, label %bb_true, label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: 
[debug] === 이게 branch instruction terminator:   br i1 %cond, label %bb_true, label %bb_exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_exit
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond2, label %bb_true2, label %bb_false

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_true
[debug] === 이게 branch instruction terminator:   br i1 %cond2, label %bb_true2, label %bb_false

[debug] === successor 갯수: 2
이거 타입이 뭐임 bb_true2
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_true2
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_false
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_exit
[debug] +++++++ bb_true2
[debug] +++++++ bb_false
[debug] <<<이건 그냥 inst만 받은거>>>:   ret i32 %b

이게 ret이 나와야 하는데ret
오잉 여기 안 들어와??
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_true2
[debug] === 이게 branch instruction terminator:   br label %bb_exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 bb_exit
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_exit
[debug] +++++++ bb_true2
[debug] +++++++ bb_false
[debug]        this is value(inst):   %cond = icmp eq i32 %a, %b
[debug]              inst name:cond

[debug] ****** I found compare inst!:   %cond = icmp eq i32 %a, %b

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0: i32 %a
[debug] Op0.getname(): a
[debug] Op1: i32 %b
[debug] Op1.getname(): b
[debug]--i32 %a is argv[0]
[debug]--i32 %b is argv[1]

[debug]  ** 'i32 %b' should be replaced by 'i32 %a'


[debug] ** 4. find condUser:   br i1 %cond, label %bb_true, label %bb_exit
[debug] num of operands: 3
[debug] ---operand0: cond
[debug] ---operand1: bb_exit
[debug] ---operand2: bb_true
[debug] >>> 여기로 뛸거야 >>> bb_true
[debug] ** 5. loserUsers:   ret i32 %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_false!!!!!!!

[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_true2!!!!!!!

[debug] ** 5. loserUsers:   %cond2 = icmp eq i32 %b, %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_true!!!!!!!

[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_true!!!!!!!

[debug] ** 5. loserUsers:   %cond = icmp eq i32 %a, %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug]        this is value(inst):   br i1 %cond, label %bb_true, label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %a, i32 %c)
[debug]              inst name:
[debug]        this is value(inst):   %cond2 = icmp eq i32 %a, %c
[debug]              inst name:cond2

[debug] ****** I found compare inst!:   %cond2 = icmp eq i32 %a, %c

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0: i32 %a
[debug] Op0.getname(): a
[debug] Op1: i32 %c
[debug] Op1.getname(): c
[debug]--i32 %a is argv[0]
[debug]--i32 %c is argv[2]

[debug]  ** 'i32 %c' should be replaced by 'i32 %a'


[debug] ** 4. find condUser:   br i1 %cond2, label %bb_true2, label %bb_false
[debug] num of operands: 3
[debug] ---operand0: cond2
[debug] ---operand1: bb_false
[debug] ---operand2: bb_true2
[debug] >>> 여기로 뛸거야 >>> bb_true2
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true2
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %a, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true2
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %a, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true2
[debug] successor[1]: bb_false
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrybb_true,bb_true2) dominates bb_true2!!!!!!!

[debug] ** 5. loserUsers:   %cond2 = icmp eq i32 %a, %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true2
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %a, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true2
[debug] successor[1]: bb_false
[debug]        this is value(inst):   br i1 %cond2, label %bb_true2, label %bb_false
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b, i32 %c)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 %b
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %a, i32 %a)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %a, i32 %c)
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_exit
[debug]              inst name:
== data/check8.ll ==
[debug] basic block list size : 5
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond, label %bb_true, label %bb_exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: 
[debug] === 이게 branch instruction terminator:   br i1 %cond, label %bb_true, label %bb_exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_exit
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond2, label %bb_true2, label %bb_false

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: bb_true
[debug] === 이게 branch instruction terminator:   br i1 %cond2, label %bb_true2, label %bb_false

[debug] === successor 갯수: 2
이거 타입이 뭐임 bb_true2
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_true2
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_false
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_exit
[debug] +++++++ bb_true2
[debug] +++++++ bb_false
[debug] <<<이건 그냥 inst만 받은거>>>:   ret i32 %a

이게 ret이 나와야 하는데ret
오잉 여기 안 들어와??
[debug] <<<이건 그냥 inst만 받은거>>>:   ret i32 %c

이게 ret이 나와야 하는데ret
오잉 여기 안 들어와??
[debug]        this is value(inst):   %a = call i32 @g(i32 %b, i32 %c)
[debug]              inst name:a
[debug]        this is value(inst):   %cond = icmp eq i32 %a, %b
[debug]              inst name:cond

[debug] ****** I found compare inst!:   %cond = icmp eq i32 %a, %b

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %a = call i32 @g(i32 %b, i32 %c)
[debug] Op0.getname(): a
[debug] Op1: i32 %b
[debug] Op1.getname(): b
[debug]--  %a = call i32 @g(i32 %b, i32 %c) is argv[-1]
[debug]--i32 %b is argv[0]

[debug]  ** '  %a = call i32 @g(i32 %b, i32 %c)' should be replaced by 'i32 %b'


[debug] ** 4. find condUser:   br i1 %cond, label %bb_true, label %bb_exit
[debug] num of operands: 3
[debug] ---operand0: cond
[debug] ---operand1: bb_exit
[debug] ---operand2: bb_true
[debug] >>> 여기로 뛸거야 >>> bb_true
[debug] ** 5. loserUsers:   ret i32 %a

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug] ** 5. loserUsers:   ret i32 %a

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_false!!!!!!!

[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_false!!!!!!!

[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_true2!!!!!!!

[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entry,bb_true) dominates bb_true!!!!!!!

[debug] ** 5. loserUsers:   %cond = icmp eq i32 %a, %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_exit
[debug]        this is value(inst):   br i1 %cond, label %bb_true, label %bb_exit
[debug]              inst name:
[debug]        this is value(inst):   %cond2 = icmp eq i32 %b, %c
[debug]              inst name:cond2

[debug] ****** I found compare inst!:   %cond2 = icmp eq i32 %b, %c

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0: i32 %b
[debug] Op0.getname(): b
[debug] Op1: i32 %c
[debug] Op1.getname(): c
[debug]--i32 %b is argv[0]
[debug]--i32 %c is argv[1]

[debug]  ** 'i32 %c' should be replaced by 'i32 %b'


[debug] ** 4. find condUser:   br i1 %cond2, label %bb_true2, label %bb_false
[debug] num of operands: 3
[debug] ---operand0: cond2
[debug] ---operand1: bb_false
[debug] ---operand2: bb_true2
[debug] >>> 여기로 뛸거야 >>> bb_true2
[debug] ** 5. loserUsers:   call void @f(i32 %a, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true2
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   call void @f(i32 %b, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true2
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   ret i32 %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true2
[debug] successor[1]: bb_false
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrybb_true,bb_true2) dominates bb_true2!!!!!!!

[debug] ** 5. loserUsers:   call void @f(i32 %b, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true2
[debug] successor[1]: bb_false
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrybb_true,bb_true2) dominates bb_true2!!!!!!!

[debug] ** 5. loserUsers:   call void @f(i32 %b, i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true2
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   %cond2 = icmp eq i32 %b, %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true2
[debug] successor[1]: bb_false
[debug] ** 5. loserUsers:   %a = call i32 @g(i32 %b, i32 %c)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true2
[debug] successor[1]: bb_false
[debug]        this is value(inst):   call void @f(i32 %b, i32 %b, i32 %c)
[debug]              inst name:
[debug]        this is value(inst):   br i1 %cond2, label %bb_true2, label %bb_false
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %a, i32 %b, i32 %c)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 %a
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %b, i32 %b, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 %b
[debug]              inst name:
[debug]        this is value(inst):   call void @f(i32 %b, i32 %b, i32 %c)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 %b
[debug]              inst name:
== data/check9.ll ==
[debug] basic block list size : 3
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond, label %bb_true, label %bb_else

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: 
[debug] === 이게 branch instruction terminator:   br i1 %cond, label %bb_true, label %bb_else

[debug] === successor 갯수: 2
이거 타입이 뭐임 bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_true
[debug] ** BBlist에서 이름 같은 BB 찾음: bb_else
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ bb_true
[debug] +++++++ bb_else
[debug] <<<이건 그냥 inst만 받은거>>>:   ret i32 %b

이게 ret이 나와야 하는데ret
오잉 여기 안 들어와??
[debug]        this is value(inst):   %cond = icmp eq i32 %a, %b
[debug]              inst name:cond

[debug] ****** I found compare inst!:   %cond = icmp eq i32 %a, %b

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0: i32 %a
[debug] Op0.getname(): a
[debug] Op1: i32 %b
[debug] Op1.getname(): b
[debug]--i32 %a is argv[0]
[debug]--i32 %b is argv[1]

[debug]  ** 'i32 %b' should be replaced by 'i32 %a'


[debug] ** 4. find condUser:   br i1 %cond, label %bb_true, label %bb_else
[debug] num of operands: 3
[debug] ---operand0: cond
[debug] ---operand1: bb_else
[debug] ---operand2: bb_true
[debug] >>> 여기로 뛸거야 >>> bb_true
[debug] ** 5. loserUsers:   ret i32 %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_else
[debug] ** 5. loserUsers:   call void @g(i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_else
[debug] ** 5. loserUsers:   %cond = icmp eq i32 %a, %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: bb_true
[debug] successor[1]: bb_else
[debug]        this is value(inst):   br i1 %cond, label %bb_true, label %bb_else
[debug]              inst name:
[debug]        this is value(inst):   call void @g(i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 %b
[debug]              inst name:
[debug]        this is value(inst):   br label %bb_true
[debug]              inst name:
Score: 110 / 110
----- my checks -----
== mycheck/check1.ll ==
[debug] basic block list size : 5
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond1, label %true, label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: entry
[debug] === 이게 branch instruction terminator:   br i1 %cond1, label %true, label %exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 true
[debug] ** BBlist에서 이름 같은 BB 찾음: true
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ entry
[debug] +++++++ true
[debug] +++++++ exit
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond2, label %true1, label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: true
[debug] === 이게 branch instruction terminator:   br i1 %cond2, label %true1, label %exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 true1
[debug] ** BBlist에서 이름 같은 BB 찾음: true1
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ entry
[debug] +++++++ true
[debug] +++++++ exit
[debug] +++++++ true1
[debug] <<<이건 그냥 inst만 받은거>>>:   ret i32 0

이게 ret이 나와야 하는데ret
오잉 여기 안 들어와??
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond3, label %true2, label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: true1
[debug] === 이게 branch instruction terminator:   br i1 %cond3, label %true2, label %exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 true2
[debug] ** BBlist에서 이름 같은 BB 찾음: true2
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ entry
[debug] +++++++ true
[debug] +++++++ exit
[debug] +++++++ true1
[debug] +++++++ true2
[debug]        this is value(inst):   %a = add i32 %x, %y
[debug]              inst name:a
[debug]        this is value(inst):   %b = mul i32 %z, %w
[debug]              inst name:b
[debug]        this is value(inst):   %cond1 = icmp eq i32 %a, %b
[debug]              inst name:cond1

[debug] ****** I found compare inst!:   %cond1 = icmp eq i32 %a, %b

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %a = add i32 %x, %y
[debug] Op0.getname(): a
[debug] Op1:   %b = mul i32 %z, %w
[debug] Op1.getname(): b
[debug]--  %a = add i32 %x, %y is argv[-1]
[debug]--  %b = mul i32 %z, %w is argv[-1]

[debug]--  %a = add i32 %x, %y is inst[0]
[debug]--  %b = mul i32 %z, %w is inst[1]

[debug]  ** '  %b = mul i32 %z, %w' should be replaced by '  %a = add i32 %x, %y'


[debug] ** 4. find condUser:   br i1 %cond1, label %true, label %exit
[debug] num of operands: 3
[debug] ---operand0: cond1
[debug] ---operand1: exit
[debug] ---operand2: true
[debug] >>> 여기로 뛸거야 >>> true
[debug] ** 5. loserUsers:   %cond2 = icmp eq i32 %b, %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryentry,true) dominates true!!!!!!!

[debug] ** 5. loserUsers:   %3 = call i32 @f(i32 %c, i32 %b, i32 %c, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryentry,true) dominates true!!!!!!!

[debug] ** 5. loserUsers:   %3 = call i32 @f(i32 %c, i32 %b, i32 %c, i32 %a)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryentry,true) dominates true!!!!!!!

[debug] ** 5. loserUsers:   %2 = call i32 @f(i32 %d, i32 %b, i32 %c, i32 %d)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryentry,true) dominates true1!!!!!!!

[debug] ** 5. loserUsers:   %1 = call i32 @f(i32 %a, i32 %b, i32 %x, i32 %y)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %0 = call i32 @f(i32 %d, i32 %b, i32 %c, i32 %d)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryentry,true) dominates true2!!!!!!!

[debug] ** 5. loserUsers:   %cond1 = icmp eq i32 %a, %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug]        this is value(inst):   br i1 %cond1, label %true, label %exit
[debug]              inst name:
[debug]        this is value(inst):   %c = add i32 %a, %x
[debug]              inst name:c
[debug]        this is value(inst):   %3 = call i32 @f(i32 %c, i32 %a, i32 %c, i32 %a)
[debug]              inst name:
[debug]        this is value(inst):   %cond2 = icmp eq i32 %a, %c
[debug]              inst name:cond2

[debug] ****** I found compare inst!:   %cond2 = icmp eq i32 %a, %c

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %a = add i32 %x, %y
[debug] Op0.getname(): a
[debug] Op1:   %c = add i32 %a, %x
[debug] Op1.getname(): c
[debug]--  %a = add i32 %x, %y is argv[-1]
[debug]--  %c = add i32 %a, %x is argv[-1]

[debug]--  %a = add i32 %x, %y is inst[0]
[debug]--  %c = add i32 %a, %x is inst[4]

[debug]  ** '  %c = add i32 %a, %x' should be replaced by '  %a = add i32 %x, %y'


[debug] ** 4. find condUser:   br i1 %cond2, label %true1, label %exit
[debug] num of operands: 3
[debug] ---operand0: cond2
[debug] ---operand1: exit
[debug] ---operand2: true1
[debug] >>> 여기로 뛸거야 >>> true1
[debug] ** 5. loserUsers:   %cond2 = icmp eq i32 %a, %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %3 = call i32 @f(i32 %c, i32 %a, i32 %c, i32 %a)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %3 = call i32 @f(i32 %c, i32 %a, i32 %c, i32 %a)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %0 = call i32 @f(i32 %d, i32 %a, i32 %c, i32 %d)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrytrue,true1) dominates true2!!!!!!!

[debug] ** 5. loserUsers:   %d = add i32 %c, %y

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrytrue,true1) dominates true1!!!!!!!

[debug] ** 5. loserUsers:   %2 = call i32 @f(i32 %d, i32 %a, i32 %c, i32 %d)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrytrue,true1) dominates true1!!!!!!!

[debug] ** 5. loserUsers:   %cond3 = icmp eq i32 %d, %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrytrue,true1) dominates true1!!!!!!!

[debug]        this is value(inst):   br i1 %cond2, label %true1, label %exit
[debug]              inst name:
[debug]        this is value(inst):   %1 = call i32 @f(i32 %a, i32 %b, i32 %x, i32 %y)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 0
[debug]              inst name:
[debug]        this is value(inst):   %d = add i32 %a, %y
[debug]              inst name:d
[debug]        this is value(inst):   %2 = call i32 @f(i32 %d, i32 %a, i32 %a, i32 %d)
[debug]              inst name:
[debug]        this is value(inst):   %cond3 = icmp eq i32 %d, %a
[debug]              inst name:cond3

[debug] ****** I found compare inst!:   %cond3 = icmp eq i32 %d, %a

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %d = add i32 %a, %y
[debug] Op0.getname(): d
[debug] Op1:   %a = add i32 %x, %y
[debug] Op1.getname(): a
[debug]--  %d = add i32 %a, %y is argv[-1]
[debug]--  %a = add i32 %x, %y is argv[-1]

[debug]--  %d = add i32 %a, %y is inst[10]
[debug]--  %a = add i32 %x, %y is inst[0]

[debug]  ** '  %d = add i32 %a, %y' should be replaced by '  %a = add i32 %x, %y'


[debug] ** 4. find condUser:   br i1 %cond3, label %true2, label %exit
[debug] num of operands: 3
[debug] ---operand0: cond3
[debug] ---operand1: exit
[debug] ---operand2: true2
[debug] >>> 여기로 뛸거야 >>> true2
[debug] ** 5. loserUsers:   %cond3 = icmp eq i32 %d, %a

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true2
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %2 = call i32 @f(i32 %d, i32 %a, i32 %a, i32 %d)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true2
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %2 = call i32 @f(i32 %d, i32 %a, i32 %a, i32 %d)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true2
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %0 = call i32 @f(i32 %d, i32 %a, i32 %a, i32 %d)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true2
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrytrue1,true2) dominates true2!!!!!!!

[debug] ** 5. loserUsers:   %0 = call i32 @f(i32 %a, i32 %a, i32 %a, i32 %d)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true2
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrytrue1,true2) dominates true2!!!!!!!

[debug]        this is value(inst):   br i1 %cond3, label %true2, label %exit
[debug]              inst name:
[debug]        this is value(inst):   %0 = call i32 @f(i32 %a, i32 %a, i32 %a, i32 %a)
[debug]              inst name:
[debug]        this is value(inst):   br label %exit
[debug]              inst name:
== mycheck/check2.ll ==
[debug] basic block list size : 11
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond0, label %T, label %F

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: entry
[debug] === 이게 branch instruction terminator:   br i1 %cond0, label %T, label %F

[debug] === successor 갯수: 2
이거 타입이 뭐임 T
[debug] ** BBlist에서 이름 같은 BB 찾음: T
[debug] ** BBlist에서 이름 같은 BB 찾음: F
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ entry
[debug] +++++++ T
[debug] +++++++ F
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond1, label %TT, label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: T
[debug] === 이게 branch instruction terminator:   br i1 %cond1, label %TT, label %exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 TT
[debug] ** BBlist에서 이름 같은 BB 찾음: TT
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ entry
[debug] +++++++ T
[debug] +++++++ F
[debug] +++++++ TT
[debug] +++++++ exit
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond2, label %FT, label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: F
[debug] === 이게 branch instruction terminator:   br i1 %cond2, label %FT, label %exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 FT
[debug] ** BBlist에서 이름 같은 BB 찾음: FT
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ entry
[debug] +++++++ T
[debug] +++++++ F
[debug] +++++++ TT
[debug] +++++++ exit
[debug] +++++++ FT
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond3, label %TTT, label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: TT
[debug] === 이게 branch instruction terminator:   br i1 %cond3, label %TTT, label %exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 TTT
[debug] ** BBlist에서 이름 같은 BB 찾음: TTT
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ entry
[debug] +++++++ T
[debug] +++++++ F
[debug] +++++++ TT
[debug] +++++++ exit
[debug] +++++++ FT
[debug] +++++++ TTT
[debug] <<<이건 그냥 inst만 받은거>>>:   ret i32 0

이게 ret이 나와야 하는데ret
오잉 여기 안 들어와??
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond5, label %FTT, label %FTF_FTTT

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: FT
[debug] === 이게 branch instruction terminator:   br i1 %cond5, label %FTT, label %FTF_FTTT

[debug] === successor 갯수: 2
이거 타입이 뭐임 FTT
[debug] ** BBlist에서 이름 같은 BB 찾음: FTT
[debug] ** BBlist에서 이름 같은 BB 찾음: FTF_FTTT
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ entry
[debug] +++++++ T
[debug] +++++++ F
[debug] +++++++ TT
[debug] +++++++ exit
[debug] +++++++ FT
[debug] +++++++ TTT
[debug] +++++++ FTT
[debug] +++++++ FTF_FTTT
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond7, label %TTTT, label %TTTF

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: TTT
[debug] === 이게 branch instruction terminator:   br i1 %cond7, label %TTTT, label %TTTF

[debug] === successor 갯수: 2
이거 타입이 뭐임 TTTT
[debug] ** BBlist에서 이름 같은 BB 찾음: TTTT
[debug] ** BBlist에서 이름 같은 BB 찾음: TTTF
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ entry
[debug] +++++++ T
[debug] +++++++ F
[debug] +++++++ TT
[debug] +++++++ exit
[debug] +++++++ FT
[debug] +++++++ TTT
[debug] +++++++ FTT
[debug] +++++++ FTF_FTTT
[debug] +++++++ TTTT
[debug] +++++++ TTTF
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond6, label %FTF_FTTT, label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: FTT
[debug] === 이게 branch instruction terminator:   br i1 %cond6, label %FTF_FTTT, label %exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 FTF_FTTT
[debug] ** BBlist에서 이름 같은 BB 찾음: FTF_FTTT
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ entry
[debug] +++++++ T
[debug] +++++++ F
[debug] +++++++ TT
[debug] +++++++ exit
[debug] +++++++ FT
[debug] +++++++ TTT
[debug] +++++++ FTT
[debug] +++++++ FTF_FTTT
[debug] +++++++ TTTT
[debug] +++++++ TTTF
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: FTF_FTTT
[debug] === 이게 branch instruction terminator:   br label %exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 exit
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ entry
[debug] +++++++ T
[debug] +++++++ F
[debug] +++++++ TT
[debug] +++++++ exit
[debug] +++++++ FT
[debug] +++++++ TTT
[debug] +++++++ FTT
[debug] +++++++ FTF_FTTT
[debug] +++++++ TTTT
[debug] +++++++ TTTF
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: TTTT
[debug] === 이게 branch instruction terminator:   br label %exit

[debug] === successor 갯수: 1
이거 타입이 뭐임 exit
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ entry
[debug] +++++++ T
[debug] +++++++ F
[debug] +++++++ TT
[debug] +++++++ exit
[debug] +++++++ FT
[debug] +++++++ TTT
[debug] +++++++ FTT
[debug] +++++++ FTF_FTTT
[debug] +++++++ TTTT
[debug] +++++++ TTTF
[debug]        this is value(inst):   %apple = add i32 %buy, %hold
[debug]              inst name:apple
[debug]        this is value(inst):   %hyundai = mul i32 %zonber, %tothemoon
[debug]              inst name:hyundai
[debug]        this is value(inst):   %cond0 = icmp eq i32 %apple, %samsung
[debug]              inst name:cond0

[debug] ****** I found compare inst!:   %cond0 = icmp eq i32 %apple, %samsung

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %apple = add i32 %buy, %hold
[debug] Op0.getname(): apple
[debug] Op1: i32 %samsung
[debug] Op1.getname(): samsung
[debug]--  %apple = add i32 %buy, %hold is argv[-1]
[debug]--i32 %samsung is argv[4]

[debug]  ** '  %apple = add i32 %buy, %hold' should be replaced by 'i32 %samsung'


[debug] ** 4. find condUser:   br i1 %cond0, label %T, label %F
[debug] num of operands: 3
[debug] ---operand0: cond0
[debug] ---operand1: F
[debug] ---operand2: T
[debug] >>> 여기로 뛸거야 >>> T
[debug] ** 5. loserUsers:   %5 = call i32 @f(i32 %KAL, i32 %apple, i32 %samsung, i32 %kia, i32 %kakao, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryentry,T) dominates TTTT!!!!!!!

[debug] ** 5. loserUsers:   %cond1 = icmp eq i32 %apple, %kia

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryentry,T) dominates T!!!!!!!

[debug] ** 5. loserUsers:   %kia = add i32 %apple, %kakao

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryentry,T) dominates T!!!!!!!

[debug] ** 5. loserUsers:   %kakao = add i32 %samsung, %apple

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryentry,T) dominates T!!!!!!!

[debug] ** 5. loserUsers:   %4 = call i32 @f(i32 %samsung, i32 %apple, i32 %hanmi, i32 %noksipja, i32 %hugel, i32 %hyundai)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug] ** 5. loserUsers:   %naver = add i32 %apple, %noksipja

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug] ** 5. loserUsers:   %3 = call i32 @f(i32 %noksipja, i32 %apple, i32 %hugel, i32 %samsung, i32 %tothemoon, i32 %hanmi)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug] ** 5. loserUsers:   %hanmi = sub i32 %samsung, %apple

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug] ** 5. loserUsers:   %2 = call i32 @f(i32 %apple, i32 %samsung, i32 %kia, i32 %kakao, i32 %KAL, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryentry,T) dominates TTT!!!!!!!

[debug] ** 5. loserUsers:   %shinsegye = sub i32 %samsung, %apple

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryentry,T) dominates TT!!!!!!!

[debug] ** 5. loserUsers:   %1 = call i32 @f(i32 %samsung, i32 %apple, i32 %hyundai, i32 %sell, i32 %zonber, i32 %tothemoon)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug] ** 5. loserUsers:   %0 = call i32 @f(i32 %kakao, i32 %apple, i32 %samsung, i32 %kia, i32 %KAL, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryentry,T) dominates TTTF!!!!!!!

[debug] ** 5. loserUsers:   %cond0 = icmp eq i32 %apple, %samsung

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: T
[debug] successor[1]: F
[debug]        this is value(inst):   br i1 %cond0, label %T, label %F
[debug]              inst name:
[debug]        this is value(inst):   %kakao = add i32 %samsung, %samsung
[debug]              inst name:kakao
[debug]        this is value(inst):   %kia = add i32 %samsung, %kakao
[debug]              inst name:kia
[debug]        this is value(inst):   %cond1 = icmp eq i32 %samsung, %kia
[debug]              inst name:cond1

[debug] ****** I found compare inst!:   %cond1 = icmp eq i32 %samsung, %kia

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0: i32 %samsung
[debug] Op0.getname(): samsung
[debug] Op1:   %kia = add i32 %samsung, %kakao
[debug] Op1.getname(): kia
[debug]--i32 %samsung is argv[4]
[debug]--  %kia = add i32 %samsung, %kakao is argv[-1]

[debug]  ** '  %kia = add i32 %samsung, %kakao' should be replaced by 'i32 %samsung'


[debug] ** 4. find condUser:   br i1 %cond1, label %TT, label %exit
[debug] num of operands: 3
[debug] ---operand0: cond1
[debug] ---operand1: exit
[debug] ---operand2: TT
[debug] >>> 여기로 뛸거야 >>> TT
[debug] ** 5. loserUsers:   %5 = call i32 @f(i32 %KAL, i32 %samsung, i32 %samsung, i32 %kia, i32 %kakao, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryT,TT) dominates TTTT!!!!!!!

[debug] ** 5. loserUsers:   %cond1 = icmp eq i32 %samsung, %kia

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %0 = call i32 @f(i32 %kakao, i32 %samsung, i32 %samsung, i32 %kia, i32 %KAL, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryT,TT) dominates TTTF!!!!!!!

[debug] ** 5. loserUsers:   %KAL = add i32 %kakao, %kia

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryT,TT) dominates TT!!!!!!!

[debug] ** 5. loserUsers:   %2 = call i32 @f(i32 %samsung, i32 %samsung, i32 %kia, i32 %kakao, i32 %KAL, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryT,TT) dominates TTT!!!!!!!

[debug] ** 5. loserUsers:   %cond7 = icmp eq i32 %KAL, %kia

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryT,TT) dominates TTT!!!!!!!

[debug]        this is value(inst):   br i1 %cond1, label %TT, label %exit
[debug]              inst name:
[debug]        this is value(inst):   %hanmi = sub i32 %samsung, %apple
[debug]              inst name:hanmi
[debug]        this is value(inst):   %noksipja = mul i32 %sell, %zonber
[debug]              inst name:noksipja
[debug]        this is value(inst):   %cond2 = icmp eq i32 %noksipja, %hanmi
[debug]              inst name:cond2

[debug] ****** I found compare inst!:   %cond2 = icmp eq i32 %noksipja, %hanmi

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %noksipja = mul i32 %sell, %zonber
[debug] Op0.getname(): noksipja
[debug] Op1:   %hanmi = sub i32 %samsung, %apple
[debug] Op1.getname(): hanmi
[debug]--  %noksipja = mul i32 %sell, %zonber is argv[-1]
[debug]--  %hanmi = sub i32 %samsung, %apple is argv[-1]

[debug]--  %noksipja = mul i32 %sell, %zonber is inst[9]
[debug]--  %hanmi = sub i32 %samsung, %apple is inst[8]

[debug]  ** '  %noksipja = mul i32 %sell, %zonber' should be replaced by '  %hanmi = sub i32 %samsung, %apple'


[debug] ** 4. find condUser:   br i1 %cond2, label %FT, label %exit
[debug] num of operands: 3
[debug] ---operand0: cond2
[debug] ---operand1: exit
[debug] ---operand2: FT
[debug] >>> 여기로 뛸거야 >>> FT
[debug] ** 5. loserUsers:   %4 = call i32 @f(i32 %samsung, i32 %apple, i32 %hanmi, i32 %noksipja, i32 %hugel, i32 %hyundai)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryF,FT) dominates FTT!!!!!!!

[debug] ** 5. loserUsers:   %cond5 = icmp eq i32 %hyundai, %noksipja

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryF,FT) dominates FT!!!!!!!

[debug] ** 5. loserUsers:   %naver = add i32 %apple, %noksipja

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryF,FT) dominates FT!!!!!!!

[debug] ** 5. loserUsers:   %3 = call i32 @f(i32 %noksipja, i32 %apple, i32 %hugel, i32 %samsung, i32 %tothemoon, i32 %hanmi)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryF,FT) dominates FTF_FTTT!!!!!!!

[debug] ** 5. loserUsers:   %cond2 = icmp eq i32 %noksipja, %hanmi

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FT
[debug] successor[1]: exit
[debug]        this is value(inst):   br i1 %cond2, label %FT, label %exit
[debug]              inst name:
[debug]        this is value(inst):   %KAL = add i32 %kakao, %samsung
[debug]              inst name:KAL
[debug]        this is value(inst):   %shinsegye = sub i32 %samsung, %samsung
[debug]              inst name:shinsegye
[debug]        this is value(inst):   %cond3 = icmp eq i32 %zonber, %samsung
[debug]              inst name:cond3

[debug] ****** I found compare inst!:   %cond3 = icmp eq i32 %zonber, %samsung

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0: i32 %zonber
[debug] Op0.getname(): zonber
[debug] Op1: i32 %samsung
[debug] Op1.getname(): samsung
[debug]--i32 %zonber is argv[0]
[debug]--i32 %samsung is argv[4]

[debug]  ** 'i32 %samsung' should be replaced by 'i32 %zonber'


[debug] ** 4. find condUser:   br i1 %cond3, label %TTT, label %exit
[debug] num of operands: 3
[debug] ---operand0: cond3
[debug] ---operand1: exit
[debug] ---operand2: TTT
[debug] >>> 여기로 뛸거야 >>> TTT
[debug] ** 5. loserUsers:   %cond7 = icmp eq i32 %KAL, %samsung

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryTT,TTT) dominates TTT!!!!!!!

[debug] ** 5. loserUsers:   %2 = call i32 @f(i32 %samsung, i32 %samsung, i32 %samsung, i32 %kakao, i32 %KAL, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryTT,TTT) dominates TTT!!!!!!!

[debug] ** 5. loserUsers:   %KAL = add i32 %kakao, %samsung

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %0 = call i32 @f(i32 %kakao, i32 %samsung, i32 %samsung, i32 %samsung, i32 %KAL, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryTT,TTT) dominates TTTF!!!!!!!

[debug] ** 5. loserUsers:   %5 = call i32 @f(i32 %KAL, i32 %samsung, i32 %samsung, i32 %samsung, i32 %kakao, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryTT,TTT) dominates TTTT!!!!!!!

[debug] ** 5. loserUsers:   %0 = call i32 @f(i32 %kakao, i32 %samsung, i32 %samsung, i32 %zonber, i32 %KAL, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryTT,TTT) dominates TTTF!!!!!!!

[debug] ** 5. loserUsers:   %shinsegye = sub i32 %samsung, %samsung

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %2 = call i32 @f(i32 %samsung, i32 %samsung, i32 %zonber, i32 %kakao, i32 %KAL, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryTT,TTT) dominates TTT!!!!!!!

[debug] ** 5. loserUsers:   %kakao = add i32 %samsung, %samsung

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %kia = add i32 %samsung, %kakao

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %cond1 = icmp eq i32 %samsung, %kia

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %5 = call i32 @f(i32 %KAL, i32 %samsung, i32 %samsung, i32 %zonber, i32 %kakao, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryTT,TTT) dominates TTTT!!!!!!!

[debug] ** 5. loserUsers:   %5 = call i32 @f(i32 %KAL, i32 %zonber, i32 %samsung, i32 %zonber, i32 %kakao, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryTT,TTT) dominates TTTT!!!!!!!

[debug] ** 5. loserUsers:   %kakao = add i32 %samsung, %samsung

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %4 = call i32 @f(i32 %samsung, i32 %apple, i32 %hanmi, i32 %hanmi, i32 %hugel, i32 %hyundai)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %hugel = mul i32 %samsung, %hanmi

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %3 = call i32 @f(i32 %hanmi, i32 %apple, i32 %hugel, i32 %samsung, i32 %tothemoon, i32 %hanmi)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %hanmi = sub i32 %samsung, %apple

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %2 = call i32 @f(i32 %zonber, i32 %samsung, i32 %zonber, i32 %kakao, i32 %KAL, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryTT,TTT) dominates TTT!!!!!!!

[debug] ** 5. loserUsers:   %cond3 = icmp eq i32 %zonber, %samsung

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %shinsegye = sub i32 %samsung, %samsung

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %1 = call i32 @f(i32 %samsung, i32 %apple, i32 %hyundai, i32 %sell, i32 %zonber, i32 %tothemoon)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %0 = call i32 @f(i32 %kakao, i32 %zonber, i32 %samsung, i32 %zonber, i32 %KAL, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryTT,TTT) dominates TTTF!!!!!!!

[debug] ** 5. loserUsers:   %cond0 = icmp eq i32 %apple, %samsung

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTT
[debug] successor[1]: exit
[debug]        this is value(inst):   br i1 %cond3, label %TTT, label %exit
[debug]              inst name:
[debug]        this is value(inst):   %1 = call i32 @f(i32 %samsung, i32 %apple, i32 %hyundai, i32 %sell, i32 %zonber, i32 %tothemoon)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 0
[debug]              inst name:
[debug]        this is value(inst):   %hugel = mul i32 %samsung, %hanmi
[debug]              inst name:hugel
[debug]        this is value(inst):   %naver = add i32 %apple, %hanmi
[debug]              inst name:naver
[debug]        this is value(inst):   %cond5 = icmp eq i32 %hyundai, %hanmi
[debug]              inst name:cond5

[debug] ****** I found compare inst!:   %cond5 = icmp eq i32 %hyundai, %hanmi

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %hyundai = mul i32 %zonber, %tothemoon
[debug] Op0.getname(): hyundai
[debug] Op1:   %hanmi = sub i32 %samsung, %apple
[debug] Op1.getname(): hanmi
[debug]--  %hyundai = mul i32 %zonber, %tothemoon is argv[-1]
[debug]--  %hanmi = sub i32 %samsung, %apple is argv[-1]

[debug]--  %hyundai = mul i32 %zonber, %tothemoon is inst[1]
[debug]--  %hanmi = sub i32 %samsung, %apple is inst[8]

[debug]  ** '  %hanmi = sub i32 %samsung, %apple' should be replaced by '  %hyundai = mul i32 %zonber, %tothemoon'


[debug] ** 4. find condUser:   br i1 %cond5, label %FTT, label %FTF_FTTT
[debug] num of operands: 3
[debug] ---operand0: cond5
[debug] ---operand1: FTF_FTTT
[debug] ---operand2: FTT
[debug] >>> 여기로 뛸거야 >>> FTT
[debug] ** 5. loserUsers:   %3 = call i32 @f(i32 %hanmi, i32 %apple, i32 %hugel, i32 %samsung, i32 %tothemoon, i32 %hanmi)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FTT
[debug] successor[1]: FTF_FTTT
[debug] ** 5. loserUsers:   %naver = add i32 %apple, %hanmi

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FTT
[debug] successor[1]: FTF_FTTT
[debug] ** 5. loserUsers:   %cond5 = icmp eq i32 %hyundai, %hanmi

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FTT
[debug] successor[1]: FTF_FTTT
[debug] ** 5. loserUsers:   %4 = call i32 @f(i32 %samsung, i32 %apple, i32 %hanmi, i32 %hanmi, i32 %hugel, i32 %hyundai)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FTT
[debug] successor[1]: FTF_FTTT
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryFT,FTT) dominates FTT!!!!!!!

[debug] ** 5. loserUsers:   %cond6 = icmp eq i32 %hugel, %hanmi

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FTT
[debug] successor[1]: FTF_FTTT
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryFT,FTT) dominates FTT!!!!!!!

[debug] ** 5. loserUsers:   %4 = call i32 @f(i32 %samsung, i32 %apple, i32 %hanmi, i32 %hyundai, i32 %hugel, i32 %hyundai)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FTT
[debug] successor[1]: FTF_FTTT
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryFT,FTT) dominates FTT!!!!!!!

[debug] ** 5. loserUsers:   %hugel = mul i32 %samsung, %hanmi

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FTT
[debug] successor[1]: FTF_FTTT
[debug] ** 5. loserUsers:   %3 = call i32 @f(i32 %hanmi, i32 %apple, i32 %hugel, i32 %samsung, i32 %tothemoon, i32 %hanmi)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FTT
[debug] successor[1]: FTF_FTTT
[debug] ** 5. loserUsers:   %cond2 = icmp eq i32 %noksipja, %hanmi

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FTT
[debug] successor[1]: FTF_FTTT
[debug]        this is value(inst):   br i1 %cond5, label %FTT, label %FTF_FTTT
[debug]              inst name:
[debug]        this is value(inst):   %2 = call i32 @f(i32 %zonber, i32 %zonber, i32 %zonber, i32 %kakao, i32 %KAL, i32 %shinsegye)
[debug]              inst name:
[debug]        this is value(inst):   %cond7 = icmp eq i32 %KAL, %zonber
[debug]              inst name:cond7

[debug] ****** I found compare inst!:   %cond7 = icmp eq i32 %KAL, %zonber

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %KAL = add i32 %kakao, %samsung
[debug] Op0.getname(): KAL
[debug] Op1: i32 %zonber
[debug] Op1.getname(): zonber
[debug]--  %KAL = add i32 %kakao, %samsung is argv[-1]
[debug]--i32 %zonber is argv[0]

[debug]  ** '  %KAL = add i32 %kakao, %samsung' should be replaced by 'i32 %zonber'


[debug] ** 4. find condUser:   br i1 %cond7, label %TTTT, label %TTTF
[debug] num of operands: 3
[debug] ---operand0: cond7
[debug] ---operand1: TTTF
[debug] ---operand2: TTTT
[debug] >>> 여기로 뛸거야 >>> TTTT
[debug] ** 5. loserUsers:   %5 = call i32 @f(i32 %KAL, i32 %zonber, i32 %zonber, i32 %zonber, i32 %kakao, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTTT
[debug] successor[1]: TTTF
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entryTTT,TTTT) dominates TTTT!!!!!!!

[debug] ** 5. loserUsers:   %cond7 = icmp eq i32 %KAL, %zonber

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTTT
[debug] successor[1]: TTTF
[debug] ** 5. loserUsers:   %2 = call i32 @f(i32 %zonber, i32 %zonber, i32 %zonber, i32 %kakao, i32 %KAL, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTTT
[debug] successor[1]: TTTF
[debug] ** 5. loserUsers:   %0 = call i32 @f(i32 %kakao, i32 %zonber, i32 %zonber, i32 %zonber, i32 %KAL, i32 %shinsegye)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: TTTT
[debug] successor[1]: TTTF
[debug]        this is value(inst):   br i1 %cond7, label %TTTT, label %TTTF
[debug]              inst name:
[debug]        this is value(inst):   %4 = call i32 @f(i32 %samsung, i32 %apple, i32 %hyundai, i32 %hyundai, i32 %hugel, i32 %hyundai)
[debug]              inst name:
[debug]        this is value(inst):   %cond6 = icmp eq i32 %hugel, %hyundai
[debug]              inst name:cond6

[debug] ****** I found compare inst!:   %cond6 = icmp eq i32 %hugel, %hyundai

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %hugel = mul i32 %samsung, %hanmi
[debug] Op0.getname(): hugel
[debug] Op1:   %hyundai = mul i32 %zonber, %tothemoon
[debug] Op1.getname(): hyundai
[debug]--  %hugel = mul i32 %samsung, %hanmi is argv[-1]
[debug]--  %hyundai = mul i32 %zonber, %tothemoon is argv[-1]

[debug]--  %hugel = mul i32 %samsung, %hanmi is inst[18]
[debug]--  %hyundai = mul i32 %zonber, %tothemoon is inst[1]

[debug]  ** '  %hugel = mul i32 %samsung, %hanmi' should be replaced by '  %hyundai = mul i32 %zonber, %tothemoon'


[debug] ** 4. find condUser:   br i1 %cond6, label %FTF_FTTT, label %exit
[debug] num of operands: 3
[debug] ---operand0: cond6
[debug] ---operand1: exit
[debug] ---operand2: FTF_FTTT
[debug] >>> 여기로 뛸거야 >>> FTF_FTTT
[debug] ** 5. loserUsers:   %cond6 = icmp eq i32 %hugel, %hyundai

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FTF_FTTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %4 = call i32 @f(i32 %samsung, i32 %apple, i32 %hyundai, i32 %hyundai, i32 %hugel, i32 %hyundai)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FTF_FTTT
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %3 = call i32 @f(i32 %hanmi, i32 %apple, i32 %hugel, i32 %samsung, i32 %tothemoon, i32 %hanmi)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: FTF_FTTT
[debug] successor[1]: exit
[debug]        this is value(inst):   br i1 %cond6, label %FTF_FTTT, label %exit
[debug]              inst name:
[debug]        this is value(inst):   %3 = call i32 @f(i32 %hanmi, i32 %apple, i32 %hugel, i32 %samsung, i32 %tothemoon, i32 %hanmi)
[debug]              inst name:
[debug]        this is value(inst):   br label %exit
[debug]              inst name:
[debug]        this is value(inst):   %5 = call i32 @f(i32 %zonber, i32 %zonber, i32 %zonber, i32 %zonber, i32 %kakao, i32 %shinsegye)
[debug]              inst name:
[debug]        this is value(inst):   br label %exit
[debug]              inst name:
[debug]        this is value(inst):   %0 = call i32 @f(i32 %kakao, i32 %zonber, i32 %zonber, i32 %zonber, i32 %KAL, i32 %shinsegye)
[debug]              inst name:
[debug]        this is value(inst):   br label %exit
[debug]              inst name:
== mycheck/check3.ll ==
[debug] basic block list size : 5
[debug] <<<이건 그냥 inst만 받은거>>>:   br label %true

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: 
[debug] === 이게 branch instruction terminator:   br label %true

[debug] === successor 갯수: 1
이거 타입이 뭐임 true
[debug] ** BBlist에서 이름 같은 BB 찾음: true
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ true
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond1, label %true1, label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: true
[debug] === 이게 branch instruction terminator:   br i1 %cond1, label %true1, label %exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 true1
[debug] ** BBlist에서 이름 같은 BB 찾음: true1
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ true
[debug] +++++++ true1
[debug] +++++++ exit
[debug] <<<이건 그냥 inst만 받은거>>>:   br i1 %cond2, label %true2, label %exit

이게 ret이 나와야 하는데br
이게 마지막 BB의 이름이라는 것: true1
[debug] === 이게 branch instruction terminator:   br i1 %cond2, label %true2, label %exit

[debug] === successor 갯수: 2
이거 타입이 뭐임 true2
[debug] ** BBlist에서 이름 같은 BB 찾음: true2
[debug] ** BBlist에서 이름 같은 BB 찾음: exit
[debug] ++++++ BFS elements ++++++ 
[debug] +++++++ 
[debug] +++++++ true
[debug] +++++++ true1
[debug] +++++++ exit
[debug] +++++++ true2
[debug] <<<이건 그냥 inst만 받은거>>>:   ret i32 0

이게 ret이 나와야 하는데ret
오잉 여기 안 들어와??
[debug]        this is value(inst):   %cond = icmp eq i32 %king, %queen
[debug]              inst name:cond

[debug] ****** I found compare inst!:   %cond = icmp eq i32 %king, %queen

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0: i32 %king
[debug] Op0.getname(): king
[debug] Op1: i32 %queen
[debug] Op1.getname(): queen
[debug]--i32 %king is argv[1]
[debug]--i32 %queen is argv[2]

[debug]  ** 'i32 %queen' should be replaced by 'i32 %king'

[debug]        this is value(inst):   br label %true
[debug]              inst name:
[debug]        this is value(inst):   %a = add i32 %king, %queen
[debug]              inst name:a
[debug]        this is value(inst):   %b = add i32 %joker, %king
[debug]              inst name:b
[debug]        this is value(inst):   %cond1 = icmp eq i32 %b, %a
[debug]              inst name:cond1

[debug] ****** I found compare inst!:   %cond1 = icmp eq i32 %b, %a

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %b = add i32 %joker, %king
[debug] Op0.getname(): b
[debug] Op1:   %a = add i32 %king, %queen
[debug] Op1.getname(): a
[debug]--  %b = add i32 %joker, %king is argv[-1]
[debug]--  %a = add i32 %king, %queen is argv[-1]

[debug]--  %b = add i32 %joker, %king is inst[3]
[debug]--  %a = add i32 %king, %queen is inst[2]

[debug]  ** '  %b = add i32 %joker, %king' should be replaced by '  %a = add i32 %king, %queen'


[debug] ** 4. find condUser:   br i1 %cond1, label %true1, label %exit
[debug] num of operands: 3
[debug] ---operand0: cond1
[debug] ---operand1: exit
[debug] ---operand2: true1
[debug] >>> 여기로 뛸거야 >>> true1
[debug] ** 5. loserUsers:   %1 = call i32 @f(i32 %joker, i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %g = add i32 %b, %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrytrue,true1) dominates true2!!!!!!!

[debug] ** 5. loserUsers:   %cond2 = icmp eq i32 %b, %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrytrue,true1) dominates true1!!!!!!!

[debug] ** 5. loserUsers:   %d = add i32 %c, %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrytrue,true1) dominates true1!!!!!!!

[debug] ** 5. loserUsers:   %c = add i32 %a, %b

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrytrue,true1) dominates true1!!!!!!!

[debug] ** 5. loserUsers:   %cond1 = icmp eq i32 %b, %a

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true1
[debug] successor[1]: exit
[debug]        this is value(inst):   br i1 %cond1, label %true1, label %exit
[debug]              inst name:
[debug]        this is value(inst):   %c = add i32 %a, %a
[debug]              inst name:c
[debug]        this is value(inst):   %d = add i32 %c, %a
[debug]              inst name:d
[debug]        this is value(inst):   %cond2 = icmp eq i32 %a, %c
[debug]              inst name:cond2

[debug] ****** I found compare inst!:   %cond2 = icmp eq i32 %a, %c

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %a = add i32 %king, %queen
[debug] Op0.getname(): a
[debug] Op1:   %c = add i32 %a, %a
[debug] Op1.getname(): c
[debug]--  %a = add i32 %king, %queen is argv[-1]
[debug]--  %c = add i32 %a, %a is argv[-1]

[debug]--  %a = add i32 %king, %queen is inst[2]
[debug]--  %c = add i32 %a, %a is inst[6]

[debug]  ** '  %c = add i32 %a, %a' should be replaced by '  %a = add i32 %king, %queen'


[debug] ** 4. find condUser:   br i1 %cond2, label %true2, label %exit
[debug] num of operands: 3
[debug] ---operand0: cond2
[debug] ---operand1: exit
[debug] ---operand2: true2
[debug] >>> 여기로 뛸거야 >>> true2
[debug] ** 5. loserUsers:   %g = add i32 %a, %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true2
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrytrue1,true2) dominates true2!!!!!!!

[debug] ** 5. loserUsers:   %e = add i32 %c, %d

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true2
[debug] successor[1]: exit
[debug] 이 문장 나오면 바뀌는거다.
***** Edge (entrytrue1,true2) dominates true2!!!!!!!

[debug] ** 5. loserUsers:   %cond2 = icmp eq i32 %a, %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true2
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %d = add i32 %c, %a

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true2
[debug] successor[1]: exit
[debug]        this is value(inst):   br i1 %cond2, label %true2, label %exit
[debug]              inst name:
[debug]        this is value(inst):   %1 = call i32 @f(i32 %joker, i32 %a, i32 %b)
[debug]              inst name:
[debug]        this is value(inst):   ret i32 0
[debug]              inst name:
[debug]        this is value(inst):   %e = add i32 %a, %d
[debug]              inst name:e
[debug]        this is value(inst):   %g = add i32 %a, %a
[debug]              inst name:g
[debug]        this is value(inst):   %h = add i32 %g, %e
[debug]              inst name:h
[debug]        this is value(inst):   %cond3 = icmp eq i32 %a, %joker
[debug]              inst name:cond3

[debug] ****** I found compare inst!:   %cond3 = icmp eq i32 %a, %joker

[debug] ****** icmp일 때에만 이 문장 나와야 함
 [debug]** 3. decideWinnerLoser
[debug] Op0:   %a = add i32 %king, %queen
[debug] Op0.getname(): a
[debug] Op1: i32 %joker
[debug] Op1.getname(): joker
[debug]--  %a = add i32 %king, %queen is argv[-1]
[debug]--i32 %joker is argv[0]

[debug]  ** '  %a = add i32 %king, %queen' should be replaced by 'i32 %joker'


[debug] ** 4. find condUser:   br i1 %cond3, label %true, label %exit
[debug] num of operands: 3
[debug] ---operand0: cond3
[debug] ---operand1: exit
[debug] ---operand2: true
[debug] >>> 여기로 뛸거야 >>> true
[debug] ** 5. loserUsers:   %e = add i32 %a, %d

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %g = add i32 %a, %a

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %c = add i32 %a, %a

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %d = add i32 %c, %a

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %cond2 = icmp eq i32 %a, %c

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %g = add i32 %a, %a

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %1 = call i32 @f(i32 %joker, i32 %a, i32 %b)

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %cond3 = icmp eq i32 %a, %joker

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %c = add i32 %a, %a

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug] ** 5. loserUsers:   %cond1 = icmp eq i32 %b, %a

[debug] ** 6. checkBBEdominance

[debug] 일단 실험해보자 : successor 갯수: 2
[debug] successor[0]: true
[debug] successor[1]: exit
[debug]        this is value(inst):   br i1 %cond3, label %true, label %exit
[debug]              inst name:
MyCheck passed: 3 / 3
