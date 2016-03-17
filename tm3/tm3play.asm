;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;'ßßßßßßßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßÛßÛÛÛÛÛÛÜ  ßßßßßßßßßßÛÛÛÛÛÛÜ THE MODULE V3.00á  '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ ß ÛÛÛÛÛÛÛ          ßßÛÛÛÛÛÛÛ  (C) Spring 1997   '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ  ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß by Syrius / Alpine '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
IDEAL
P386
ASSUME  cs:code32,ds:code32

TM3_NAME   EQU "INSIDE.TM3"
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
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; Code                                                                       ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
PUBLIC  _main
INCLUDE "TM3_CONST.ASM"

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO InitText Rows
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  mov [v86r_ax],0003h
  mov al,10h
  int 33h
  IF Rows EQ 50
   mov [v86r_ax],1112h
   mov [v86r_bl],00h
   mov al,10h
   int 33h
  ENDIF
  mov [v86r_ax],0600h
  mov [v86r_cx],0
  mov [v86r_dx],3250h
  mov [v86r_bh],7
  mov al,10h
  int 33h
  mov [v86r_ax],1003h
  mov [v86r_bl],0
  mov al,10h
  int 33h
 ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC Wait4Key   ; Destroys: AL        Needs: ---
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  mov [v86r_ax], 00
  mov al,16h
  int 33h
  mov ax,[v86r_ax]
  Ret
 ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO GetKey     ; Destroys: AL        Needs: ---
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  mov [v86r_ax], 0100h
  mov al,16h
  int 33h
  mov ax,[v86r_ax]
 ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO SPrint ADDR    ; Destroys eax, ebx   Needs: Eax = Offset of Message
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  pushad
  mov eax, o ADDR
  add eax, [_Code32a]
  shld ebx,eax,28
  and eax, 0Fh
  mov [v86r_ds], bx
  mov [v86r_dx], ax
  mov [v86r_ah], 09
  mov al, 21h

  int 33h
  popad
 ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC SWrite         ; Destroys ESI,EDI,CX Needs: Esi = Offset of Message    ;
                     ;          AX                edi = Screen-Offset        ;
                     ;                            cx  = Num of Chars         ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  mov ah,7
  @SLoop:
    movsb
    inc edi
    dec cx
  jne @SLoop
  Ret
 ENDP


  Digits db "o123456789ABCDEF"
  Buf    db "        $"
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO HexPrint Num; Destroys: ---   Needs: DX = Number; Num = Digits
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  pushad
  Xor bx,bx
  HEXINC = 1
  REPT Num
   mov bl,dl
   and bl,0Fh
   mov al,[Digits+bx]
   mov [Buf+Num-HEXINC],al
   shr edx,4
  HEXINC = HEXINC + 1
  ENDM
  mov [Buf+Num],'$'
  SPrint Buf
  SPrint CRLF
  popad
 ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC HexWrite ; Destroys: ---   Needs: EDX = Number; cl = Digits, EDI = Pos.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  pushad
  mov al,ch
  Xor ebx,ebx  ;' Shift left, so that the significant digits are in the MSBs
  mov ch,cl
  mov cl,8
  sub cl,ch
  shl cl,2
  shl edx,cl
  mov bl,ch    ;' Center Right.
  shl bl,1
  sub edi,ebx
  cmp al,1
  je  @HWLoop2
  @HWLoop1:
   rol edx,4
   add edi,2
   mov bl,dl
   and bl,0Fh
   jnz @HWNotZero
     mov [B DS:EDI],250
     dec ch
  jne @HWLoop1
  popad
  ret
  @HWLoop2:
   rol edx,4
   add edi,2
   mov bl,dl
   and bl,0Fh
   @HWNotZero:
   mov al,[Digits+ebx]
   mov [DS:EDI],al
   dec ch
  jne @HWLoop2
  popad
  ret
 ENDP

INCLUDE "TM3_MIX.ASM"
INCLUDE "TM3_DATA.ASM"
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  _MAIN: STI
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 Call SBDetect
 jc @ErrorNoSB
 Call SBWriteInfo

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
 jnz @NoStandard
  lea ecx, [Standard]
  Call LoadTM3
  jc @ErrorNoFile
  jmp @LoadReady
 @NoStandard:
 sub cl,5
 rep movsb
 mov esi,O Ending
 mov cl,6
 rep movsb
 lea ecx, [TM3File]
 Call LoadTM3
 jc @ErrorNoFile

 @LoadReady:

  InitText 50

  mov [Stereo],TM3_STEREO
  mov [LoopIt],TM3_LOOP
  mov [SamplingRate],TM3_SRATE
  Call PlayTM3

  mov esi,o Screen
  mov edi,0B8000h
  sub edi,[_code32a]
  mov ecx,2000
  rep movsd

  mov esi,o Screen2
  mov edi,0B8000h+24*160
  sub edi,[_code32a]
  mov ecx,1040
  rep movsd
  mov [LFlag],1

  mov edi,0B811Ch
  sub edi,[_code32a]
  add edi,12
  mov dx,[ADR]
  mov cl, 3
  Call HexWrite
  add edi,8
  mov dl, [IRQ]
  mov cl,2
  Call HexWrite
  add edi,8
  mov dl, [DMA]
  mov cl,2
  Call HexWrite
  mov [StartChannel],0
