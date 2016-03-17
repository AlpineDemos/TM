;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; Assembler - Routinen fr SB / SB Pro                            .Syrius.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

IDEAL
P386
ASSUME CS:Code, DS:Data

INCLUDE "Find1.ASM"

 W EQU Word  Ptr
 B EQU Byte  Ptr
 D EQU DWord Ptr
 sampleconst equ 0A00000h

;TPUsed = 1


SEGMENT Data Public

 IFDEF TPUsed

  extrn FlatPos     :Dword ;IMMER EXTRN!
  extrn LoadName    :DWord ;IMMER EXTRN!
  extrn LoadBuffer  :DWord

  extrn PatternLine:word
  extrn Modloop:byte
  extrn PatNum:byte
  extrn Modlen:byte
  extrn Pattern:DWord
  extrn Arrangement:DWord
  extrn Speed:byte
  extrn TBufPos :dword
  extrn MInstSmp:  DWord
  extrn MInstPos:  DWord
  extrn MInstLen:  DWord
  extrn MInstLoopS:DWord
  extrn MInstInc:  DWord
  extrn MInstVol:  DWord
  extrn MInstEff1: DWord
  extrn MInstEff2: DWord
  extrn MInstEff3: DWord
  extrn Endemod:byte

 ELSE
  FlatPos     dd ?
  LoadBuffer  dd ?
  Endemod     db ?
  PatternLine dw ?
  Modloop     db ?
  PatNum      db ?
  Modlen      db ?
  Pattern     dd 64 dup (?)
  Arrangement db 128 dup (?)
  Speed       db ?
  TBufPos     dd ?
  MInstSmp    dd 8 dup (?)
  MInstPos    dd 8 dup (?)
  MInstLen    dd 8 dup (?)
  MInstLoopS  dd 8 dup (?)
  MInstInc    dd 8 dup (?)
  MInstVol    dd 8 dup (?)
  MInstEff1   dd 8 dup (?)
  MInstEff2   dd 8 dup (?)
  MInstEff3   dd 8 dup (?)
 ENDIF

 BufActive db ?
 TBufStop  dd ?
 apattern  dd ?    ;Position of actual Pattern in RMEM
 Oldint    dd ?
 Buffer0   dd ?
 Buffer1   dd ?
 Buffer2   dd ?
 InstLen   dd 32 dup (?)
 InstVol   dd 32 dup (?)
 InstLoopS dd 32 dup (?)
 Samples   dd 32 dup (?)
 ticks     db ?
 MLpStart  db ?
 OTimerInc db ?
 NewCli    db ?
 LastNote1 dw ?
 LastNote2 dw ?
 LastNote3 dw ?
 LastNote4 dw ?

 OldIRQ dd ?
 OldTIM dd ?
 SAVEMASK db ?
 mixbuff  dw 880 dup (?)
ENDS

SEGMENT CODE Public

PUBLIC PlayMod, StopMod, PrepareArpeggio, FillFlat
PUBLIC SearchFlat,ALoadMod

  ModOctave dw 3424,3232,3048,2880,2712,2560,2416,2280,2152,2032,1920,1812
            dw 1712,1616,1524,1440,1356,1280,1208,1140,1076,1016,0960,0906
            dw 0856,0808,0762,0720,0678,0640,0604,0570,0538,0508,0480,0453
            dw 0428,0404,0381,0360,0339,0320,0302,0285,0269,0254,0240,0226
            dw 0214,0202,0190,0180,0170,0160,0151,0143,0135,0127,0120,0113
            dw 0107,0101,0095,0090,0085,0080,0075,0071,0067,0063,0060,0056

  VibratoTable dw +000,+024,+049,+074,+097,+120,+141,+161,+180,+197,+212,+224,+235,+244,+250,+253
               dw +255,+253,+250,+244,+235,+224,+212,+197,+180,+161,+141,+120,+097,+074,+049,+024
               dw +000,-024,-049,-074,-097,-120,-141,-161,-180,-197,-212,-224,-235,-244,-250,-253
               dw -255,-253,-250,-244,-235,-224,-212,-197,-180,-161,-141,-120,-097,-074,-049,-024


 MInstJump dw OFFSET @NO_Tick_Effect
           dw 15 dup (1)                ;0-1Eh Effects
           dw OFFSET @Arpeggio_20
           dw OFFSET @Portamento_22
           dw OFFSET @Portamento_24
           dw OFFSET @Portamento_26
           dw OFFSET @Portamento_28
           dw OFFSET @VolumeSlide_2A
           dw OFFSET @VolumeSlide_2C
           dw OFFSET @Vibrato_2E        ;@No_Tick_Effect

           dw 0 ;30
           dw 0 ;32
           dw 0 ;34
           dw OFFSET @RetriggerNote_36
           dw 0 ;38
           dw OFFSET @PortaVSlideUpUp
           dw OFFSET @PortaVSlideUpDn
           dw OFFSET @PortaVSlideDnUp
           dw OFFSET @PortaVSlideDnDn
           dw OFFSET @VibVSlideUp_42
           dw OFFSET @VibVSlideDn_44

 Finetunes dw 8363,8413,8463,8529,8581,8651,8723,8757
           dw 7895,7941,7985,8046,8107,8169,8232,8280

 dma_page  db 87h,83h,81h,81h
 dma_adr   db 00 ,02, 04, 06
 dma_len   db 01 ,03 ,05, 07

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
MACRO FileRead len, mem
 mov ah,3Fh
 IFNB <mem>
  lea dx,[mem]
 ENDIF
 mov cx,len
 int 21h
ENDM

