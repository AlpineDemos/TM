IDEAL
P386
ASSUME  cs:code32,ds:code32


TM3_NAME   EQU 'NOTHING.TM3'
TM3_STEREO = 1
TM3_LOOP   = 1
TM3_SRATE  = 21739
;TM3INC    = 1

o EQU OFFSET
b EQU BYTE PTR
w EQU WORD PTR
d EQU DWORD PTR

SEGMENT code16  PARA PUBLIC USE16
ENDS

SEGMENT code32  PARA PUBLIC USE32
;ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ;
; Code                                                                       ;
;ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ;
MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
PUBLIC  _main

INCLUDE 'help!.asm'
INCLUDE 'TM3_MIX.ASM'

;ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ;
  _MAIN: STI
;ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ;
  Call SBDetect
  jc @ErrorNoSB

  mov ecx,O LoadName
  Call LoadTM3
  jc @ErrorLoadTM3

  mov [Stereo],TM3_STEREO
  mov [LoopIt],TM3_LOOP
  mov [SamplingRate],TM3_SRATE
  Call PlayTM3
  SPrint Waiting
  Call SBWriteInfo

; Call SetTimerHandler
; Call WaitNRetrace
; mov ebx, OVERFREQ
; Call NewTimerFreq


 @MainLoop:
  mov edx,[TM3SyncCount]
; hexPrint 8
; sprint crlf
  GetKey
  jz @MainLoop
  Wait4Key
  cmp al,27
 jne @MainLoop

;-----------------------------------------------;

;Call ResetTimer
 Call StopTM3
 jmp _exit

@ErrorLoadTM3:
 SPrint ErrorTM3
 jmp _exit

@ErrorNoSB:
 SPrint ErrorSB1
 jmp _exit

;ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ;
; Data                                                                       ;
;ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ;

 ;лВБА MainProc... АБВлллллллллллллллллллллллллллллллллллллллллллллллллллллллл

 LoadName db TM3_Name,0
; INCLUDE 'PHARAO.INC'

 ErrorTM3 db 'Error occured loading TM3. Check if you have enough HIMEM... $'
 ErrorSB1 db 'Error Initialising SB-Card. Try to configure manually.. ',13,10,'$'

 Waiting  db 13,10,' TM3 v1.1  by Denis Kovacs aka Syrius / Alpine ',13,10
          db ' Status: Playing...  [ESC] to exit...',13,10,'$'

 ;лВБА Constants... АБВллллллллллллллллллллллллллллллллллллллллллллллллллллллл

 INCLUDE 'TM3_CONS.ASM'

 ;лВБА Variables... АБВллллллллллллллллллллллллллллллллллллллллллллллллллллллл

 INCLUDE 'TM3_VARS.ASM'
ENDS

END

