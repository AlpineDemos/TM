;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'
;'ЬЫЫЫЫЫЯЯЯЯЫЫЫЫЫЫЬ  ЫЫЫЫЫЫЫЯЯЯЫЫЫЫЫЫЬ	ЯЯЯЯЯЯЯЯЯЯЫЫЫЫЫЫЬ ALPINE PLAYER V3.00'
;'ЫЫЫЫЫЫ    ЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫ   ЫЫЫЫЫЫЫ		ЯЯЫЫЫЫЫЫЫ  (C) 1997          '
;'ЫЫЫЫЫЫ ЯЯЯЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫЯЯЯЯЯЯЯЯЯ 	ЬЬЬЬЬЬЬЬЬЬЫЫЫЫЫЫЯ by Syrius / Alpine '
;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'
;' TM3 - No Output!                                                          '
;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'

TM3_NAME   EQU "NOTFORKI.TM3"
TM3_STEREO = 1
TM3_LOOP   = 1
TM3_SRATE  = 21739

PMODEASM = 1

o EQU OFFSET
b EQU BYTE PTR
w EQU WORD PTR
d EQU DWORD PTR

IDEAL
P386
ASSUME  cs:code32,ds:code32


SEGMENT code32  PARA PUBLIC USE32
MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
PUBLIC  _main
INCLUDE "AP_ASM.INC"
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
;(* Code                                                                   *);
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 MACRO GetKey     ; Destroys: AL        Needs: ---
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
  mov [v86r_ax], 0100h
  mov al,16h
  int 33h
  mov al,[v86r_al]
 ENDM
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 MACRO Wait4Key   ; Destroys: AL        Needs: ---
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
  mov [v86r_ax], 00
  mov al,16h
  int 33h
  mov al,[v86r_al]
 ENDM


;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  _MAIN: STI
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);

 Call AP_InitPointers_

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
 Call detectSB_
 jc @ErrorNoSB

 Call SBWriteInfo

 mov ecx,O TM3File
 Call LoadTM3
 jc @ErrorLoadTM3

 mov [_Stereo],TM3_STEREO
 mov [_LoopIt],TM3_LOOP
 mov [_SamplingRate],TM3_SRATE
 Call PlayTM3_
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
  mov edx,[_TM3SyncCount]
  GetKey
  jz @MainLoop
  Wait4Key
  cmp al,27
 jne @MainLoop

;-----------------------------------------------;

 Call stopTM3_
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
 TM3FILE db tm3_name,0,"$"
         db 255 dup (0)

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

 INCLUDE "AP_VARS.ASM"
ENDS
END
