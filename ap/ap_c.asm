;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'
;'蔔栢栢賽賽栢栢栢�  栢栢栢幡賽栢栢栢�  賽賽賽賽賽栢栢栢� ALPINE PLAYER V3.00'
;'栢栢栢    栢栢栢�  栢栢栢�   栢栢栢�          賽栢栢栢�  (C) 1997          '
;'栢栢栢 賽賞栢栢栢  栢栢栢幡賽賽賽賽   複複複複複栢栢栢� by Syrius / Alpine '
;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'
;' AP 3.0 WATCOM C/C++ - Protected Mode - Link-Version.
;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'

;' Remember!  False = 0 !                                                    '
;'            True  = 1 !                                                    '

AP_C = 1

o EQU offset
b EQU byte ptr
w EQU word ptr
d EQU dword ptr

IDEAL
P386
GROUP DGROUP _DATA, _BSS


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
SEGMENT _TEXT byte public use32 'CODE'
 ASSUME CS:_TEXT, DS:DGROUP

 GLOBAL _StartPattern: DWord
 GLOBAL _TM3SyncCount: DWord
 GLOBAL _SongLoop    : Byte
 GLOBAL _PatternLen  : DWord

 GLOBAL _SoundCard   : Word
 GLOBAL _Stereo      : Byte
 GLOBAL _ADR         : Word
 GLOBAL _IRQ         : Byte
 GLOBAL _DMA         : Byte
 GLOBAL _SamplingRate: Word
 GLOBAL _LoopIt      : Byte

 GLOBAL _DMAFlipFlop : Byte
 GLOBAL _DIVConst    : DWord

 GLOBAL _OrdNum      : Byte
 GLOBAL _PatternLine : Byte

 GLOBAL _IRQ_Stop    : Byte
 GLOBAL _IRQ_Finished: Byte


 GLOBAL _MasterSpace : Word
 GLOBAL _GlobalVol   : Byte
 GLOBAL _Speed       : Byte
 GLOBAL _BPM         : Byte
 GLOBAL _Tempo       : Byte
 GLOBAL _Channels    : Byte
 GLOBAL _SongLen     : Byte
 GLOBAL _PatNum      : Byte
 GLOBAL _SmpNum      : Byte

 GLOBAL _LineAdd     : DWord
 GLOBAL _PackedLen   : Word

 GLOBAL _DMABuf      : DWord ; *
 GLOBAL _PTRPatternP : DWord ; *
 GLOBAL _VolTableP   : DWord ; *
 GLOBAL _OrderP      : DWord ; *
 GLOBAL _PanningP    : DWord ; *
 GLOBAL _SampleVolP  : DWord ; *

 GLOBAL _CSampleP    : DWord ; *
 GLOBAL _SampleP     : DWord ; *
 GLOBAL _TM3BufferP  : DWord ; *
 GLOBAL _MixBufP     : DWord ; *
 GLOBAL _PostProcP   : DWord ; *

 PUBLIC AP_InitPointers_
 PUBLIC PlayTM3_
 PUBLIC StopTM3_
 PUBLIC checkSBSettings_
 PUBLIC detectSB_

 PUBLIC SetCursor_
 PUBLIC OpenFile_
 PUBLIC ReadFile_
 PUBLIC CloseFile_

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC OpenFile_
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  mov ah, 03Dh
  int 21h
  jnc @NoOpenErr
   xor eax,eax
  @NoOpenErr:
  Ret
 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC readFile_
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  mov ecx, ebx
  mov ebx, eax
  mov ah, 03Fh
  int 21h
  jnc @NoReadErr
   xor eax,eax
  @NoReadErr:
  Ret
 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC closeFile_
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  mov ebx,eax
  mov ah, 03Eh
  int 21h
  jnc @NoCloseErr
   xor eax,eax
  @NoCloseErr:
  Ret
 ENDP


;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC SetCursor_
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  mov dx,ax
  mov ah,02h
  xor bh,bh
  int 10h
  Ret
 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC AP_InitPointers_
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  pushad

  mov eax,o _PTRPattern
  mov [_PTRPatternP], eax

  mov eax,o _Order
  mov [_OrderP], eax

  mov eax,o _VolTable
  mov [_VolTableP], eax

  mov eax,o _Panning
  mov [_PanningP], eax

  mov eax,o _SampleVols
  mov [_SampleVolP], eax

  mov ax, 0100h
  mov bx, 2000h
  int 31h
 jc @ErrorMem
  mov bx,dx
  mov ax, 0006h
  int 31h
 jc @ErrorMem
  shl ecx,16
  mov cx, dx

  or cx, cx
  je @No2Buf
    add ecx, 65536
    xor cx,cx
  @No2Buf:
  mov [_DMABuf],ecx

  mov ax,0501h
  mov bx,0001h
  mov cx,7C56h  ;'13782+65536+32*64+100*16
  int 31h
  jc @ErrorMem
  shl ebx,16
  mov bx,cx

  mov [_MixBufP],ebx  ;' 88200/12.8 * 2 ( WORD-MIXING! )
  add ebx,13782
  mov [_PostProcP],ebx
  add ebx,65536
  mov [_CSampleP],ebx
  add ebx,2048
  mov [_SampleP],ebx

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
     PROC APPrint   ; d: ---- N: eax:ADDR
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  pushad
  mov edx, eax
  mov ah,09h
  int 21h
  popad
  Ret
 ENDP

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     MACRO GetSetIRQ  irq, old, new
local @@CNoIRQ2, @@CNoIRQ3
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
   mov eax,0204h     ; DPMI!
   mov bl,irq
   cmp bl,8
   jb @@CNoIRQ2
    add bl,60h
   @@CNoIRQ2:
   add bl,8          ; INTNum, not IRQ!!!!
   int 31h
   mov [old], edx
   mov [d old+4],ecx
   mov eax,0205h
   mov bl,irq
   cmp bl,8
   jb @@CNoIRQ3
    add bl,60h
   @@CNoIRQ3:
   add bl,8          ; INTNum, not IRQ!!!!
   xor ecx,ecx
   mov cx, cs
   mov edx,o new
   int 31h
 ENDM

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     MACRO SetIRQ  irq, new, flag
   local @@CNoIRQ5
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
   mov ax,0205h
   mov bl,irq
   cmp bl,8
   jb @@CNoIRQ5
    add bl,60h
   @@CNoIRQ5:
   add bl,8          ; INTNum, not IRQ!!!!
   IFNB <Flag>
    mov edx,[new]
    mov ecx,[d new+4]
   ELSE
    mov edx,o new
    xor ecx,ecx
    mov cx, cs
   ENDIF
   int 31h
 ENDM

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     MACRO SetCallBack irq, stub, callb
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
 ENDM

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     MACRO UnCallBack irq, callb
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
 ENDM

 INCLUDE "AP_CONST.ASM"
 INCLUDE "AP_MIX.ASM"


ENDS
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
SEGMENT _DATA para public use32 'DATA'
 _DMA_Page  db 87h,83h,81h,81h
 _DMA_Adr   db 00 ,02, 04, 06
 _DMA_Len   db 01 ,03 ,05, 07

 _PTRPatternP dd ?
 _VolTableP   dd ?
 _OrderP      dd ?
 _PanningP    dd ?
 _SampleVolP  dd ?
ENDS

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
SEGMENT _BSS para Public use32 'BSS'
  INCLUDE "AP_VARS.ASM"
ENDS

End