PROC ALoadMod Far

 mov ax,3D40h
 lea dx,[LoadName]
 int 21h
 jnc @OpenOK
  mov al,0
  ret
 @OpenOK:

 mov bx,ax              ;Handle always in BX
 FileRead 20,MixBuff
 xor si,si
 @LOADInst1:
  add si,4
  FileRead 22,MixBuff
  FileRead 2,InstLen+Si ;Length convert
  mov cx,[W InstLen+si]
  xchg cl,ch
  shl cx,1
  mov [W InstLen+Si],cx

  FileRead 1,InstVol+Si
  xor ah,ah
  mov al,[B InstVol+Si]
  cmp al,15
  jbe @NOverFineTune
   xor al,al
  @NOverFineTune:
  shl ax, 9
  push ax
  FileRead 1,InstVol+Si
  xor dh,dh
  mov dl,[B InstVol+Si]
  cmp dl,63
  jbe @NOverVol
   mov dl,63
  @NOverVol:
  pop ax
  add ax,dx
  mov [W InstVol+Si],ax

  FileRead 2,InstLoopS+Si
  mov ax,[W InstLoopS+Si]
  xchg ah,al
  shl eax,17
  push eax

  FileRead 2,InstLoopS+Si

  mov dx,[W InstLoopS+Si]
  xchg dh,dl
  shl dx,1
  pop eax
  mov ax,dx

  mov [InstLoopS+Si],eax

  cmp si,31*4
 jne @LOADInst1

 FileRead 1,ModLen
 dec [ModLen]

 FileRead 1,MLpStart
 mov al,[MLpStart]
 cmp al,[ModLen]
 jbe @OkLoop
  xor al,al
 @OkLoop:
 mov [MLpStart],al

 FileRead 128,Arrangement
 FileRead 4,MixBuff

 xor al,al
 mov di,128
 @GetMaxPat:
  dec di
  mov ah,[B Arrangement+di]
  cmp al,ah
  jae @NoIncPat
   mov al,ah
  @NoIncPat:
  test di,di
 jne @GetMaxPat
 xor ah,ah
 mov di,ax
 inc di

 xor si,si
 @PatLoop:
  push ds
  lds dx, [LoadBuffer]
  FileRead 1024
  pop ds
  Call PrepareArpeggio
  Call ReadFlat Pascal,[LoadBuffer], [FlatPos], 1024
  mov eax,[FlatPos]
  mov [Pattern+Si],eax
  add [FlatPos],1024
  add si,4
  dec di
 jne @PatLoop

 xor di,di
 @SampleLoop:
  add di,4
  xor esi,esi
  Mov si, [W InstLen+Di]
  push ds
  lds dx, [LoadBuffer]
  FileRead Si
  pop ds

  Call ReadFlat Pascal,[LoadBuffer], [FlatPos], Si
  Mov eax,[FlatPos]
  mov [Samples+Di],eax
  add [FlatPos],esi

  mov eax,[InstLoopS+Di]
  mov cx,ax
  shr eax,16    ;ax=W

  mov dx,ax
  add dx,cx
  cmp dx,[W InstLen+Di]
  jbe @NoCorrLen
   mov cx,[W InstLen+Di]
   sub cx,ax
  @NoCorrLen:

  cmp cx,10
  jbe @NoSampleLoop
   mov [W InstLen+Di],dx
   shl eax,16
   inc al
   mov [InstLoopS+Di],eax
  jmp @EndLoopCheck
  @NoSampleLoop:
   mov [InstLoopS+Di],0
  @EndLoopCheck:

  Shl [InstLen+Di],16
  inc [InstLen+Di]

 cmp di,4*31
 jb  @SampleLoop

 Call SearchFlat
 mov eax,[Buffer2]
 mov [FlatPos],eax

 mov ah,3Eh
 int 21h

 mov al,1
 Ret
ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
PROC TransferBlock
  push cx  ;cx  = DSP-Len
  push bx  ;bx  = DMA-Len
  push eax ;eax = Buffer!
  mov al,4
  add al,[DMA]
  out 0Ah, al
  mov al,58h
  add al,[DMA]
  out 0Bh, al
  xor bh,bh
  xor dh,dh
  mov bl,[DMA]
  mov dl,[DMA_ADR+bx]
  xor al,al
  out 0Ch, al
  pop eax               ;mov eax,[Buffer0]
  out dx,al
  shr ax,8
  out dx,al
  shr eax,16
  mov dl,[DMA_PAGE+bx]
  out dx,al
  mov dl,[DMA_LEN+bx]
  xor al,al
  out 0Ch, al
  pop ax                ;mov ax,0ABDFh
  out dx,al
  shr ax,8
  out dx,al
  WDsp 48h
  pop bx
  WDsp bl               ;WDsp 0EFh
  WDsp bh               ;WDsp 055h
  WDsp 01Ch
  WDsp 40h
  WDsp 211
  WDsp 0D1h
  mov al,[DMA]
  out 0Ah,al
  Ret
ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Init SB/Pro at Adr ÄÄ;
PROC DspInterrupt Far
 push dx
 push eax
 push ds
  mov ax,data
  mov ds,ax
  mov dx,[ADR]
  add dx,0Eh
  in al,dx
  cmp [BufActive],0
  jne @Dl1
    mov eax, [Buffer1]
    mov [TBufPos],Eax
    mov eax, [Buffer2]
    mov [TBufStop],Eax
    jmp @DlReady
  @Dl1:
    mov eax, [Buffer0]
    mov [TBufPos],Eax
    mov eax, [Buffer1]
    mov [TBufStop],Eax
  @DlReady:
  xor [BufActive],1

  mov al,20h
  cmp [IRQ],10
  jne @NoI10
   out 0A0h,al  ;IRQ 10-> EOI to 2nd PIC !  _W_A_S_  A   B U G :)
  @NoI10:
  out 20h,al
 pop ds
 pop eax
 pop dx
Iret
ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Init SB/Pro at Adr ÄÄ;

