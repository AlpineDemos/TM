;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'
;'ЯЯЯЯЯЯЯЯЯЯЫЫЫЫЫЫЬ  ЫЫЫЫЫЫЫЯЫЯЫЫЫЫЫЫЬ	ЯЯЯЯЯЯЯЯЯЯЫЫЫЫЫЫЬ THE MODULE V3.00б  '
;'          ЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫ Я ЫЫЫЫЫЫЫ		ЯЯЫЫЫЫЫЫЫ  (C) Spring 1997   '
;'          ЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫ   ЫЫЫЫЫЫЫ	ЬЬЬЬЬЬЬЬЬЬЫЫЫЫЫЫЯ by Syrius / Alpine '
;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'
;' TM3 - No Output!                                                          '
;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'

IDEAL
P386
ASSUME  cs:code32,ds:code32

TM3_NAME   EQU "EXPLORAT.TM3"
TM3_STEREO = 1
TM3_LOOP   = 1
TM3_SRATE  = 21739

o EQU OFFSET
b EQU BYTE PTR
w EQU WORD PTR
d EQU DWORD PTR

SEGMENT code16  PARA PUBLIC USE16
ENDS

SEGMENT code32  PARA PUBLIC USE32
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
;(* Code                                                                   *);
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);

MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
PUBLIC  _main

INCLUDE "TM3.INC"
INCLUDE "Help!.ASM"

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  _MAIN: STI
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);

 mov [v86r_ah],62h
 mov al,21h
 int 33h
 xor esi,esi
 mov si,[v86r_bx]
 shl esi,4
 add esi,82h
 sub esi,[_code32a]
 mov edi,O TM3File
 xor ecx,ecx
 mov cl,[esi-2]
 or  cl,cl
 jz @ErrorNoFile
 sub cl,5
 rep movsb
 mov esi,O Ending
 mov cl,6
 rep movsb

 SPrint Loading

 Call SBDetect
 jc @ErrorNoSB

 Call SBWriteInfo

 mov ecx,O TM3File
 Call LoadTM3
 jc @ErrorLoadTM3

 mov [Stereo],TM3_STEREO
 mov [LoopIt],TM3_LOOP
 mov [SamplingRate],TM3_SRATE
 Call PlayTM3
 SPrint Waiting

 @MainLoop:
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
  xor ebx,ebx

  SPrint StatusLine
  mov edx,[TM3SyncCount]
  GetKey
  jz @MainLoop
  Wait4Key
  cmp al,27
 jne @MainLoop

;-----------------------------------------------;

 Call StopTM3
 jmp _exit

@ErrorLoadTM3:
 SPrint ErrorTM3
 jmp _exit

@ErrorNoSB:
 SPrint ErrorSB1
 jmp _exit

@ErrorNoFile:
 SPrint Usage
 jmp _exit


;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
;(* Data                                                                   *);
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
 ;ЫІ±° MainProc... °±ІЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ

 Ending db ".TM3",0,"$"
 Loading db "Loading: "
 TM3File db 255 dup (0)

 ErrorTM3 db "Error occured loading TM3. File not found or not enough MEM... $"
 ErrorSB1 db "Error Initialising SB-Card. Try to configure manually.. ",13,10,"$"
 Usage    db "Usage: ASMTM3 <Name>.TM3 ",13,10,"$"
 StatusLine db 53 dup (8)
            db " Order: "
  COrder    dw ?
            db "/"
  MaxOrder  dw ?
            db " Pattern: "
  CPat      dw ?
            db "/"
  MaxPat    dw ?
            db " Line: "
  CLine     dw ?
            db "/63 Speed: "
  CSpeed    dw ?
            db "/"
  CBPM      dw ?
            db "$"

 Waiting  db 13,10," TM3 v1.1  by Denis Kovacs aka Syrius / Alpine ",13,10
          db " Status: Playing...  [ESC] to exit...",13,10,"$"

 ;ЫІ±° Constants... °±ІЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ
ENDS

END

