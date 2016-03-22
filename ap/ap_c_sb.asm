;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'
;'ЬЫЫЫЫЫЯЯЯЯЫЫЫЫЫЫЬ  ЫЫЫЫЫЫЫЯЯЯЫЫЫЫЫЫЬ  ЯЯЯЯЯЯЯЯЯЯЫЫЫЫЫЫЬ ALPINE PLAYER V3.00'
;'ЫЫЫЫЫЫ    ЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫ   ЫЫЫЫЫЫЫ          ЯЯЫЫЫЫЫЫЫ  (C) 1997          '
;'ЫЫЫЫЫЫ ЯЯЯЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫЯЯЯЯЯЯЯЯЯ   ЬЬЬЬЬЬЬЬЬЬЫЫЫЫЫЫЯ by Syrius / Alpine '
;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'
;' TM3 - No Output!                                                          '
;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'


 SBInfo   db " Soundblaster$"
 SB16     db " 16$"
 SBPro    db " Pro$"
 SBOther  db "  . $"
 SBInfo2  db " detected at Port: 2"
  SBPort  db ?
          db "0h IRQ: "
  SBIRQ   db ?
          db " DMA: "
  SBDMA   db ?
          db 13,10,"$"

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     MACRO WDsp Val        ;D: --- ;N: <Val> = Value sent to DSP
     LOCAL @@1
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  push eax edx
  mov dx,[_ADR]
  add dx,0Ch
  @@1:
   in al,dx
   test al,128
  jnz @@1
  mov al,Val
  out dx,al
  pop edx eax
 ENDM

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     MACRO RDsp            ;D: --- ;N: <Val> = Value sent to DSP
     LOCAL @@1
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  push edx
  mov dx,[_ADR]
  add dx,0Eh
  @@1:
   in al,dx
   Test al,128
  jz  @@1
  sub dx,4
  in al,dx
  pop edx
 ENDM

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     MACRO WMixer Reg, Val ; D: --- ;N: <Reg> = MixReg, <Val> = Value
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  push dx ax
  mov dx,[_ADR]
  add dx,04h
  mov al,Reg
  out dx,al
  inc dx
  mov al,Val
  out dx,al
  pop ax dx
 ENDM

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     MACRO RMixer Reg, Dest  ; D: AL ;N: <Reg> = MixReg,
                                     ;   <Dest> opt. Destination
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  push dx
  mov dx,[_ADR]
  add dx,04h
  mov al,Reg
  out dx,al
  inc dx
  in al,dx
  IFNB <Dest>
   mov Dest, al
  ENDIF
  pop dx
 ENDM


;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC InitSB Near  ; D: --- ;N: DX = ADDRESS
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  push ax cx dx
  add dx,06h
  mov al,1
  out dx,al
  mov cx,100
  @l1:
  loop @l1
  xor al,al
  out dx,al
  mov cx,200
  @l2:
  loop @l2
  add dx,08h
  in  al,dx
  pop dx cx ax
  ret
 ENDP

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC DetectBase ; D: --- ;R: [ADR] = 0 (Nothing found) <>0 ( Address )
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  push ax dx
  mov dx,200h
  mov cx,7
  @DB1:
   add dx,10h
   Call InitSB
   add dx,0Ah
   in al,dx
   sub dx,0Ah
   cmp al,0AAh
   je @DB2
  loop @DB1
  mov [_ADR],0
  pop dx ax
  Ret
  @DB2:
   mov [_ADR],dx
  pop dx ax
  Ret
 ENDP

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC InitDMA            ;D: --- ;N: EAX:Linear Address; BX:Num;
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  pushad
  push bx
  push eax
  mov al,4
  add al,[_DMA]
  out 0Ah, al           ;'Mask DMA-Channel
  mov al,cl
  add al,[_DMA]
  out 0Bh, al           ;'Set Mode
  xor al,al
  out 0Ch, al           ;'Clear FlipFlop
  xor ebx,ebx
  xor dh,dh
  mov bl,[_DMA]
  mov dl,[_DMA_ADR+ebx]
  pop eax
  out dx,al             ;'Set Offset Low
  shr eax,8
  out dx,al             ;'Set Offset High
  shr eax,8
  mov dl,[_DMA_PAGE+ebx]
  out dx,al             ;'Set Page
  xor al,al
  out 0Ch, al           ;'Clear FlipFlop
  mov dl,[_DMA_LEN+ebx]
  pop ax
  out dx,al
  shr ax,8
  out dx,al
  mov al,[_DMA]
  out 0Ah,al            ;'DeMask DMA-Channel
  popad
  Ret
