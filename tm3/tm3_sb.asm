;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;'ßßßßßßßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßÛßÛÛÛÛÛÛÜ	ßßßßßßßßßßÛÛÛÛÛÛÜ THE MODULE V3.00á  '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ ß ÛÛÛÛÛÛÛ		ßßÛÛÛÛÛÛÛ  (C) Spring 1997   '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ	ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß by Syrius / Alpine '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;' HARDWARE-ROUTINES                                                         '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

 Dma_Page  db 87h,83h,81h,81h
 Dma_Adr   db 00 ,02, 04, 06
 Dma_Len   db 01 ,03 ,05, 07
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

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     MACRO WDsp Val        ;D: --- ;N: <Val> = Value sent to DSP
     LOCAL @@1
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  push eax edx
  mov dx,[ADR]
  add dx,0Ch
  @@1:
   in al,dx
   test al,128
  jnz @@1
  mov al,Val
  out dx,al
  pop edx eax
 ENDM

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     MACRO RDsp            ;D: --- ;N: <Val> = Value sent to DSP
     LOCAL @@1
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  push edx
  mov dx,[ADR]
  add dx,0Eh
  @@1:
   in al,dx
   Test al,128
  jz  @@1
  sub dx,4
  in al,dx
  pop edx
 ENDM

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     MACRO WMixer Reg, Val ; D: --- ;N: <Reg> = MixReg, <Val> = Value
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  push dx ax
  mov dx,[ADR]
  add dx,04h
  mov al,Reg
  out dx,al
  inc dx
  mov al,Val
  out dx,al
  pop ax dx
 ENDM

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     MACRO RMixer Reg, Dest  ; D: AL ;N: <Reg> = MixReg,
                                     ;   <Dest> opt. Destination
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  push dx
  mov dx,[ADR]
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


;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC InitSB Near  ; D: --- ;N: DX = ADDRESS
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
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

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC DetectBase ; D: --- ;R: [ADR] = 0 (Nothing found) <>0 ( Address )
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
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
  mov [ADR],0
  pop dx ax
  Ret
  @DB2:
   mov [ADR],dx
  pop dx ax
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC InitDMA            ;D: --- ;N: EAX:Linear Address; BX:Num;
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pusha
  push bx
  push eax
  mov al,4
  add al,[DMA]
  out 0Ah, al           ;'Mask DMA-Channel
  mov al,cl
  add al,[DMA]
  out 0Bh, al           ;'Set Mode
  xor al,al
  out 0Ch, al           ;'Clear FlipFlop
  xor bh,bh
  xor dh,dh
  mov bl,[DMA]
  mov dl,[DMA_ADR+bx]
  pop eax
  out dx,al             ;'Set Offset Low
  shr eax,8
  out dx,al             ;'Set Offset High
  shr eax,8
  mov dl,[DMA_PAGE+bx]
  out dx,al             ;'Set Page
  xor al,al
  out 0Ch, al           ;'Clear FlipFlop
  mov dl,[DMA_LEN+bx]
  pop ax
  out dx,al
  shr ax,8
  out dx,al
  mov al,[DMA]
  out 0Ah,al            ;'DeMask DMA-Channel
  popa
  Ret
ENDP


