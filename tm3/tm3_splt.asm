;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
; ЯЯЯЯЯЯЯЯЯЯЫЫЫЫЫЫЬ  ЫЫЫЫЫЫЫЯЫЯЫЫЫЫЫЫЬ  ЯЯЯЯЯЯЯЯЯЯЫЫЫЫЫЫЬ  THE MODULE V3.00б
;           ЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫ Я ЫЫЫЫЫЫЫ          ЯЯЫЫЫЫЫЫЫ   (C) Spring 1997
;           ЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫ   ЫЫЫЫЫЫЫ  ЬЬЬЬЬЬЬЬЬЬЫЫЫЫЫЫЯ  by Syrius / Alpine
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
; SPLIT-SCREEN-EFFECT: DEMO ON USAGE OF TIMER-CONTROLLED VGA-MANIPULATIONS
; DOES ACTUALLY NOT BELONG TO TM3...
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 SplitPos     dw ?
 SplitLoop    dw ?
 OldTimer     dd ?
 OldRealTimer dd ?
 Old_Stub     db 21 dup(?)
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 MACRO SetBorder Num
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
  xor al,al
  mov dx,3c8h
  out dx,al
  inc dx
  mov al,Num
  out dx,al
  out dx,al
  out dx,al
 ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 MACRO WaitVRetrace
 local @1,@2
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
  mov dx,3dah
  @1:
   in al,dx
   test al,08
  jz @1
  @2:
   in al,dx
   test al,08
  jnz @2
 ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 PROC SetTimer
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
  WaitVRetrace
  cli
   mov bl,0
   Call [_GetIrqVect]
   mov [OldTimer],edx
   mov edx, o SCREENIRQ
   Call [_SetIrqVect]
   mov edi,o Old_stub
   call _rmpmirqset
   mov [OldRealTimer],eax
   mov al,00110000b
   out 43h,al
   mov al,0fch
   out 40h,al
   mov al,3eh
   out 40h,al
   sti
  Ret
 EndP

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 PROC ResetTimer
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
  cli
   mov dx,43h
   mov al,36h
   out dx,al
   mov dx,40h
   xor al,al
   out dx,al
   out dx,al
   mov bl,0
   mov eax,[OldRealTimer]
   call _rmpmirqfree
   mov edx,[OldTimer]
   Call [_SetIrqVect]
  sti
  Ret
 ENDP

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 PROC SCREENIRQ
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
  pushad
  push ds
  mov dx,[cs:_SelData]
  mov ds,dx
;  SetBorder 50
  WaitVRetrace
  cmp [SplitLoop],0
  je  @SplitReady
   mov dx,3d4h
   mov ax,[SplitPos]
   shl ax,1
   inc ax
   mov si,ax
   shl ax,4
   mov al,07h
   out dx,ax
   mov ax,si
   mov ah,al
   mov al,18h
   out dx,ax
@ModifySubAdd:
   add [SplitPos],2
   dec [SplitLoop]
  @SplitReady:

;  SetBorder 0
  mov al,0fch
  out 40h,al
  mov al,03eh
  out 40h,al
  mov al,20h
  out 20h,al
  pop ds
  popad
  IRetD
 ENDP


;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 PROC SplitUp
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
  mov [b @ModifySubAdd+2],2Dh
  mov dx,3d4h       ;Bit 9 Split Line auf 0!
  mov al,09h
  out dx,al
  inc dx
  in  al,dx
  and al,191
  out dx,al
  mov dx,3d4h
  mov [SplitLoop],54
  mov [SplitPos], 458
  Call SetTimer
  @SplitL:
   Call TrackWindow
   cmp [SplitLoop],0
  jne @SplitL
  Call ResetTimer
  Ret
 ENDP


;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 PROC SplitDown
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
  mov [b @ModifySubAdd+2],05h
  mov dx,3d4h       ;Bit 9 Split Line auf 0!
  mov al,09h
  out dx,al
  inc dx
  in  al,dx
  and al,191
  out dx,al
  mov dx,3d4h
  mov [SplitLoop],54
  mov [SplitPos], 352
  Call SetTimer
  @SplitLDn:
   Call TrackWindow
   cmp [SplitLoop],0
  jne @SplitLDn
  Call ResetTimer
  Ret
 ENDP