PROC PlayMod Far
 mov [PATNUM], 255    ; Force Pattern=0 at beginning
 mov [speed],6        ; Default Speed=6
 mov [ticks],5        ; Force new line at beginning
 mov [PatternLine],63 ; Force new Pattern at beginning
 mov [NewCli],0       ; no Handling-Routine active
 mov [BufActive],1
 mov eax, [Buffer1]   ; Start Playing with second Buffer ( calc 1st Buf! )
 mov [TBufPos],eax
 mov eax, [Buffer2]   ; Set end of 2nd Rea... I mean 2nd Buffer ;)
 mov [TBufStop],eax

 ; Initialize Data for all Channels:
 xor eax,eax
 mov [MInstLen+00],eax
 mov [MInstLen+04],eax
 mov [MInstLen+08],eax
 mov [MInstLen+12],eax

 mov dx,[ADR]
 Call InitSB

 Cmp [SBPro],0
 je @NoSBProInit
   WMixer 0Ch, 17
   WMixer 0Eh, 17
   WMixer 22h, 0EEh
 @NoSBProInit:

 Call FillFlat Pascal,[Buffer0], 44000, 128
 mov eax,[Buffer0]
 mov bx, 0ABDFh   ;DMA-Len
 mov cx, 055EFh   ;DSP-Len
 Call TransferBlock

 xor bh,bh
 mov bl,[IRQ]
 cmp bl,10
 jne @noIRQ10
  add bl,60h
 @NoIRQ10:
 add bl,08h
 shl bx,2       ;bx=Pointer to Interrupt-Vectortable

 push es
 xor ax,ax
 mov es,ax
 mov eax,[es:bx]
 mov [OldIRQ],eax
 mov ax,cs
 shl eax,16
 lea ax,[DspInterrupt]
 cli
  mov [es:bx],eax
 sti

 cmp [IRQ],10
 je @2NDPIC
  in al,21h        ; Demask IRQ: Port[$21]:=port[$21] and (not (1 shl irq))
  mov [SAVEMASK],al
  mov cl,[IRQ]
  mov ah,1
  shl ah,cl
  not ah
  and al,ah
  out 21h, al
  jmp @EndPIC
 @2NDPIC:
  in  al,0A1h      ; Demask PIC for IRQ 10
  mov [SAVEMASK],al
  and al,11111011b
  out 0A1h, al
 @EndPIC:


 mov eax,[es:08h*04]
 mov [OldTIM],eax
 cli
  mov [es:71h*04],eax
 sti
 mov ax,cs
 shl eax,16
 lea ax,[NewTimer]
 cli
  mov [es:08h*04],eax     ; Set Int 08 to NewTimer!
  mov al,36h              ; TimerFreq to 51 Hz -> 1193180 div 51 = 5B63h
  out 43h,al
  mov al,63h ;Lo-Word
  out 40h,al
  mov al,5Bh ;Hi-Word
  out 40h,al
 sti
 pop es
 Ret
ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Init SB/Pro at Adr ÄÄ;
PROC StopMod Far
 cli                      ;TimerFreq to 18.2
  mov al,36h
  out 43h,al
  xor al,al
  out 40h,al
  out 40h,al
 sti

 push es
 xor ax,ax
 mov es,ax
 mov eax,[OldTIM]
 cli
  mov [es:08h*04],eax
 sti

 cmp [IRQ],10
 mov al,[SAVEMASK]
 je @DeIRQ10
  out 21h,al
  jmp @EndDeMASK
 @DeIRQ10:
  out 0A1h,al
 @EndDeMASK:

 xor bh,bh
 mov bl,[IRQ]
 cmp bl,10
 jne @noIRQ10Out
  add bl,60h
 @NoIRQ10Out:
 add bl,08h
 shl bx,2       ;bx=Pointer to Interrupt-Vectortable

 mov eax,[OldIRQ]
 cli
  mov [es:bx],eax
 sti

 pop es

 mov al,5
 out 0Ah,al

 mov dx,[ADR]
 Call InitSB
 Ret
ENDP


r64 db 64
r4  db 4
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Init SB/Pro at Adr ÄÄ;
PROC SBMix2 Near

 Mov bp,16                      ; BP = Channel-Index
 @Channel_Loop:
  Sub bp,4
  mov eax, [MInstSmp+bp]         ;
  mov [D cs:@AddressFlat+4],eax  ; CodeManip.: Startaddresse des Samples

  mov edi, [MInstPos+bp]
  mov esi, [MInstInc+bp]
  mov edx, [MInstLen+bp]         ; MInstLen:=Length shl 16
  mov cl,  [B MInstVol+bp]
  mov ch, 64

  mov bx,880
  @Byte_Loop:
   cmp edi,edx                  ; Position < L„nge ( mit Nachkomastellen )
   jb @No_Ende
   or dx,dx                     ; if dx = 1 then Sample still active
   jz @Ende_inst
   mov eax, [MInstLoopS+bp]     ; EAX = LoopStart
   or  eax, eax
   jnz @LoopActiv               ; EAX = 0 -> kein Loop!
    xor dx,dx                   ; DX:=0 -> Sample switched off! (See above)
    jmp @Ende_Inst
   @LoopActiv:
   mov edi, eax
   @No_Ende:
    mov eax,edi                 ; EAX=Position ohne Nachkommastellen
    shr eax,16
    add edi,esi                 ; Position um INC erh”hen
    @AddressFlat:               ; CodeManipulation:
    mov al,[gs:0000FFFFh+eax]   ; 0000FFFFh = Startadresse des Samples
    imul cl
    idiv ch
    cbw
    add [W MixBuff+bx],ax
   @Ende_Inst:
   Dec bx
   Dec bx
  jne @Byte_Loop
  Mov [MInstPos+bp],edi          ; Position abspeichern!
 cmp bp,0
 jne @Channel_Loop

 mov edi,[TBufPos]
 mov bx,880
 @WriteLoop:
  xor ax,ax
  xchg ax,[W MixBuff+bx]
  sar ax,2
  sub al, 128
  mov [gs:edi],al
  inc edi
  dec bx
  dec bx
 jne @WriteLoop
 mov [TBufPos],edi
