PMODEASM = 1
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC AP_InitPointers_
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  pushad

  mov eax,20000h
  call _getlomem
 jc @ErrorMem
  add eax,[_code32a]
  or ax, ax
  je @No2Buf
    add eax, 65536
    xor ax,ax
  @No2Buf:
  sub eax,[_code32a]
  mov [_DMABuf],eax

  mov eax,014416h
  call _getmem
 jc @ErrorMem

  mov [_MixBufP],eax  ;' 88200/12.8 * 2 ( WORD-MIXING! )
  add eax,13782
  mov [_PostProcP],eax
  add eax,65536
  mov [_CSampleP],eax
  add eax,2048
  mov [_SampleP],eax

  Call CalcVolTable

  popad
  mov al,1
  Ret
 @ErrorMem:
  popad
  xor al,al
  Ret

 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     MACRO SPrint text  ; d: ---- N: text: ADDR
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  mov eax,o text
  call APPrint
 ENDM


;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC APPrint   ; d: ---- N: eax:ADDR
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  pushad
  add eax, [_Code32a]
  shld ebx,eax,28
  and eax, 0Fh
  mov [v86r_ds], bx
  mov [v86r_dx], ax
  mov [v86r_ah], 09
  mov al, 21h
  int 33h
  popad
  Ret
 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     MACRO GetSetIRQ  irq, old, new
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
   mov bl,irq
   Call [_GetIrqVect]
   mov [old],edx
   mov edx, o new
   Call [_SetIrqVect]
 ENDM

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     MACRO SetIRQ  irq, new, flag
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
   mov bl,irq
   IFNB <Flag>
    mov edx, [new]
   ELSE
    mov edx, o new
   ENDIF
   Call [_SetIrqVect]
 ENDM

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     MACRO SetCallBack irq, stub, callb
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
   mov bl,irq
   mov edi, o stub
   call _rmpmirqset
   mov callb,eax
 ENDM

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     MACRO UnCallBack irq, callb
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
   mov bl,irq
   mov eax,callb
   call _rmpmirqfree
 ENDM

INCLUDE "AP_MIX.ASM"

;(*컴컴 CONSTANTS........컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);

 INCLUDE "AP_CONST.ASM"
 _DMA_Page  db 87h,83h,81h,81h
 _DMA_Adr   db 00 ,02, 04, 06
 _DMA_Len   db 01 ,03 ,05, 07