;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC SBInt
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
 pushf
 Pushad
 Push ds
  mov dx,[_Seldata]
  mov ds,dx
  mov dx,[ADR]
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
  mov [IRQ],dl
  mov al,0Bh    ;'Second PIC for IRQ 10!
  out 0A0h,al
  in al,0A0h
  test al,al
  je @No_PIC_2
   mov [IRQ],10
   mov al,20h
   out 0A0h,al
  @No_PIC_2:
  mov al,20h
  Out 20h,al
 Pop ds
 Popad
 popf
 Iretd
ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC SBCheckSettings   ; D: AL ;R: AL=0 -> Okay
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad
  mov dx,[ADR]
  Call InitSB
  add dx,0Ah
  in al,dx
  cmp al,0AAh
  jne @SBErrorC

  cli
   mov bl,[IRQ]
   Call [_GetIrqVect]
   mov [IRQ2],edx
   mov edx, o SBInt
   Call [_SetIrqVect]
  sti

  mov cl,[IRQ]
  mov ah,1
  cmp cl,7
  ja @PIC2
   in  al,21h            ;' Demask IRQs
   mov [Port21],al
   shl ah,cl
   not ah
   and al,ah
   out 21h,al
   jmp @PIC_OKAY
  @PIC2:
   sub cl,8
   in  al,0A1h
   mov [PortA1],al
   shl ah,cl
   not ah
   and al,ah
   out 0A1h,al
  @PIC_OKAY:

  mov dx,[ADR]
  Call InitSB
  xor eax, eax       ;'Length=1
  xor bx,bx
  mov cl,48h
  Call InitDMA
  WDsp 14h
  WDsp 00h
  WDsp 00h
  mov ecx,9FFFFh
  @SBC1:
  loopd @SBC1
  cmp [IRQ],0
  je  @SBErrorC

  popad
  xor al,al
  Ret

  @SBErrorC:
  popad
  mov al,1
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC SBDetect   ; D: AL ;R: AL=0 -> Okay
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad
  mov [DMA],255
  mov [IRQ],0
  Call DetectBASE

  cmp [W ADR],0
  je  @Error

  cli
   mov bl, 2             ;' Set up IRQ 2
  Call [_GetIrqVect]
  mov [IRQ2],edx
  mov edx, o SBInt
  Call [_SetIrqVect]
   mov bl, 3             ;' Set up IRQ 3
  Call [_GetIrqVect]
  mov [IRQ3],edx
  mov edx, o SBInt
  Call [_SetIrqVect]
   mov bl, 5             ;' Set up IRQ 5
  Call [_GetIrqVect]
  mov [IRQ5],edx
  mov edx, o SBInt
  Call [_SetIrqVect]
   mov bl, 7             ;' Set up IRQ 7
  Call [_GetIrqVect]
  mov [IRQ7],edx
  mov edx, o SBInt
  Call [_SetIrqVect]
   mov bl, 10            ;' Set up IRQ 10
  Call [_GetIrqVect]
  mov [IRQA],edx
  mov edx, o SBInt
  Call [_SetIrqVect]
  sti

  in  al,21h            ;' Demask IRQs
  mov [Port21],al
  and al,01010011b
  out 21h,al
  in  al,0A1h
  mov [PortA1],al
  and al,11111011b
  out 0A1h,al

 ;{°° DMA 1 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  mov dx,[ADR]
  Call InitSB
  mov [DMA],1
  xor eax, eax       ;Length=1
  xor bx,bx
  mov cl,48h
  Call InitDMA
  WDsp 14h
  WDsp 00h
  WDsp 00h
  mov ecx,9FFFFh
  @d1:
  loopd @d1
  cmp [IRQ],0
  jne @DMAEnd

 ;{°° DMA 0 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  mov dx,[ADR]
  Call InitSB
  mov [DMA],0
  xor eax,eax
  xor bx,bx
  mov cl,48h
  Call InitDMA
  WDsp 14h
  WDsp 00h
  WDsp 00h
  mov ecx,9FFFFh
  @d2:
  loopd @d2
  cmp [IRQ],0
  jne @DMAEnd

 ;{°° DMA 3 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  mov dx,[ADR]
  Call InitSB
  mov [DMA],3
  xor eax,eax
  xor bx,bx
  mov cl,48h
  Call InitDMA
  WDsp 14h
  WDsp 00h
  WDsp 00h
  mov ecx,9FFFFh
  @d3:
  loopd @d3
  cmp [IRQ],0
  jne @DMAEnd
  mov [DMA],255

  @DMAEnd:
  mov al,[PORT21]
  out 21h,al
  mov al,[PORTA1]
  out 0A1h,al
  cli
   mov bl, 2             ;' Set back IRQ 2
  mov edx,[IRQ2]
  Call [_SetIrqVect]
   mov bl, 3             ;' Set back IRQ 3
  mov edx,[IRQ3]
  Call [_SetIrqVect]
   mov bl, 5             ;' Set back IRQ 5
  mov edx,[IRQ5]
  Call [_SetIrqVect]
   mov bl, 7             ;' Set back IRQ 7
  mov edx,[IRQ7]
  Call [_SetIrqVect]
   mov bl, 10            ;' Set back IRQ 10
  mov edx,[IRQA]
  Call [_SetIrqVect]
  sti
  cmp [DMA],255          ;' No DMA found ?
  je @Error

  mov dx,[ADR]
  add dx,0Ah
  in al,dx

  WDsp 0E1h
  RDsp
  mov ah,al
  RDsp
  mov [SBVer],ax
  popad
  clc
  Ret

 @Error:
  xor eax,eax
  mov [SBVer],ax
  popad
  stc
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC SBPrint   ; d: ---- N: eax:ADDR
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
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

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC SBWriteInfo          ; D: eax
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  mov eax,O SBInfo
  Call SBPrint
  cmp [SBVer],400h
  jb @NoSB16
    mov eax,O SB16
    Call SBPrint
    jmp @SBTypeReady
  @NoSB16:
  cmp [SBVer],300h
  jb @NoSBPro
    mov eax,O SBPro
    Call SBPrint
    jmp @SBTypeReady
  @NoSBPro:
    mov al, [B SBVer]
    mov ah,al
    and al,0Fh
    add al,'0'
    mov [SBOther+4],al
    shr ah,4
    add ah,'0'
    mov [SBOther+3],ah
    mov al, [B SBVer+1]
    add al,'0'
    mov [SBOther+1],al
    mov eax,O SBOther
    Call SBPrint
  @SBTypeReady:
  mov al,[b ADR]
  shr al,4
  add al,'0'
  mov [SBPort],al
  mov al,[IRQ]
  add al,'0'
  mov [SBIRQ],al
  mov al,[DMA]
  add al,'0'
  mov [SBDMA],al
  mov eax,O SBInfo2
  Call SBPrint
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC SetUpDMA_SB16   ; D: ---
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
   WMixer 22h, 0h
   WDsp 0D1h
   mov eax,O MixMono
   cmp [Stereo],1
   jne @Mono16_1
    mov eax,O MixStereo
   @Mono16_1:
   mov [MixProc],eax
   cli                  ;'Transfer 1 Byte (?)
    mov bl,[IRQ]
    mov edx, o SBInt
    Call [_SetIrqVect]
   sti
   mov eax,o SetStereo
   add eax,[_Code32a]
   xor bx, bx           ;'DMA-Len = 1
   mov cl, 48h
   Call InitDMA         ;'Dummy-šbertragung
   WDsp 014h
   WDsp 00
   WDsp 00              ;'mit L„nge 1
   mov [IRQ],0

   @Set16_1:
   cmp [IRQ],0
   je @Set16_1

   cli                     ;' Set up actual Interrupt-Handler
    mov bl,[IRQ]
    mov edx, o TM3_SB_IRQ
    Call [_SetIrqVect]
    mov edi, o SB_Stub_Buf
    call _rmpmirqset
    mov [SB_CallBack],eax
   sti

   WDsp 41h
   mov bx,[SamplingRate]
   WDsp bh
   WDsp bl
   mov eax,[DMABuf]
   add eax,[_Code32a]
   mov bx, [MaxSampleBytes]
   shl ebx,2               ;' QuadroBuf
   cmp [Stereo],1
   jne @Mono16_2
    shl ebx,1              ;' Stereo
   @Mono16_2:
   dec bx
   mov cl,58h
   Call InitDMA


   mov bx,[MaxSampleBytes]
   xor ah,ah
   cmp [Stereo],1
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
    cmp [PatternLine],0    ;' Wait for 1st PatternLine.
   jne @Set16_2
   WMixer 22h, 0FFh
   Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC SetUpDMA_SBPro  ; D: ---
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
   WMixer 22h, 0h
   WDsp 0D1h

   RMixer 0Eh,bl
   or bl,10h
   and bl,not 2
   mov eax,O MixMono
   cmp [stereo],1
   jne @MonoPro_1
    mov eax,O MixStereo
    or bl,2
   @MonoPro_1:
   mov [MixProc],eax
   WMixer 0Eh, bl	 ;'Init Stereo/Mono, Turn off Filter
   cli
    mov bl,[IRQ]
    mov edx, o SBInt
    Call [_SetIrqVect]
   sti
   mov eax,o SetStereo
   add eax,[_Code32a]
   mov bx, 0            ;'DMA-Len = 1
   mov cl, 48h
   Call InitDMA         ;'Dummy-šbertragung
   WDsp 014h
   WDsp 00
   WDsp 00              ;'mit L„nge 1
   mov [IRQ],0

   @SetPro_1:
    cmp [IRQ],0	        ;'<>0 -> Indikator -> Interrupt ok.
   je @SetPro_1

   mov dx,[ADR]
   add dx,0Eh
   in al,dx

   cli
    mov bl,[IRQ]
    mov edx, o TM3_SB_IRQ
    Call [_SetIrqVect]
    mov edi, o SB_Stub_Buf
    call _rmpmirqset
    mov [SB_CallBack],eax
   sti

   mov eax,[DMABuf]
   add eax,[_Code32a]
   mov bx,[MaxSampleBytes]
   shl ebx,2                 ;' QuadroBuf + Stereo
   cmp [Stereo],1
   jne @MonoPro_2
    shl ebx,1
   @MonoPro_2:
   dec ebx
   mov cl,58h
   Call InitDMA

   xor edx,edx
   mov eax,0F424000h
   xor ebx,ebx
   mov bx,[SamplingRate]
   cmp [Stereo],1
   jne @MonoPro_3
    shl ebx,1
   @MonoPro_3:
   div ebx
   neg ax
   WDsp 40h
   WDsp ah
   WDsp 48h
   mov bx,[MaxSampleBytes]
   cmp [Stereo],1
   jne @MonoPro_4
    shl ebx,1
   @MonoPro_4:
   dec bx
   WDsp bl
   WDsp bh
   WDsp 90h

   @SetPro_2:
    cmp [PatternLine],0
   jne @SetPro_2
   WMixer 22h, 0FFh
   Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC SetUpDMA_SB201  ; D: ---
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
   mov [MixProc],O MixMono
   cli
    mov bl,[IRQ]
    mov edx, o TM3_SB_IRQ
    Call [_SetIrqVect]
    mov edi, o SB_Stub_Buf
    call _rmpmirqset
    mov [SB_CallBack],eax
   sti
   mov eax,[DMABuf]
   add eax,[_Code32a]
   mov bx, [MaxSampleBytes]
   shl bx,2		     ;' QuadroBuf
   dec bx
   mov cl,58h
   Call InitDMA
   WDsp 0D1h
   xor edx,edx
   mov eax,0F424000h
   xor ebx,ebx
   mov bx,[SamplingRate]
   div ebx
   neg ax
   WDsp 40h
   WDsp ah
   WDsp 48h
   mov bx,[MaxSampleBytes]
   dec bx
   WDsp bl
   WDsp bh
   WDsp 90h

   @Set201_1:
    cmp [PatternLine],0
   jne @Set201_1

   Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC SetUpDMA_SB200  ; D: ---
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
   mov [MixProc],O MixMono
   cli
    mov bl,[IRQ]
    mov edx, o TM3_SB_IRQ
    Call [_SetIrqVect]
    mov edi, o SB_Stub_Buf
    call _rmpmirqset
    mov [SB_CallBack],eax
   sti
   mov eax,[DMABuf]
   add eax,[_Code32a]
   mov bx, [MaxSampleBytes]
   shl bx,2
   dec bx
   mov cl,58h
   Call InitDMA
   WDsp 0D1h
   xor edx,edx
   mov eax,0F424000h
   xor ebx,ebx
   mov bx,[SamplingRate]
   div ebx
   neg ax
   WDsp 40h
   WDsp ah
   WDsp 48h
   mov bx,[MaxSampleBytes]
   dec bx
   WDsp bl
   WDsp bh
   WDsp 1Ch

   @Set200_1:
    cmp [PatternLine],0
   jne @Set200_1
   Ret
 ENDP