Ret
ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Init SB/Pro at Adr ÄÄ;
PROC NewTimer Far
Pushf
Pushad
 push es
 push gs
 push ds

 xor ecx,ecx               ;Fr Division bei Note in Pattern
 mov gs,cx                 ;Flat-Model-Addressierung!

 mov dx,data               ;Datasegment addressieren
 mov ds,dx
 cmp [NewCli],0
 je @NoMyCli
  jmp @SkipTimer
 @NoMyCli:

 mov eax,[TBufStop]
 cmp [TBufPos],eax
 jb  @IntoTimer
  jmp @SkipTimer
 @IntoTimer:
 Mov [NewCli],1
 inc [Ticks]
 mov dl,[Ticks]
 cmp dl,[Speed]
 je  @IntoLine
  jmp @NoNewLine
 @IntoLine:
 mov [Ticks],0
 ;-------------------PatternLine-Actualisation
 xor edi,edi
 mov di,[PatternLine]
 cmp di,63
 jb  @NoNewPattern
  ;-----------------Neues Pattern
  xor bh,bh
  mov bl,[PatNum]
  inc bl
  cmp bl,[ModLen]
  jbe @ModNotEnded
   mov bl,[MLpStart]
   cmp [Modloop],1
   je  @ModNotEnded
     mov [EndeMod],1     ;Kein Loop->Raus
     jmp @SkipTimer
  @ModNotEnded:
  mov [patnum],bl
  mov bl,[B Arrangement+bx]
  shl bx,2
  mov eax,[Pattern+bx]
  mov [APattern],eax
  mov di,0FFFFh        ;wird von inc auf 0 gesetzt
  ;-------------------------------
 @NoNewPattern:
 inc di
 mov [PatternLine],di
 ;--------------------------
 shl di,4               ;DWord-Zugriff.
 add edi,[APattern]
 mov si,16              ;si:dword->Schhleifenz„hler
 add edi,16             ;di:dword->Offset in APattern
 @NTrackLoop:
  sub edi,4
  sub si,4

  mov ah,[B gs:edi]
  and ah,0Fh
  mov al,[B gs:edi+1]

  mov bl,[B gs:edi]
  and bl,0F0h
  mov bh,[B gs:edi+2]
  shr bh,4
  add bl,bh               ;ax:=Note in Pattern
  xor bh,bh               ;bx:=momentanes Instrument in Pattern
  mov [B MInstVol+si+3],bh ;Jump Index = 0
  shl bx,2
  mov cx,[W InstVol+bx]

  mov dl,[B gs:edi+2]          ; Wenn Tone Portamento, Dann keine Tonh”he
  and dl,0Fh
  cmp dl,08h
  jne @noarp1
    cmp ah,15
    jne @noloud
      xor ah,ah
      mov bp,ax
      mov ax,[w ModOctave+bp]
      jmp @noarp1
    @noloud:
    xor ax,ax
    jmp @noinstrument2
  @noarp1:

  or bl,bl
  jz @NoInstrument2
    mov [B MInstVol+si],cl
  @NoInstrument2:

  cmp ax,0
  je @NoNote

    or bl,bl
    jz @NoInstrument1
     mov [B MInstEff3+si+3],ch
     mov edx,[Samples+bx]
     mov [MInstSmp+si],edx
     mov edx,[InstLen+bx]
     mov [MInstLen+si],edx
     mov edx,[InstLoopS+bx]
     mov [MInstLoopS+si],edx
    @NoInstrument1:

    mov bx,8363                    ;Set FineTune
    mul bx
    xor bh,bh
    mov bl, [B MInstEff3+si+3]
    mov bx, [FineTunes+bx]
    div bx
    mov cx,ax

    mov [W MInstEff2+si+1],cx
    mov dl,[b gs:+edi+2]          ; Wenn Tone Portamento, Dann keine Tonh”he
    and dl,0Fh
    cmp dl,3
    je @NoNote

    xor edx,edx
    mov [MInstPos+si+2],edx    ;Position auf 0
    mov [W MInstVol+si+1], cx
    mov eax,SampleConst
    div ecx
    mov [MInstInc+si],eax
  @NoNote:


  mov ax,[w gs:edi+2] ;al:Effect, ah:effectbyte
  and al,0Fh
  or al,al
  jz @EndEffects

  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 22h Portamento up ²²±°
  cmp al,01h
  jne @No_e01
    mov [B MInstVol+si+3],22h ;22h=Portamento Up
    or  ah,ah
    jz @out_e01
    mov [B MInstEff1+si+1],ah
    @out_e01:
    jmp @EndEffects
  @No_e01:

  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 24h Portamento dn ²²±°
  cmp al,02h
  jne @No_e02
    mov [B MInstVol+si+3],24h ;24h=Portamento Dn
    or  ah,ah
    jz @out_e02
    mov [B MInstEff1+si+2],ah
    @out_e02:
    jmp @EndEffects
  @No_e02:

  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 26h/28h Tone Portamento up/dn ²²±°
  cmp al,03h
  jne @No_e03
    or  ah,ah
    jnz @NoTlast
      mov ah, [B MInstEff2+si+0]
    @NoTlast:
    mov cx,[W MInstEff2+si+1]     ;keine Note angegeben->letze hernehmen
    mov bx,[W MInstVol+si+1]
    mov al,26h                   ;26h=Tone Portamento up
    cmp bx,cx
    jae @TSlideDn
     mov al,28h                  ;28h=Tone Portamento dn
    @TSlideDn:
    mov [B MInstVol+si+3],al
    mov [B MInstEff2+si+0],ah
    jmp @EndEffects
  @No_e03:

  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 2Eh Vibrato...    ²²±°
  cmp al,04h
  jne @No_e04
   mov al,ah
   and al,00Fh
   and ah,0F0h
   or al,al
   jne @nolast104
    mov al, [B MInstEff1+si+3]
    and al, 00Fh
   @nolast104:
   or ah,ah
   jne @nolast204
    mov ah, [B MInstEff1+si+3]
    and ah, 0F0h
   @nolast204:
   add ah,al
   mov [B MInstEff1+si+3],ah
   mov al,2Eh
   mov [B MInstVol+si+3],al
   jmp @EndEffects
  @No_e04:
  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Portamento to Note + Volume Sliding ÄÄÄÄÄÄÄÄ
  cmp al,05h
  jne @No_e05

    cmp ah,0
    Jne @No0Vol05
     mov cl,[B MInstEff3+Si+2]   ;Load Direction=Jump Index!
     jmp @VolReady05
    @No0Vol05:
     mov cl,3Ch         ;3Ch=Porta Up + Volume Slide Dn
    cmp ah,15
    jbe @Vol_U05
     mov cl,3Ah         ;3Ah=Porta Dn + Volume Slide Up
     shr ah,4
    @Vol_U05:
    mov [B MInstEff3+Si+2],cl    ;Save Direction!
    mov [B MInstEff1+Si+0],ah    ;Save Slide-Speed
    @VolReady05:

    mov ah, [B MInstEff2+si+0]
    mov dx,[W MInstEff2+si+1]     ;keine Note angegeben->letze hernehmen
    mov bx,[W MInstVol+si+1]
    cmp bx,dx
    jae @TSlideDn05
     add cl,4h                  ;3Eh,40h = Porta Dn!
    @TSlideDn05:


    mov [B MInstVol+Si+3],cl     ;Save Jump Index
    jmp @EndEffects

  @No_e05:

  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Vibrato + Volume Sliding            ÄÄÄÄÄÄÄÄ
  cmp al,06h
  jne @no_e06
    cmp ah,0
    Jne @No0Vol06
     mov cl,[B MInstEff3+Si+2]
     jmp @VolReady06
    @No0Vol06:
     mov cl,44h         ;44h=Vibrato+Volume Slide Dn
    cmp ah,15
    jbe @Vol_U06
     mov cl,42h         ;42h=Vibrato+Volume Slide Up
     shr ah,4
    @Vol_U06:
    mov [B MInstEff3+Si+2],cl      ;Save Direction!
    mov [B MInstEff1+Si+0],ah
    @VolReady06:
    mov [B MInstVol+Si+3],cl   ;42h=Vib+VolumeSlide up, 44h=Vib+VolumeSlide dn

    mov ah, [B MInstEff1+si+3] ;Vibrato Params
    mov [B MInstEff1+si+3],ah
    jmp @EndEffects
  @No_e06:
  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 20h Arpeggio (Precalced)   ²²±°
  cmp al,08h
  jne @no_e08
   mov [B MInstEff3+si],ah
   mov [B MInstEff3+si+1],0
   mov al,[B gs:edi+1]
   mov [B MInstEff2+si+3],al
   mov [B MInstVol+Si+3],20h
  @no_e08:

  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Set Sample Offset                   ÄÄÄÄÄÄÄÄ
  cmp al,09h
  jne @No_e09
    xor al,al
    mov [W MInstPos+si+2],ax
     jmp @EndEffects
  @No_e09:

  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 2Ah/2Ch Volume Slide Up/Dn ²²±°
  cmp al,10
  jne @no_e10
    cmp ah,0
    Jne @No0Vol0A
     mov cl,[B MInstEff3+Si+2]   ;Load Direction=Jump Index!
     jmp @VolReady0A
    @No0Vol0A:
     mov cl,2Ch         ;2Ch=Volume Slide Dn
    cmp ah,15
    jbe @Vol_U0A
     mov cl,2Ah         ;2Ah=Volume Slide Up
     shr ah,4
    @Vol_U0A:
    mov [B MInstEff3+Si+2],cl    ;Save Direction!
    mov [B MInstEff1+Si+0],ah    ;Save Slide-Speed
    @VolReady0A:
    mov [B MInstVol+Si+3],cl     ;Save Jump Index
    jmp @EndEffects
  @no_e10:

  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Jump Pattern                        ÄÄÄÄÄÄÄÄ
  cmp al,11
  jne @no_e11
    dec ah
    mov [patnum],ah
    mov bl,ah
    mov [patternline],63
    jmp @EndEffects
  @no_e11:

  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Volume Set                          ÄÄÄÄÄÄÄÄ
  cmp al,12
  jne @no_e12
    cmp ah,63
    jbe @NoOverflow
     mov ah,63
    @NoOverflow:
    mov [B MInstVol+si],ah
    jmp @EndEffects
  @no_e12:

  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Pattern Break                       ÄÄÄÄÄÄÄÄ
  cmp al,13
  jne @no_e13
    mov [patternline],63
    jmp @EndEffects
  @no_e13:
  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Cascaded Effect 14 (0Eh)            ÄÄÄÄÄÄÄÄ
  cmp al,14
  jne @no_e14
    mov bl,ah
    shr bl,4
    and ah,15
        ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Retrigger Note ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    cmp bl,9
    jne @no_eE9
      mov [B MInstVol+si+3],36h      ;36=Retrigger Note
      mov [B MInstEff3+si+0],ah
      mov [B MInstEff3+si+1],ah
      jmp @EndEffects
    @no_eE9:
    jmp @EndEffects
  @no_e14:
  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Set Speed                           ÄÄÄÄÄÄÄÄ
  cmp al,15
  jne @no_e15
  ; and ah,0Fh
    mov [Speed],ah
  @no_e15:
  @EndEffects:
  cmp si,0
 jne @NTrackLoop


 ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 ; Ab hier Effects, die jedes Tick ver„ndert werden mssen                  ;
 ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 jmp @NewLineTimer
 @NoNewLine:

 mov si,16
 @TickTracks:
  Sub si,4                      ; K”nnte optimiert werden-> man spart ein CMP
   xor bh,bh
   mov bl,[B MInstVol+Si+3]

   jmp [cs:MInstJump+bx]
   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 20h Arpeggio...   ²²±°
   @Arpeggio_20:
    xor bh,bh
    mov al,[B MInstEff3+si+1]
    ;---
    cmp al,0
    jne @NoTick0
     @nx0:
     mov bl,[B MInstEff2+si+3]
     mov ax,[W ModOctave+bx]

     mov cx,8363                        ;Finetune
     mul cx
     mov bl, [B MInstEff3+si+3]
     mov bx, [FineTunes+bx]
     div bx
     mov cx,ax

     xor edx, edx
     mov eax, SampleConst
     div ecx
     mov [MInstInc+Si],eax
     mov [B MInstEff3+si+1],1
     jmp @No_Tick_Effect
    @NoTick0:
    ;---
    cmp al,1
    jne @NoTick1
     mov bl,[B MInstEff3+si]
     shr bl,4
     shl bl,1
     jz @nx2
     add bl,[B MInstEff2+si+3]
     mov ax,[W ModOctave+bx]

     mov cx,8363                        ;Finetune
     mul cx
     mov bl, [B MInstEff3+si+3]
     mov bx, [FineTunes+bx]
     div bx
     mov cx,ax

     xor edx, edx
     mov eax, SampleConst
     div ecx
     mov [MInstInc+Si],eax
     mov [B MInstEff3+si+1],2
     jmp @No_Tick_Effect
    @NoTick1:
    ;---
    cmp al,2
    jne @NoTick2
     @nx2:
     mov bl,[B MInstEff3+si]
     and bl,00Fh
     shl bl,1
     jz @nx0
     add bl,[B MInstEff2+si+3]
     mov ax,[W ModOctave+bx]

     mov cx,8363                        ;Finetune
     mul cx
     mov bl, [B MInstEff3+si+3]
     mov bx, [FineTunes+bx]
     div bx
     mov cx,ax

     xor edx, edx
     mov eax, SampleConst
     div ecx
     mov [MInstInc+Si],eax
     mov [B MInstEff3+si+1],0
     jmp @No_Tick_Effect
    @NoTick2:
    jmp @No_Tick_Effect

   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 22h Portamento up ²²±°
   @Portamento_22:
     xor edx,edx
     xor ebx,ebx
     mov al,[B MInstEff1+Si+1]
     cbw
     mov bx,[W MInstVol+Si+1]   ;MomNote
     sub bx,ax
     or  bx,bx
     jge @Porta22ok             ;Wenn Nicht negativ
      mov bx,0
     @Porta22ok:
     mov [W MInstVol+Si+1],bx    ;MomNote
     mov eax, SampleConst
     div ebx
     mov [MInstInc+Si],eax
   jmp @No_Tick_Effect

   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 24h Portamento dn ²²±°
   @Portamento_24:
     xor edx,edx
     xor ebx,ebx
     mov al,[B MInstEff1+Si+2]
     cbw
     mov bx,[W MInstVol+Si+1]   ;MomNote
     add bx,ax
     cmp bx,0FF00h              ;Wenn kleiner
     jbe @Porta24ok
      mov bx,0FF00h
     @Porta24ok:
     mov [W MInstVol+Si+1],bx    ;MomNote
     mov eax, SampleConst
     div ebx
     mov [MInstInc+Si],eax
   jmp @No_Tick_Effect

   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 26h Tone Portamento up ²²±°
   @Portamento_26:
     xor edx,edx
     xor ebx,ebx
     mov al,[B MInstEff2+Si+0]
     xor ah,ah
     mov bx,[W MInstVol+Si+1]    ;MomNote
     mov bp,[W MInstEff2+Si+1]   ;EndNote
     sub bx,ax
     js  @TPOverflow
     cmp bx,bp
     jae @Porta28ok
      @TPOverflow:
      mov bx,bp
     @Porta28ok:
     mov [W MInstVol+Si+1],bx    ;MomNote
     mov eax, SampleConst
     div ebx
     mov [MInstInc+Si],eax
   jmp @No_Tick_Effect

   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 28h Tone Portamento dn ²²±°
   @Portamento_28:
     xor edx,edx
     xor ebx,ebx
     mov al,[B MInstEff2+Si+0]
     xor ah,ah
     mov bx,[W MInstVol+Si+1]   ;MomNote
     mov bp,[W MInstEff2+Si+1]   ;EndNote
     add bx,ax
     cmp bx,bp
     jbe @Porta26ok
      mov bx,bp
     @Porta26ok:
     mov [W MInstVol+Si+1],bx    ;MomNote
     mov eax, SampleConst
     div ebx
     mov [MInstInc+Si],eax
   jmp @No_Tick_Effect

   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 2Ah Volume Slide up ²²±°
   @VolumeSlide_2A:
    mov al,[B MInstEff1+si+0]
    mov ah,[B MInstVol+si]
    add ah,al
    cmp ah,63
    jbe @NoOverflow2A
     mov ah,63
    @NoOverflow2A:
    mov [B MInstVol+si],ah
   jmp @No_Tick_Effect

   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 2Ch Volume Slide dn ²²±°
   @VolumeSlide_2C:
    mov al,[B MInstEff1+si+0]
    mov ah,[B MInstVol+si]
    sub ah,al
    or  ah,ah
    jns @NoOverflow2C
     xor ah,ah
    @NoOverflow2C:
    mov [B MInstVol+si],ah
   jmp @No_Tick_Effect
   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 2Eh Vibrato         ²²±°
   @Vibrato_2E:
    mov al,[B MInstEff1+si+3]
    mov cl,al
    and cl,0Fh
    shr al,4
    xor ch,ch

    xor bh,bh
    mov bl,[B MInstEff3+Si]
    add bl,al
    and bl,63
    mov [B MInstEff3+Si],bl

    shl bx,1
    xor dx,dx
    mov ax,[W Vibratotable+bx]
    mul cx
    sar ax,8

    add ax,[W MInstVol+Si+1]

    xor ebx,ebx
    mov bx,ax
    xor edx,edx
    mov eax,SampleConst
    div ebx
    mov [MInstInc+si],eax
   jmp @No_Tick_Effect
   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 36h Retrigger Note ²²±°
   @RetriggerNote_36:
     dec [B MInstEff3+si+0]
     jnz @No_Tick_Effect
     mov al, [B MInstEff3+si+1]
     mov [B MInstEff3+si+0],al
     mov [W MInstPos+si+2],0
   jmp @No_Tick_Effect

   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² Double Effects..... ²²±°

   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 3Ah PortaVSlideUpUp ²²±°
   @PortaVSlideUpUp:
    mov al,[B MInstEff1+si+0]
    mov ah,[B MInstVol+si]
    add ah,al
    cmp ah,63
    jbe @NoOverflow3A
     mov ah,63
    @NoOverflow3A:
    mov [B MInstVol+si],ah

     xor edx,edx
     xor ebx,ebx
     mov al,[B MInstEff2+Si+0]
     xor ah,ah
     mov bx,[W MInstVol +Si+1]   ;MomNote
     mov bp,[W MInstEff2+Si+1]   ;EndNote
     sub bx,ax
     js  @TPOverflow3A
     cmp bx,bp
     jae @Porta3Aok
      @TPOverflow3A:
      mov bx,bp
     @Porta3Aok:
     mov [W MInstVol+Si+1],bx    ;MomNote
     mov eax, SampleConst
     div ebx
     mov [MInstInc+Si],eax

   jmp @No_Tick_Effect
   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 3Ch PortaVSlideUpDn ²²±°
   @PortaVSlideUpDn:
    mov al,[B MInstEff1+si+0]
    mov ah,[B MInstVol+si]
    sub ah,al
    or  ah,ah
    jns @NoOverflow3C
     xor ah,ah
    @NoOverflow3C:
    mov [B MInstVol+si],ah

     xor edx,edx
     xor ebx,ebx
     mov al,[B MInstEff2+Si+0]
     xor ah,ah
     mov bx,[W MInstVol +Si+1]   ;MomNote
     mov bp,[W MInstEff2+Si+1]   ;EndNote
     sub bx,ax
     js  @TPOverflow3C
     cmp bx,bp
     jae @Porta3Cok
      @TPOverflow3C:
      mov bx,bp
     @Porta3Cok:
     mov [W MInstVol+Si+1],bx    ;MomNote
     mov eax, SampleConst
     div ebx
     mov [MInstInc+Si],eax

   jmp @No_Tick_Effect
   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 3Eh PortaVSlideDnUp ²²±°
   @PortaVSlideDnUp:
    mov al,[B MInstEff1+si+0]
    mov ah,[B MInstVol+si]
    add ah,al
    cmp ah,63
    jbe @NoOverflow3E
     mov ah,63
    @NoOverflow3E:
    mov [B MInstVol+si],ah

     xor edx,edx
     xor ebx,ebx
     mov al,[B MInstEff2+Si+0]
     xor ah,ah
     mov bx,[W MInstVol+Si+1]   ;MomNote
     mov bp,[W MInstEff2+Si+1]   ;EndNote
     add bx,ax
     cmp bx,bp
     jbe @Porta3Eok
      mov bx,bp
     @Porta3Eok:
     mov [W MInstVol+Si+1],bx    ;MomNote
     mov eax, SampleConst
     div ebx
     mov [MInstInc+Si],eax
   jmp @No_Tick_Effect

   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 40h PortaVSlideDnDn ²²±°
   @PortaVSlideDnDn:
    mov al,[B MInstEff1+si+0]
    mov ah,[B MInstVol+si]
    sub ah,al
    or  ah,ah
    jns @NoOverflow40
     xor ah,ah
    @NoOverflow40:
    mov [B MInstVol+si],ah

     xor edx,edx
     xor ebx,ebx
     mov al,[B MInstEff2+Si+0]
     xor ah,ah
     mov bx,[W MInstVol+Si+1]   ;MomNote
     mov bp,[W MInstEff2+Si+1]   ;EndNote
     add bx,ax
     cmp bx,bp
     jbe @Porta40ok
      mov bx,bp
     @Porta40ok:
     mov [W MInstVol+Si+1],bx    ;MomNote
     mov eax, SampleConst
     div ebx
     mov [MInstInc+Si],eax
   jmp @No_Tick_Effect

   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 42h Vib+VolSlideUp  ²²±°
   @VibVSlideUp_42:
    mov al,[B MInstEff1+si+0]
    mov ah,[B MInstVol+si]
    add ah,al
    cmp ah,63
    jbe @NoOverflow42
     mov ah,63
    @NoOverflow42:
    mov [B MInstVol+si],ah
    ;Vibrato---
    mov al,[B MInstEff1+si+3]
    mov cl,al
    and cl,0Fh
    shr al,4
    xor ch,ch
    xor bh,bh
    mov bl,[B MInstEff3+Si]
    add bl,al
    and bl,63
    mov [B MInstEff3+Si],bl
    shl bx,1
    xor dx,dx
    mov ax,[W Vibratotable+bx]
    mul cx
    sar ax,7
    add ax, [W MInstVol+Si+1]
    xor ebx,ebx
    mov bx,ax
    xor edx,edx
    mov eax,SampleConst
    div ebx
    mov [MInstInc+si],eax
   jmp @No_Tick_Effect

   ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °±²² 44h Vib+VolSlideDn  ²²±°
   @VibVSlideDn_44:
    mov al,[B MInstEff1+si+0]
    mov ah,[B MInstVol+si]
    sub ah,al
    or  ah,ah
    jns @NoOverflow44
     xor ah,ah
    @NoOverflow44:
    mov [B MInstVol+si],ah
    ;Vibrato---
    mov al,[B MInstEff1+si+3]
    mov cl,al
    and cl,0Fh
    shr al,4
    xor ch,ch
    xor bh,bh
    mov bl,[B MInstEff3+Si]
    add bl,al
    and bl,63
    mov [B MInstEff3+Si],bl
    shl bx,1
    xor dx,dx
    mov ax,[W Vibratotable+bx]
    mul cx
    sar ax,7
    add ax, [W MInstVol+Si+1]
    xor ebx,ebx
    mov bx,ax
    xor edx,edx
    mov eax,SampleConst
    div ebx
    mov [MInstInc+si],eax
   jmp @No_Tick_Effect


   @No_Tick_Effect:
  Cmp si,0
 jne @TickTracks
 @NewLineTimer:
 Call sbMix2
 Mov [NewCli],0
 @SkipTimer:


 inc [OTimerInc]
 cmp [OTimerInc],3
 jne @NoOldTimer
  mov [OTimerInc],0
  int 071h
 @NoOldTimer:

 mov ax,020h
 mov dx,ax
 out dx,al

 pop ds
 pop gs
 pop es
