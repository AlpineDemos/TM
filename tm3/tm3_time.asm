 FC1   db ?
 FC2   db ?
 SplitPos     dw ?
 SplitLoop    dw ?
 OldTimer     dd ?
 OldRealTimer dd ?
 Old_Stub     db 21 dup(?)
 TimerCalled  dd O DummyTimer
 SYNC_COUNT   dd ?

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     MACRO SetBorder Num
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  xor al,al
  mov dx,3c8h
  out dx,al
  inc dx
  mov al,Num
  out dx,al
  out dx,al
  out dx,al
 ENDM

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC WaitVRetrace
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  cli
  mov dx,3dah
  @1:
   in al,dx
   test al,08
  jz @1
  @2:
   in al,dx
   test al,08
  jnz @2
  sti
  Ret
 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC WaitNRetrace
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  mov dx,3dah
  @3:
   in al,dx
   test al,08
  jnz @3
  @4:
   in al,dx
   test al,08
  jz @4
  Ret
 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC SetTimerHandler ; D:all
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  pushad
  cli
   mov bl,0
   Call [_GetIrqVect]
   mov [OldTimer],edx
   db 0BAh
   OfsTimerIRQ dd O Timer
   Call [_SetIrqVect]
   mov edi,o Old_stub
   call _rmpmirqset
   mov [OldRealTimer],eax
  sti
  popad
  Ret
 EndP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC NewTimerFreq  ; D:all  N:EBX = FREQ
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  pushad
  cli
   mov al,00110000b
   out 43h,al
   xor edx,edx
   mov eax,1234DCh
   div ebx
   mov [FC1],al
   out 40h,al
   mov al,ah
   mov [FC2],al
   out 40h,al
  sti
  popad
  Ret
 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC DirectTimerFreq  ; D:all  N:EAX = DIRECTCOUNT
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  pushad
  cli
   mov al,00110000b
   out 43h,al
   out 40h,al
   mov al,ah
   out 40h,al
  sti
  popad
  Ret
 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC ResetTimer
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  pushad
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
  popad
  Ret
 ENDP


;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC DUMMYTIMER
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  RET
 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC SYNCIRQ
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  pushad
  push ds
  mov dx,[cs:_SelData]
  mov ds,dx
  inc [SYNC_COUNT]
  mov al,20h
  out 20h,al
  pop ds
  popad
  IRetD
 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC TIMER
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  pushad
  push ds es
  mov dx,[cs:_SelData]
  mov ds,dx
  mov es,dx
  Call WaitVRetrace
  @NoVR:
  mov al,[FC1]   ; RESET TIMER!
  out 40h,al
  mov al,[FC2]
  out 40h,al
  mov al,20h
  out 20h,al
  CALL [TimerCalled]
  cmp [SBVer],0
  jne @NoSilence
   pushfd
   call far TM3_SB_IRQ
  @NoSilence:
  pop es ds
  popad
  IRetD
 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC GETSCREENFREQ
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  mov ebx,120
  mov [OfsTimerIRQ],O SYNCIRQ
  Call SetTimerHandler
  @GSLoop:
   Call WaitVRetrace
   SUB ebx,2
   Call NewTimerFreq
   mov [Sync_Count],0
   Call WaitVRetrace
   cmp [Sync_Count],0
  jne @GSLoop
  Call ResetTimer
  mov [OfsTimerIRQ],O Timer
  mov [TimerCalled],O DummyTimer
  Ret
 ENDP