;-----------------------------------------------;
 @MainLoop:
  Call TrackWindow
  test [LFlag],1
  jnz @NoInfos
   Call CSampleValues
  @NoInfos:
  GetKey
  jz @MainLoop
  Call Wait4Key
  cmp al,27
  je @EndMain

  ;mov edi,0B8010h
  ;sub edi,[_Code32a]
  ;mov edx,eax
  ;mov cl,8
  ;Call HexWrite

  cmp ah, 4Dh
  jne @NoRCurs
   mov edx,[StartChannel]
   add edx,5
   cmp dl,[Channels]
   ja @MainLoop
   inc [StartChannel]
  @NoRCurs:

  cmp ah, 4Bh
  jne @NoLCurs
   cmp [StartChannel],0
   je @MainLoop
   dec [StartChannel]
  @NoLCurs:

  cmp ah,39h
  jne @NoSpace
   mov esi,o Screen+24*160
   xor [LFlag],1
   jz @Led2
    mov esi,o Screen2
   @Led2:
   mov edi,0B8000h+24*160
   sub edi,[_code32a]
   mov ecx,1040
   rep movsd

  @NoSpace:


 jmp @MainLoop
 @EndMain:
;-----------------------------------------------;

 Call StopTM3
 InitText 25
 jmp _exit

@ErrorNoFile:
 SPrint ErrorTM3
 jmp _exit

@ErrorNoSB:
 SPrint ErrorSB1
 jmp _exit

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; Data                                                                       ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

 ;Û²±° MainProc... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
 Leer db ' $'
 CRLF db 13,10,'$'
 Loud db 255

 INCLUDE "TM3_SCRN.ASM"
 INCLUDE "TM3_SCR2.ASM"

 Notes db "úúú "
       db "C-0 C#0 D-0 D#0 E-0 F-0 F#0 G-0 G#0 A-0 A#0 H-0 "
       db "C-1 C#1 D-1 D#1 E-1 F-1 F#1 G-1 G#1 A-1 A#1 H-1 "
       db "C-2 C#2 D-2 D#2 E-2 F-2 F#2 G-2 G#2 A-2 A#2 H-2 "
       db "C-3 C#3 D-3 D#3 E-3 F-3 F#3 G-3 G#3 A-3 A#3 H-3 "
       db "C-4 C#4 D-4 D#4 E-4 F-4 F#4 G-4 G#4 A-4 A#4 H-4 "
       db "C-5 C#5 D-5 D#5 E-5 F-5 F#5 G-5 G#5 A-5 A#5 H-5 "
       db "C-6 C#6 D-6 D#6 E-6 F-6 F#6 G-6 G#6 A-6 A#6 H-6 "
       db "C-7 C#7 D-7 D#7 E-7 F-7 F#7 G-7 G#7 A-7 A#7 H-7 "
       db "C-8 C#8 D-8 D#8 E-8 F-8 F#8 G-8 G#8 A-8 A#8 H-8 "
       db "C-9 C#9 D-9 D#9 E-9 F-9 F#9 G-9 G#9 A-9 A#9 H-9 "
       db "C-A C#A D-A D#A E-A F-A F#A G-A G#A A-A A#A H-A "

 Effect db  00,07h, 00,07h   ; 0 = Nothing
        db  32,04h,'S',04h   ; 1 = SetSpeed
        db  32,04h, 25,04h   ; 2 = Pattern Jump
        db  32,04h,'!',04h   ; 3 = Pattern Break
        db  32,09h, 18,09h   ; 4 = VSlide
        db  32,0Ah, 25,0Ah   ; 5 = Pitch Down
        db  32,0Ah, 24,0Ah   ; 6 = Pitch Up
        db  32,0Ah, 13,0Ah   ; 7 = Portamento
        db  32,0Ah,'~',0Ah   ; 8 = Vibrato
        db  32,0Ah,'÷',0Ah   ; 9 = Fine Vibrato
        db  32,09h, 22,09h   ;10 = Tremor
        db  32,0Ah,'ğ',0Ah   ;11 = Arpeggio
        db '~',0Ah, 18,09h   ;12 = Vibrato+VSlide
        db  13,0Ah, 18,09h   ;13 = Portamento + VSlide
        db  32,04h, 26,04h   ;14 = Set Offset
        db  32,04h, 19,04h   ;15 = Retrigger
        db  32,09h,'÷',09h   ;16 = Tremolo
        db  32,04h,'d',04h   ;17 = Pattern Delay
        db  32,04h, 15,04h   ;18 = Loop Start
        db  32,04h, 18,04h   ;19 = Loop x Times
        db  32,0Ah,'^',0Ah   ;20 = Note Cut
        db  32,0Ah,'d',0Ah   ;21 = Note Delay
        db  32,04h,'B',04h   ;22 = BPM
        db  32,04h,'v',04h   ;23 = Global Vol
        db  32,05h, 29,05h   ;24 = Set Panning

 ErrorTM3 db 'Error occured loading TM3. Check if you have enough HIMEM... $'
 ErrorSB1 db 'Error Initialising SB-Card. Try to configure manually.. ',13,10,'$'

 OkayMSG  db ' Okay, TM3 loaded... ',13,10,'$'
 Working  db ' Trying to set up DMA-Transfer...',13,10,'$'
 W2       db ' Still working...',13,10,'$'

 Loading  db "Loading: "
 TM3File  db 255 dup (0)
 Ending   db ".TM3",0,"$"
 Standard db TM3_NAME,"0"

 HLP1 DD ?
 HLP2 DD ?
 SplitState   db ?
 CHINC        dd ?           ;' For Track-View
 StartChannel dd ?           ;' For Track-View: Channel to be displayed as 1st
 CHNum        db ?
 LFlag        db ?

 ;Û²±° Tracking-Window °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

 OPatternLine db ?
 INCLUDE "TM3_VARS.ASM"
ENDS

END