ENDP

PUBLIC SBInt_
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC SBInt_ far
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
 pushf
 Pushad
 Push ds es fs gs
IFDEF PMODEASM
  mov dx,[cs:_seldata]
ELSE
  mov dx,_DATA
ENDIF
  mov ds,dx
  mov es,dx
  mov fs,dx
  mov gs,dx

  mov [_IActive],1
  mov dx,[_ADR]
  add dx,0Eh
  in  al,dx

  mov al,0Bh    ;'First PIC for IRQs 2,3,5,7
  out 20h,al
  in  al,20h
  xor dx,dx
  @I1:
   inc dl
   shr al,1
  jne @I1
  dec dl
  mov [_IRQ],dl
  mov al,0Bh    ;'Second PIC for IRQ 10!
  out 0A0h,al
  in al,0A0h
  test al,al
  je @No_PIC_2
   mov [_IRQ],10
   mov al,20h
   out 0A0h,al
  @No_PIC_2:
  mov al,20h
  out 20h,al

 Pop gs fs es ds
 Popad
 popf
 Iretd

ENDP


;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC checkSBSettings_   ; D: AL ;R: AL=0 -> Okay
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  pushad
  mov al,[_IRQ]
  mov [_TIRQ],al
  mov dx,[_ADR]
  Call InitSB
  WDsp 0D3h
  add dx,0Ah
  in al,dx
  cmp al,0AAh
  jne @SBErrorD

  GetSetIRQ [_TIRQ], _IRQ2, SBInt_

  mov cl,[_IRQ]
  mov ah,1
  cmp cl,7
  ja @PIC2
   in  al,21h            ;' Demask IRQs
   mov [_Port21],al
   shl ah,cl
   not ah
   and al,ah
   out 21h,al
   jmp @PIC_OKAY
  @PIC2:
   sub cl,8
   in  al,0A1h
   mov [_PortA1],al
   shl ah,cl
   not ah
   and al,ah
   out 0A1h,al
  @PIC_OKAY:
  mov [_IActive],0
  mov dx,[_ADR]
  Call InitSB
  mov eax,[_DMABuf]
  xor bx,bx          ;'Length=1
  mov cl,48h
  Call InitDMA
  WDsp 14h
  WDsp 00h
  WDsp 00h
  mov ecx,9FFFFh
  @SBC1:
  loopd @SBC1
  cmp [_IActive],0
  je  @SBErrorC

  SetIRQ [_TIRQ], _IRQ2,1
  popad
  mov al,1    ; TRUE
  Ret

  @SBErrorC:
  SetIRQ [_TIRQ], _IRQ2,1

  @SBErrorD:
  popad
  xor al,al   ; FALSE
  Ret
 ENDP

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC detectSB_   ; D: AL ;R: AL=0 -> Okay
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  pushad
  mov [_DMA],255
  mov [_IRQ],0
  Call DetectBASE
  WDsp 0D3h
  cmp [W _ADR],0
  je  @Error

  GetSetIRQ  2, _IRQ2, SBInt_
  GetSetIRQ  3, _IRQ3, SBInt_
  GetSetIRQ  5, _IRQ5, SBInt_
  GetSetIRQ  7, _IRQ7, SBInt_
  GetSetIRQ 10, _IRQA, SBInt_

  in  al,21h            ;' Demask IRQs
  mov [_Port21],al
  and al,01010011b
  out 21h,al
  in  al,0A1h
  mov [_PortA1],al
  and al,11111011b
  out 0A1h,al

 ;{°° DMA 1 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

  mov dx,[_ADR]
  Call InitSB
  mov [_DMA],1
  mov eax,[_DMABuf]
  xor bx,bx          ;'Length=1
  mov cl,48h
  Call InitDMA
  WDsp 14h
  WDsp 00h
  WDsp 00h
  mov ecx,9FFFFh
  @d1:
  loopd @d1
  cmp [_IRQ],0
  jne @DMAEnd

 ;{°° DMA 0 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  mov dx,[_ADR]
  Call InitSB
  mov [_DMA],0
  mov eax,[_DMABuf]
  xor bx,bx
  mov cl,48h
  Call InitDMA
  WDsp 14h
  WDsp 00h
  WDsp 00h
  mov ecx,9FFFFh
  @d2:
  loopd @d2
  cmp [_IRQ],0
  jne @DMAEnd

 ;{°° DMA 3 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  mov dx,[_ADR]
  Call InitSB
  mov [_DMA],3
  mov eax,[_DMABuf]
  xor bx,bx
  mov cl,48h
  Call InitDMA
  WDsp 14h
  WDsp 00h
  WDsp 00h
  mov ecx,9FFFFh
  @d3:
  loopd @d3
  cmp [_IRQ],0
  jne @DMAEnd
  mov [_DMA],255

  @DMAEnd:
  mov al,[_PORT21]
  out 21h,al
  mov al,[_PORTA1]
  out 0A1h,al
  SetIRQ  2, _IRQ2,1
  SetIRQ  3, _IRQ3,1
  SetIRQ  5, _IRQ5,1
  SetIRQ  7, _IRQ7,1
  SetIRQ 10, _IRQA,1
  cmp [_DMA],255          ;' No DMA found ?
  je @Error

  mov dx,[_ADR]
  add dx,0Ah
  in al,dx

  WDsp 0E1h
  RDsp
  mov ah,al
  RDsp
  mov [_SoundCard],ax
  popad
  mov al,1   ; TRUE
  Ret

 @Error:
  xor eax,eax
  mov [_SoundCard],ax
  popad
  xor al,al  ; FALSE.
  Ret
 ENDP


;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC SBWriteInfo          ; D: eax
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  mov eax,O SBInfo
  Call APPrint
  cmp [_SoundCard],400h
  jb @NoSB16
    mov eax,O SB16
    Call APPrint
    jmp @SBTypeReady
  @NoSB16:
  cmp [_SoundCard],300h
  jb @NoSBPro
    mov eax,O SBPro
    Call APPrint
    jmp @SBTypeReady
  @NoSBPro:
    mov al, [B _SoundCard]
    mov ah,al
    and al,0Fh
    add al,'0'
    mov [SBOther+4],al
    shr ah,4
    add ah,'0'
    mov [SBOther+3],ah
    mov al, [B _SoundCard+1]
    add al,'0'
    mov [SBOther+1],al
    mov eax,O SBOther
    Call APPrint
  @SBTypeReady:
  mov al,[b _ADR]
  shr al,4
  add al,'0'
  mov [SBPort],al
  mov al,[_IRQ]
  add al,'0'
  mov [SBIRQ],al
  mov al,[_DMA]
  add al,'0'
  mov [SBDMA],al
  mov eax,O SBInfo2
  Call APPrint
  Ret
 ENDP

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC SetUpDMA_SB16   ; D: ---
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
   WMixer 22h, 0h
   WDsp 0D1h
   mov eax,O MixMono
   cmp [_Stereo],1
   jne @Mono16_1
    mov eax,O MixStereo
   @Mono16_1:
   mov [MixProc],eax
   SetIRQ [_IRQ], SBInt_
   mov eax,o SetStereo
   IFDEF PMODEASM
    add eax,[_Code32a]
   ENDIF
   xor bx, bx           ;'DMA-Len = 1
   mov cl, 48h
   Call InitDMA         ;'Dummy-љbertragung
   WDsp 014h
   WDsp 00
   WDsp 00              ;'mit L„nge 1
   mov [_IRQ],0

   @Set16_1:
   cmp [_IRQ],0
   je @Set16_1

   SetIRQ [_IRQ], TM3_SB_IRQ
   SetCallBack [_IRQ], _SB_Stub_Buf, [_SB_Callback]

   WDsp 41h
   mov bx,[_SamplingRate]
   WDsp bh
   WDsp bl
   mov eax,[_DMABuf]
   IFDEF PMODEASM
     add eax,[_Code32a]
   ENDIF
   mov bx, [_MaxSampleBytes]
   shl ebx,2               ;' QuadroBuf
   cmp [_Stereo],1
   jne @Mono16_2
    shl ebx,1              ;' Stereo
   @Mono16_2:
   dec bx
   mov cl,58h
   Call InitDMA


   mov bx,[_MaxSampleBytes]
   xor ah,ah
   cmp [_Stereo],1
   jne @Mono16_3
    shl bx,1               ;' Stereo
    mov ah,20h
   @Mono16_3:
   WDsp 0C6h               ;' Set Transfer Mode.
   WDsp ah
   dec bx
   WDsp bl                 ;' Set Blocklength
   WDsp bh
   WDsp 90h

   @Set16_2:
    cmp [_PatternLine],0    ;' Wait for 1st PatternLine.
   jne @Set16_2
   WMixer 22h, 0FFh
   Ret
 ENDP

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC SetUpDMA_SBPro  ; D: ---
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
   WMixer 22h, 0h
   WDsp 0D1h
   WMixer 0Ch,00100001b

   mov bl, 00010001b
   mov eax,O MixMono
   cmp [_stereo],1
   jne @MonoPro_1
    mov eax,O MixStereo
    or bl,2
   @MonoPro_1:
   WMixer 0Eh, bl        ;'Init Stereo/Mono, Turn off Filter

   mov [MixProc],eax
   mov [_IActive],0
   SetIRQ [_IRQ], SBInt_
   mov eax,o SetStereo
   IFDEF PMODEASM
     add eax,[_Code32a]
   ENDIF
   mov bx, 0            ;'DMA-Len = 1
   mov cl, 48h
   Call InitDMA         ;'Dummy-љbertragung
   WDsp 014h
   WDsp 00
   WDsp 00              ;'mit L„nge 1

   @SetPro_1:
    cmp [_IActive],0    ;'<>0 -> Indikator -> Interrupt ok.
   je @SetPro_1

   mov dx,[_ADR]
   add dx,0Eh
   in al,dx

   SetIRQ [_IRQ], TM3_SB_IRQ
   SetCallBack [_IRQ], _SB_Stub_Buf, [_SB_CallBack]

   mov eax,[_DMABuf]
   IFDEF PMODEASM
    add eax,[_Code32a]
   ENDIF
   mov bx,[_MaxSampleBytes]
   shl ebx,2                 ;' QuadroBuf
   cmp [_Stereo],1
   jne @MonoPro_2
    shl ebx,1
   @MonoPro_2:
   dec ebx
   mov cl,58h
   Call InitDMA

   xor edx,edx
   mov eax,0F424000h
   xor ebx,ebx
   mov bx,[_SamplingRate]
   cmp [_Stereo],1
   jne @MonoPro_3
    shl ebx,1
   @MonoPro_3:
   div ebx
   neg ax
   WDsp 40h
   WDsp ah
   WDsp 48h
   mov bx,[_MaxSampleBytes]
   cmp [_Stereo],1
   jne @MonoPro_4
    shl ebx,1
   @MonoPro_4:
   dec bx
   WDsp bl
   WDsp bh
   WDsp 90h

   @SetPro_2:
    cmp [_PatternLine],0
   jle @SetPro_2
   WMixer 22h, 0FFh
   Ret
 ENDP

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC SetUpDMA_SB201  ; D: ---
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
   mov [MixProc],O MixMono
   SetIRQ [_IRQ], TM3_SB_IRQ
   SetCallBack [_IRQ], _SB_Stub_Buf, [_SB_CallBack]
   mov eax,[_DMABuf]
   IFDEF PMODEASM
     add eax,[_Code32a]
   ENDIF
   mov bx, [_MaxSampleBytes]
   shl bx,2                  ;' QuadroBuf
   dec bx
   mov cl,58h
   Call InitDMA
   WDsp 0D1h
   xor edx,edx
   mov eax,0F424000h
   xor ebx,ebx
   mov bx,[_SamplingRate]
   div ebx
   neg ax
   WDsp 40h
   WDsp ah
   WDsp 48h
   mov bx,[_MaxSampleBytes]
   dec bx
   WDsp bl
   WDsp bh
   WDsp 90h

   @Set201_1:
    cmp [_PatternLine],0
   jne @Set201_1

   Ret
 ENDP

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC SetUpDMA_SB200  ; D: ---
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
   mov [MixProc],O MixMono
   SetIRQ [_IRQ], TM3_SB_IRQ
   SetCallBack [_IRQ], _SB_Stub_Buf, [_SB_CallBack]
   mov eax,[_DMABuf]
   IFDEF PMODEASM
     add eax,[_Code32a]
   ENDIF
   mov bx, [_MaxSampleBytes]
   shl bx,2
   dec bx
   mov cl,58h
   Call InitDMA
   WDsp 0D1h
   xor edx,edx
   mov eax,0F424000h
   xor ebx,ebx
   mov bx,[_SamplingRate]
   div ebx
   neg ax
   WDsp 40h
   WDsp ah
   WDsp 48h
   mov bx,[_MaxSampleBytes]
   dec bx
   WDsp bl
   WDsp bh
   WDsp 1Ch

   @Set200_1:
    cmp [_PatternLine],0
   jne @Set200_1
   Ret
 ENDP

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC SetUpSB         ; D: ---
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  mov dx,[_ADR]
  Call InitSB
  mov cl,[_IRQ]
  cmp cl,10
  jae @I10
   in al,21h
   mov [_PORT21],al
   mov ah,1
   shl ah,cl
   not ah
   and al,ah
   out 21h, al
   jmp @EndMsk
  @I10:
   in  al,0A1h
   mov [_PORTA1],al
   and al,11111011b
   out 0A1h, al
  @EndMsk:

  GetSetIRQ [_IRQ], _SB_OldIRQ, SBInt_

  cmp [_SoundCard],400h
  jb @NoSB16Detected
   Call SetUpDMA_SB16
   Ret
  @NoSB16Detected:
  cmp [_SoundCard],300h
  jb @NoSBProDetected
   Call SetUpDMA_SBPro
   Ret
  @NoSBProDetected:
  cmp [_SoundCard],201h
  jb @NoSB201Detected
   Call SetUpDMA_SB201
   Ret
  @NoSB201Detected:
  cmp [_SoundCard],200h
  jb @NoSBDetected
   Call SetUpDMA_SB200
   Ret

  Ret
 ENDP

;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
     PROC StopSB
;(*ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);
  cmp [_SoundCard],0
  je @NothingToDo
  mov al,5
  out 0Ah,al           ;' Stop DMA-Tranfer!
  mov dx,[_ADR]
  Call InitSB
  cmp [_IRQ],10
  je @DeIRQ10
   mov al,[_PORT21]
   out 21h,al
   jmp @EndDeMASK
  @DeIRQ10:
   mov al,[_PORTA1]
   out 0A1h,al
  @EndDeMASK:

  SetIRQ [_IRQ], _SB_OldIRQ,1
  UnCallBack [_IRQ], [_SB_CallBack]
  WDsp 0D3h
  @NothingToDo:
  mov [_IRQ_Finished],1
  Ret
 ENDP

