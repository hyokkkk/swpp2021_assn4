     <argument run 시작>: i1 %cond
        this is value:i1 %cond
          - normal user:  br i1 %cond, label %undef_zone, label %normal_zone

     <argument run 시작>: i32 %arg
        this is value:i32 %arg
          - normal user:  %x2 = add i32 %arg, 0

          - undef_zone usr:  %x1 = add i32 %arg, 0

<BB label>: 
     <Instruction run 시작>:   %inst = add i32 1, 1
        this is value:  %inst = add i32 1, 1
          - normal user:  ret i32 %inst

          - undef_zone usr:  ret i32 %inst

     <Instruction run 시작>:   br i1 %cond, label %undef_zone, label %normal_zone
        this is value:  br i1 %cond, label %undef_zone, label %normal_zone
       !!! there is no user using this value.
<BB label>: undef_zone
     <Instruction run 시작>:   %x1 = add i32 undef, 0
        this is value:  %x1 = add i32 undef, 0
       !!! there is no user using this value.
     <Instruction run 시작>:   ret i32 undef
        this is value:  ret i32 undef
       !!! there is no user using this value.
<BB label>: normal_zone
     <Instruction run 시작>:   %x2 = add i32 %arg, 0
        this is value:  %x2 = add i32 %arg, 0
       !!! there is no user using this value.
     <Instruction run 시작>:   ret i32 %inst
        this is value:  ret i32 %inst
       !!! there is no user using this value.
; ModuleID = 'fillundef.ll'
source_filename = "fillundef.ll"

define i32 @f(i1 %cond, i32 %arg) {
  %inst = add i32 1, 1
  br i1 %cond, label %undef_zone, label %normal_zone

undef_zone:                                       ; preds = %0
  %x1 = add i32 undef, 0
  ret i32 undef

normal_zone:                                      ; preds = %0
  %x2 = add i32 %arg, 0
  ret i32 %inst
}
----- run instmatch with instmatch.ll -----
Found i32 %a + i32 %b - i32 %b!
	Can be optimized to i32 %a
Found i32 %a == i32 %a!
	Can be optimized to true
Found i32 %a * 0!
	Can be optimized to zero
