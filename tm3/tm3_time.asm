 FC1   db ?
 FC2   db ?
 SplitPos     dw ?
 SplitLoop    dw ?
 OldTimer     dd ?
 OldRealTimer dd ?
 Old_Stub     db 21 dup(?)
 TimerCalled  dd O DummyTimer
 SYNC_COUNT   dd ?

;(*������������������������������������������������������������������������*);
     MACRO SetBorder Num
;(*������������������������������������������������������������������������*);
  xor al,al
  mov dx,3c8h
  out dx,al
  inc dx
  mov al,Num
  out dx,al
  out dx,al
  out dx,al
 ENDM

;(*������������������������������������������������������������������������*);
     PROC WaitVRetrace
;(*������������������������������������������������������������������������*);
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

;(*������������������������������������������������������������������������*);
     PROC WaitNRetrace
;(*������������������������������������������������������������������������*);
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

;(*������������������������������������������������������������������������*);
     PROC SetTimerHandler ; D:all
;(*������������������������������������������������������������������������*);
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

;(*������������������������������������������������������������������������*);
     PROC NewTimerFreq  ; D:all  N:EBX = FREQ
;(*������������������������������������������������������������������������*);
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

;(*������������������������������������������������������������������������*);
     PROC DirectTimerFreq  ; D:all  N:EAX = DIRECTCOUNT
;(*������������������������������������������������������������������������*);
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

;(*������������������������������������������������������������������������*);
     PROC ResetTimer
;(*������������������������������������������������������������������������*);
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


;(*������������������������������������������������������������������������*);
     PROC DUMMYTIMER
;(*������������������������������������������������������������������������*);
  RET
 ENDP

;(*������������������������������������������������������������������������*);
     PROC SYNCIRQ
;(*������������������������������������������������������������������������*);
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

;(*������������������������������������������������������������������������*);
     PROC TIMER
;(*������������������������������������������������������������������������*);
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

;(*������������������������������������������������������������������������*);
     PROC GETSCREENFREQ
;(*������������������������������������������������������������������������*);
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