Popad
popf
IRet
EndP


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; Precalculations before Playing ( actually only Arpeggio )
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

;Byte 0 [þþþþ][þþþþ]
;        HInst HNote
;Byte 1 [þþþþþþþþ]
;        LowNote
;Byte 1 [þþþþ][þþþþ]
;        LInst EffNr.
;Byte 3 [þþþþþþþþ]
;        EffByte


PROC PrepareArpeggio
;----
 MACRO ArpChannel Chnl, Lastnote
  local @nonewnote, @noArp, @FindLoop,@OkFound,@nonote
  mov cx,[W es:di+bx+Chnl]
  mov dl,cl
  and dl,0F0h
  and cl,00Fh                   ;cx:Note, dl:highbyte of Inst
  or cx,cx
  jz  @nonewnote
  xchg cl,ch
    xor si,si
    @FindLoop:
     cmp [w ModOctave+si],cx
     jbe @OkFound
     inc si
     inc si
    cmp si,144
    jne @FindLoop
    @OkFound:
    shl si,8
    mov [lastnote],si
  @nonewnote:
  mov ax,[W es:di+bx+Chnl+2]
  and al,0Fh
  or ah,ah
  jz @noArp
   or al,al
   jnz @noArp

    mov ax,[lastnote]
    or cx,cx
    jz @nonote
     mov al,15
    @nonote:
    add al,dl
    mov [W es:di+bx+Chnl],ax
    mov al,[B es:di+bx+Chnl+2]
    and al,0F0h
    add al,8
    mov [B es:di+bx+Chnl+2],al
  @noArp:
 EndM
