; Write your own check here.
; Feel free to add arguments to @f, so its signature becomes @f(i32 %x, ...).
; But, this file should contain one function @f() only.
; FileCheck syntax: https://llvm.org/docs/CommandGuide/FileCheck.html

define i32 @f(i32 %zonber, i32 %buy, i32 %hold, i32 %sell, i32 %samsung, i32 %tothemoon) {
; CHECK-LABEL:  @f(i32 %zonber, i32 %buy, i32 %hold, i32 %sell, i32 %samsung, i32 %tothemoon) {
; CHECK:        entry:
; CHECK-NEXT:     [[APPLE:%.*]] = add i32 [[BUY:%.*]], [[HOLD:%.*]]
; CHECK-NEXT:     [[HYUNDAI:%.*]] = mul i32 [[ZONBER:%.*]], [[TOTHEMOON:%.*]]
; CHECK-NEXT:     [[COND0:%.*]] = icmp eq i32 [[APPLE]], [[SAMSUNG:%.*]]
; CHECK-NEXT:     br i1 [[COND0]], label [[T:%.*]], label [[F:%.*]]
; CHECK:        TTTF:
; CHECK-NEXT:     call i32 @f(i32 [[KAKAO:%.*]], i32 [[ZONBER]], i32 [[ZONBER]], i32 [[ZONBER]], i32 [[KAL:%.*]], i32 [[SHINSEGYE:%.*]])
; CHECK-NEXT:     br label [[EXIT:%.*]]
; CHECK:        exit:
; CHECK-NEXT:     call i32 @f(i32 [[SAMSUNG]], i32 [[APPLE]], i32 [[HYUNDAI]], i32 [[SELL:%.*]], i32 [[ZONBER]], i32 [[TOTHEMOON]])
; CHECK-NEXT:     ret i32 0
; CHECK:        TT:
; CHECK-NEXT:     [[KAL]] = add i32 [[KAKAO]], [[SAMSUNG]]
; CHECK-NEXT:     [[SHINSEGYE]] = sub i32 [[SAMSUNG]], [[SAMSUNG]]
; CHECK-NEXT:     [[COND3:%.*]] = icmp eq i32 [[ZONBER]], [[SAMSUNG]]
; CHECK-NEXT:     br i1 [[COND3]], label [[TTT:%.*]], label [[EXIT]]
; CHECK:        TTT:
; CHECK-NEXT:     call i32 @f(i32 [[ZONBER]], i32 [[ZONBER]], i32 [[ZONBER]], i32 [[KAKAO]], i32 [[KAL]], i32 [[SHINSEGYE]])
; CHECK-NEXT:     [[COND7:%.*]] = icmp eq i32 [[KAL]], [[ZONBER]]
; CHECK-NEXT:     br i1 [[COND7]], label [[TTTT:%.*]], label [[TTTF:%.*]]
; CHECK:        F:
; CHECK-NEXT:     [[HANMI:%.*]] = sub i32 [[SAMSUNG]], [[APPLE]]
; CHECK-NEXT:     [[NOKSIPJA:%.*]] = mul i32 [[SELL:%.*]], [[ZONBER]]
; CHECK-NEXT:     [[COND2:%.*]] = icmp eq i32 [[NOKSIPJA]], [[HANMI]]
; CHECK-NEXT:     br i1 [[COND2]], label [[FT:%.*]], label [[EXIT]]
; CHECK:        FTF_FTTT:
; CHECK-NEXT:     call i32 @f(i32 [[HANMI]], i32 [[APPLE]], i32 [[HUGEL:%.*]], i32 [[SAMSUNG]], i32 [[TOTHEMOON]], i32 [[HANMI]])
; CHECK-NEXT:     br label [[EXIT]]
; CHECK:        FT:
; CHECK-NEXT:     [[HUGEL]] = mul i32 [[SAMSUNG]], [[HANMI]]
; CHECK-NEXT:     [[NAVER:%.*]] = add i32 [[APPLE]], [[HANMI]]
; CHECK-NEXT:     [[COND5:%.*]] = icmp eq i32 [[HYUNDAI]], [[HANMI]]
; CHECK-NEXT:     br i1 [[COND5]], label [[FTT:%.*]], label [[FTF_FTTT:%.*]]
; CHECK:        FTT:
; CHECK-NEXT:     call i32 @f(i32 [[SAMSUNG]], i32 [[APPLE]], i32 [[HYUNDAI]], i32 [[HYUNDAI]], i32 [[HUGEL]], i32 [[HYUNDAI]])
; CHECK-NEXT:     [[COND6:%.*]] = icmp eq i32 [[HUGEL]], [[HYUNDAI]]
; CHECK-NEXT:     br i1 [[COND6]], label [[FTF_FTTT]], label [[EXIT]]
; CHECK:        T:
; CHECK-NEXT:     [[KAKAO]] = add i32 [[SAMSUNG]], [[SAMSUNG]]
; CHECK-NEXT:     [[KIA:%.*]] = add i32 [[SAMSUNG]], [[KAKAO]]
; CHECK-NEXT:     [[COND1:%.*]] = icmp eq i32 [[SAMSUNG]], [[KIA]]
; CHECK-NEXT:     br i1 [[COND1]], label [[TT:%.*]], label [[EXIT]]
; CHECK:        TTTT:
; CHECK-NEXT:     call i32 @f(i32 [[ZONBER]], i32 [[ZONBER]], i32 [[ZONBER]], i32 [[ZONBER]], i32 [[KAKAO]], i32 [[SHINSEGYE]])
; CHECK-NEXT:     br label [[EXIT]]
;
entry:
  %apple = add i32 %buy, %hold
  %hyundai = mul i32 %zonber, %tothemoon
  %cond0 = icmp eq i32 %apple, %samsung
  br i1 %cond0, label %T, label %F

TTTF:
  call i32 @f(i32 %kakao, i32 %apple, i32 %samsung, i32 %kia, i32 %KAL, i32 %shinsegye)
                            ; zon       zon           zon
  br label %exit

exit:
  call i32 @f(i32 %samsung, i32 %apple, i32 %hyundai, i32 %sell, i32 %zonber, i32 %tothemoon)
  ret i32 0

TT:
  %KAL = add i32 %kakao, %kia       ; kia ->sam
  %shinsegye = sub i32 %samsung, %apple ; app -> sam
  %cond3 = icmp eq i32 %zonber, %samsung
  br i1 %cond3, label %TTT, label %exit

TTT:
  call i32 @f(i32 %apple, i32 %samsung, i32 %kia, i32 %kakao, i32 %KAL, i32 %shinsegye)
                ; zon         zon           zon
  %cond7 = icmp eq i32 %KAL, %kia ; kia->zon
  br i1 %cond7, label %TTTT, label %TTTF

F:
  %hanmi = sub i32 %samsung, %apple
  %noksipja = mul i32 %sell, %zonber
  %cond2 = icmp eq i32 %noksipja, %hanmi
  br i1 %cond2, label %FT, label %exit

FTF_FTTT:
  call i32 @f(i32 %noksipja, i32 %apple, i32 %hugel, i32 %samsung, i32 %tothemoon, i32 %hanmi)
                  ;hanmi
  br label %exit

FT:
  %hugel = mul i32 %samsung, %hanmi
  %naver = add i32 %apple, %noksipja          ;nok -> han
  %cond5 = icmp eq i32 %hyundai, %noksipja    ; nok -> han
  br i1 %cond5, label %FTT, label %FTF_FTTT

FTT:
  call i32 @f(i32 %samsung, i32 %apple, i32 %hanmi, i32 %noksipja, i32 %hugel, i32 %hyundai)
              ;   sam           ap     han->hyun       han->hyun       hugel       hyundai
  %cond6 = icmp eq i32 %hugel, %hanmi  ; han->hyun
  br i1 %cond6, label %FTF_FTTT, label %exit

T:
  %kakao = add i32 %samsung, %apple ; app -> sam
  %kia = add i32 %apple, %kakao     ; app -> sam
  %cond1 = icmp eq i32 %apple, %kia ; app ->sam
  br i1 %cond1, label %TT, label %exit

TTTT:
  call i32 @f(i32 %KAL, i32 %apple, i32 %samsung, i32 %kia, i32 %kakao, i32 %shinsegye)
                ; zon       zon         zon           zon
  br label %exit








}