;----


push es
pusha
 les di,[LoadBuffer]
 xor bx,bx
 @TrackLoop:
  ArpChannel 00,LastNote1
  ArpChannel 04,LastNote2
  ArpChannel 08,LastNote3
  ArpChannel 12,LastNote4
 add bx,16
 cmp bx,1024
 jne @TrackLoop
popa
pop es
Ret
ENDP


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; FlatM - Procs Needed by SB1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

PROC SearchFlat
 mov eax,[FlatPos]
 mov bx, ax
 or bx,bx
 jz @noadd
  add eax,10000h
  xor ax,ax
 @noadd:

 mov [Buffer0],eax
 add eax,22000
 mov [Buffer1],eax
 add eax,22000
 mov [Buffer2],eax
 ret
ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Init SB/Pro at Adr ÄÄ;
PROC FillFlat Pascal FlatP:dword, laenge:word, wert:Byte
 xor ax,ax
 mov gs,ax
 mov ebx,[FlatP]
 mov cx,[laenge]
@FFLoop:
 mov al,[wert]
 mov [B gs:ebx],al
 inc ebx
 inc di
loop @FFLoop
Ret
ENDP

IFDEF TPUsed

 PROC WriteFlat Pascal FlatP:dword, Memory:dword, laenge:word
 push es
  les di,[Memory]
  xor ax,ax
  mov gs,ax
  mov ebx,[FlatP]
  mov cx,[laenge]
 @WFLoop:
  mov al,[B gs:ebx]
  mov [es:di],al
  inc ebx
  inc di
 loop @WFLoop
 pop es
 Ret
 ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Init SB/Pro at Adr ÄÄ;
 PROC ReadFlat Pascal Memory:dword, FlatP:dword, laenge:word
 push es
 pusha
  les di,[Memory]
  xor ax,ax
  mov gs,ax
  mov ebx,[FlatP]
  mov cx,[laenge]
 @RFLoop:
  mov al,[es:di]
  mov [B gs:ebx],al
  inc ebx
  inc di
 loop @RFLoop
 popa
 pop es
 Ret
 ENDP

ENDIF

ENDS

IFDEF TPUsed
 END
ENDIF