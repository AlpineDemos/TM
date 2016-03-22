;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;'ÜÛÛÛÛÛßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßßßÛÛÛÛÛÛÜ  ßßßßßßßßßßÛÛÛÛÛÛÜ ALPINE PLAYER V3.00'
;'ÛÛÛÛÛÛ    ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ          ßßÛÛÛÛÛÛÛ  (C) 1997          '
;'ÛÛÛÛÛÛ ßßßÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛßßßßßßßßß   ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß by Syrius / Alpine '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;' AP3 - Mixing Routines                                                     '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

;BORDERS = 1

VOLBARS = 1

;' DON`T FORGET TO DEFINE AP_C / PMODEASM / TM3INC !!!!!!!

INCLUDE "AP_C_SB.ASM"        ;' For AP_C another version of AP_SB needed.

IFDEF PMODEASM
 IFDEF TM3INC                 ;' If TM3 in INC-File -> No TM3-Loader!
  INCLUDE "AP_LOD2.ASM"
 ELSE
  INCLUDE "AP_LOAD.ASM"
 ENDIF
ENDIF

INCLUDE "AP_JMP.ASM"

  CStart      = 00
  CLength     = 04
  CLStart     = 08
  CC2SPD      = 12
  CVolume     = 16
  CMonoVol    = 17
  CVolLeft    = 18
  CVolRight   = 19
  CPanning    = 20
  CStatus     = 21
  CPeriod     = 22
  CCountI     = 24
  CCountF     = 28
  CIncF       = 30
  CIncI       = 32
  CDstPeriod  = 36
  CSmpIndex   = 38
  CNoteIndex  = 39
  CVolumeCol  = 40
  CEffect     = 41
  CFXByte     = 42
  CTickCmd    = 43
  CTickCmd2   = 44
  CWorkByte   = 45
  CWorkByte2  = 46
  CWorkByte3  = 47
  CLastVSld   = 48
  CLastPSldD  = 49
  CLastPSldU  = 50
  CLastTPorta = 51
  CLastVib    = 52
  CLastVibPos = 53
  CLastRetrig = 54
  CLoopStart  = 55
  CLoopCount  = 56

  CVolBar     = 63
  VMAX = 100;

  PlayTM3 EQU PlayTM3_
  StopTM3 EQU StopTM3_
  LoadTM3 EQU LoadTM3_


MACRO QUIT
  SetBorder 0
  Pop fs gs es ds
  Popad
  iret
ENDM

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     MACRO SetBorder Num
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  IFDEF BORDERS
  xor al,al
  mov dx,3c8h
  out dx,al
  inc dx
  mov al,Num
  out dx,al
  out dx,al
  out dx,al
  ENDIF
 ENDM

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
;    TM3_SB_IRQ Exceptions                                                   ;
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
@FinishIRQ:
   Call StopSB
@NoCalcBuf:
  quit

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC TM3_SB_IRQ
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  Pushad
  Push ds es gs fs
   IFDEF PMODEASM
     mov dx,[cs:_seldata]
   ELSE
     mov dx,_DATA
   ENDIF
   mov ds,dx
   mov es,dx
   mov fs,dx
   mov gs,dx

   mov dx,[_ADR]
   add dx,0Eh
   in  al,dx
   sti
   mov al,20h
   Out 20h,al
   out 0A0h,al

   SetBorder 50
   cmp [_IRQ_Stop],1
   je @FinishIRQ
   Xor ebx,ebx

   ;' Play last Tick to End...

   inc [_DMAFlipFlop]
   and [_DMAFlipFlop],3
   jnz @2ndDMABuf
    mov eax,[_DMABuf]
    mov [_C_BufPosition],eax
   @2ndDMABuf:

   mov dx, [_MaxSampleBytes]
   mov [_Bytes2Fill],dx      ;' Buffer-Length reinitialize

   mov ax, [_Bytes4Tick]
   or ax,ax
   jz @SBIRQ_MAINLOOP
   cmp ax, dx
   jb  @NoClipLast
     mov ax, dx
     mov [_C_BPT],ax
     Call [MixProc]
     quit
   @NoClipLast:
   mov [_C_BPT],ax
   Call [MixProc]

   @SBIRQ_MAINLOOP:
   inc [_Ticks]
   mov al,[_Speed]
   cmp [_Ticks],al
   jne @InTicks                 ;' inbetween
    inc [_TM3SyncCount]
    mov [_Ticks],0
    mov bl,[_PatternJMP]        ;' Pattern Jump & Break
    inc bl
    jz  @NoPatternJump
      dec bl
      xor bh,bh
      mov dl, [_PatternROW]
      mov [_PatternLine],dl
      cmp bl,[_SongLen]
      jne @NoExitTM3
        mov bl,[_SongLoop]
        cmp [_LoopIt],0
        jne @NoExitTM3
         mov [_IRQ_Stop],1
         jmp @EndIRQ
      @NoExitTM3:
      mov [_ordnum],bl
      xor eax,eax
      mov al,[_Order+ebx]
      shl ax,2                   ;  DWORD!
      mov edi,[_PTRPattern+EAX]
      mov [_StartPattern],edi
      mov al,5                   ;  Set correct Line..
      mul [_Channels]
      mul dl
      add edi,eax
      mov [_ChPointer],edi
      jmp @NoNewPattern
    @NoPatternJump:

    inc [_PatternLine]
    cmp [_PatternLine],64
    jne @NoNewPattern
     mov [_PatternLine],0
     xor bh,bh
     mov bl,[_OrdNum]
     inc bl
     cmp bl,[_SongLen]
     jne @NoEndTM3
      mov bl,[_SongLoop]
      cmp [_LoopIt],0
      jne @NoEndTM3
       mov [_IRQ_Stop],1
       jmp @EndIRQ
     @NoEndTM3:
     mov [_OrdNum],bl
     xor edx,edx
     mov dl,[_Order+ebx]
     shl edx,2                  ;  DWORD!
     mov edi,[_PTRPattern+EDX]
     mov [_StartPattern],edi
     mov [_ChPointer],edi
    @NoNewPattern:                       ;  Ab hier Tick 0!
     mov ecx,[_ChPointer]
     mov edi,[_CSampleP]
     mov [_PatternJMP],0FFh
     mov al,[_Channels]
     mov [_ChCount],al

    @ChLoop:

     cmp [b ecx+3],15h                  ;' DANGER FineVibrato not handled!
     jne @NoNoteDelay
       cmp [B edi+CTickCmd],06
       jne @NoNDVibrato
        mov bx, [edi+CPeriod] ;'!!! Vibrato finished, no new Note in Line!
        mov eax,[_DivConst]
        xor edx,edx
        div ebx
        mov [d edi+CIncF],eax  ;' Ready.
       @NoNDVibrato:
       mov esi,ecx
       add edi,CSmpIndex
       movsd
       sub edi,CSmpIndex+4
       mov dh,[ecx+4]
       mov [edi+CWorkbyte],dh
       mov [b edi+CTickCmd],08h  ;' Note Delay.
       jmp @ChannelFinished
     @NoNoteDelay:

 ;{°°°° Set Sample °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

     mov bx,[ecx]                 ;' dl = Sample-Index
     or bx,bx
     jz @SkipVolCol
       dec bh
       js @NoNewSample
        mov [edi+CSmpIndex],bh
       @NoNewSample:
       dec bl
       jns @VolumeCol
        mov esi,ebx
        shr esi,8
        mov bl,[_SampleVols+esi]  ;'
       @VolumeCol:
       mov [edi+CVolume],bl       ;' Save Volume
       mov bh,[_GlobalVol]
       mov bl,[_VolTable+ebx]     ;' Adjust to GlobalVolume
       mov [edi+CMonoVol],bl      ;' -> Got MonoVolume
       mov bh,[edi+CPanning]      ;' Get Panning: 0..64
       mov bh,[_Voltable+ebx]     ;' Get Volume Right
       sub bl,bh                  ;' Get Volume Left
       mov [Edi+CVolLeft],bx      ;' Save
       IFDEF VOLBARS
        mov al,[b edi+CVolume]
        mov [b edi+CVolBar], al
       ENDIF

     @SkipVolCol:


 ;{°°°° Set Note/Period °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

     mov bx,[ecx+2]   ;' bh = Effect, bl = Note Index
     or bl,bl
     jnz @ProcessNote
      cmp bh,08h ;' Vibrato-Effect!
      je @NoNote
      cmp bh,09h
      je @NoNote
      cmp [B edi+CTickCmd],06
      je @RestorePitch
      cmp [B edi+CTickCmd],07
      jne @NoNote
      @RestorePitch:
        mov bx, [edi+CPeriod] ;'!!! Vibrato finished, no new Note in Line!
        mov eax,[_DivConst]
        xor edx,edx
        div ebx
        mov [d edi+CIncF],eax  ;' Ready.
        jmp @NoNote
     @ProcessNote:
      sub bl,2
      cmp bl,0FCh     ;' Note Cut ?
      je @CutNote
      mov si,[edi+CSmpIndex]
      and esi,0FFh
      shl esi,4                         ;' * 16 ( SampleBuffer )
      add esi,[_SampleP]
      movsd
      movsd
      movsd
      movsd
      sub edi,16
      cmp bh,07h
      je @FX7_D
      cmp bh,0Dh
      je @FX7_D
      @NoSlide:
      xor eax,eax
      mov [edi+CCountF],ax
      mov [edi+CLastVibPos],al
      cmp bh,0Eh
      jne @NoOffset
       mov al, [ecx+4]
       shl eax,8
      @NoOffset:
      mov [d edi+CCountI],eax
      and ebx,0FFh
      mov [EDI+CNoteIndex],bl
      mov bx,[_OCTAVES+EBX]
      mov eax,[edi+CC2SPD]    ;' C2SPD
      mul ebx                 ;' EDX -> 0!!!                   *MUL*
      shr eax,16
      mov bx,ax               ;' BX = Period
      mov [edi+CDstPeriod],ax ;' Save DestPeriod= Period
      mov [edi+CPeriod],bx    ;' Save Period
      mov eax,[_DivConst]      ;' (14317056 DIV SamplingRate) shl 16 !
      div ebx                 ;' EDX = 0!                     *DIV*
      mov [d edi+CIncF],eax   ;' Ready.
      or  [B edi+CStatus],1   ;' Set Active Channel
      jmp @NoNote
     @FX7_D:
      and ebx,0FFh
      mov [EDI+CNoteIndex],bl
      mov bx,[_OCTAVES+EBX]
      mov eax,[edi+CC2SPD]       ;' C2SPD
      mul ebx                    ;' EDX = 0!!!                   *MUL*
      shr eax,16
      mov [edi+CDstPeriod],ax    ;' Save DestPeriod
      test [B edi+CStatus],1
      jnz @NoNote
       mov bx,ax              ;' BX = Period
       mov [edi+CPeriod],bx   ;' Save DestPeriod
       mov eax,[_DivConst]     ;' (14317056 DIV SamplingRate) shl 16 !
       div ebx                ;' EDX = 0!                     *DIV*
       mov [d edi+CIncF],eax  ;' Ready.
       or  [B edi+CStatus],1  ;' Set Active Channel
       mov [d edi+CCountI],0
       mov [w edi+CCountF],0
       jmp @NoNote
     @CutNote:
      and [B edi+CStatus],254    ;' Cut Active Channel
     @NoNote:

 ;{°°°° Effects °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

     xor ebx,ebx
     mov [edi+CTickCmd],ebx
     mov dx,[ecx+3]
     mov bl,dl
     shl ebx,2
     jmp [JumpTable+ebx]

     INCLUDE "AP_FX1.ASM"

     @ChannelFinished:
     add ecx, 5
     add edi,64
     dec [_ChCount]
    jne @ChLoop
    mov [_ChPointer],ecx

    mov ax,[_BytesPerTick]
    mov [_Bytes4Tick],ax
    mov ax, [_BytesPerTick]
    cmp [_Bytes2Fill], ax
    jbe @ClipIt
     mov [_C_BPT],ax
     Call [MixProc]
     jmp @SBIRQ_MAINLOOP        ;' Calc next Tick.
    @ClipIt:                    ;' End of Buffer in reach.
     mov ax,[_Bytes2Fill]
     mov [_C_BPT],ax
     Call [MixProc]
   @EndIRQ:
  quit

 ;{°°°° Runtime Effects °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

  @InTicks:

   mov edi,[_CSampleP]
   mov al,[_Channels]
   mov [_ChCount],al
   @ChLoopTx:
    xor ebx,ebx
    mov bl,[edi+CTickCmd]
    shl ebx,2                    ;' *4 DWord
    jmp [JumpTableTx+ebx]

    INCLUDE "AP_FX2.ASM"

    @ChannelFinishedTx:
    add edi,64
    dec [_ChCount]
   jne @ChLoopTx

   mov ax,[_BytesPerTick]
   mov [_Bytes4Tick],ax
   mov ax, [_BytesPerTick]
   cmp [_Bytes2Fill], ax
   jbe @ClipIt2
    mov [_C_BPT],ax
    Call [MixProc]
    jmp @SBIRQ_MAINLOOP        ;' Calc next Tick.
   @ClipIt2:                   ;' End of Buffer in reach.
    mov ax,[_Bytes2Fill]
    mov [_C_BPT],ax
    Call [MixProc]
  @EndIRQ2:
  quit

 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC MixSilent   ; D: ---  N: ---     Registers see TM3.DOC
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad
  xor ecx,ecx
  mov cx, [_C_BPT]
  sub [_Bytes2Fill], cx
  sub [_Bytes4Tick], cx
  add [_C_BufPosition],ecx
  popad
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC MIXStereo   ; D: ---  N: ---     Registers see TM3.DOC
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad

  mov al, [_Channels]
  mov [_ChCount], al            ;' Counter -> Only one MOV instead of push/pop
  mov esi, [_CSampleP]
  xor ebx,ebx                   ;' HiWord ALWAYS 0 !!!
  @Loop4Channels:
    test [B esi+CStatus],1      ;' Channel still active ? IT-Compatibility ;)
    jz @NxtChannel
    push esi
    mov cx, [_C_BPT]            ;' 0->439 !
    dec cx
    shl ecx,16
    mov eax, [esi+CStart]       ;' Start
IFNDEF PMODEASM
 ASSUME DS:_TEXT
ENDIF
    mov [d ds:@C1+2],eax        ;
    mov edx,[esi+CLength]       ;' Length
    mov [d ds:@C2+2],edx
    mov ax, [esi+CVolLeft]      ;' Volume Left/Right
    mov [b ds:@C4+1],ah
    mov [b ds:@C5+1],al
IFNDEF PMODEASM
 ASSUME DS:DGROUP
ENDIF
    mov edi,[esi+CCountI]       ;' Counter Integer
    mov cx, [esi+CCountF]       ;' Counter Fract.
    mov dx, [esi+CIncF]         ;' Inc-Factor Fract.
    mov ebp,[esi+CIncI]         ;' Inc-Factor Integer
    mov esi,[_MixBufP]
    jmp @Loop4Sample
     @Loop4Sample:
@C2:   cmp edi, 11111111h       ;' End Reached ?                    ³CoDeMaN³
       jae @LoopSample          ;' If so, jmp to extra Routine
       @SampleLooped:
@C1:   mov bl,[01010101h+EDI]   ;' bl = Sample-Byte                 ³CoDeMaN³
@C4:   mov bh,10h               ;' bh = Volume Left...              ³CoDeMaN³
       mov al,[_VolTable+EBX]   ;' Get effective Sample HIWORD EBX = 0 !
       cbw
       add [ESI],ax
@C5:   mov bh,07h                                                ;' ³CoDeMaN³
       mov al,[_VolTable+EBX]   ;' HIWORD EBX = 0 !
       cbw
       add [ESI+2],ax
       add cx, dx               ;' Add Fractional Part
       adc edi,ebp              ;' Add Integer Part + Carry-Flag
       add Esi,4                ;' Inc MixBuf-Index
       sub ecx,10000h           ;' Dec BytesPerTick  HiWord of ECX! 0-??
     jns @Loop4Sample
    pop esi                     ;' Get CSample-Index
    mov [esi+CCountI],edi
    mov [esi+CCountF],cx
    @NxtChannel:                ;' Guess what.
    add esi,64                  ;' next Channel in CSamples
    dec [_ChCount]              ;' Next channel
  jne @Loop4Channels


;{°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Convert Mixbuffer °°°°°}

  xor eax,eax
  mov ebp,eax
  mov ebx,[_PostProcP]
  mov cx, [_C_BPT]
  sub [_Bytes2Fill], cx
  sub [_Bytes4Tick], cx
  mov esi,[_MixBufP]
  mov edi,[_C_BufPosition]
  @ConvertLoop:
   lodsw
   mov al,[EBX+EAX]
   stosb                        ;' Very nice code, eh ?
   lodsw
   mov [esi-4],ebp
   mov al,[EBX+EAX]
   stosb
   dec cx
  jne @ConvertLoop
  mov [_C_BufPosition],edi

  popad
  Ret

;{°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Loop/Cut Sample °°°°°}

  @LoopSample:
   mov eax,[SS:ESP]             ;' Get CSample-Index
   mov edi,[EAX+CLStart]        ;' Set Loop-Start
   cmp edi,-1                   ;' Loop ?
   jne @SampleLooped            ;' Okay, then jmp back
   and [B EAX+CStatus],254      ;' Else disable Channel...  Mask out bit 1!
   pop esi
   jmp @NxtChannel              ;' ...and goto nxt Channel
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC MIXMono     ; D: ---  N: ---     Registers see TM3.DOC
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad

  mov al, [_Channels]
  mov [_ChCount], al            ;' Counter -> Only one MOV instead of push/pop
  mov esi, [_CSampleP]
  xor ebx,ebx                   ;' HiWord ALWAYS 0 !!!
  @Loop4Channels_M:
    test [B esi+CStatus],1      ;' Channel still active ? IT-Compatibility ;)
    jz @NxtChannel_M
    push esi
    mov cx, [_C_BPT]            ;' 0->439 !
    dec cx
    shl ecx,16
    mov eax, [esi+CStart]       ;' Start
IFNDEF PMODEASM
 ASSUME DS:_TEXT
ENDIF
    mov [d ds:@C1_M+2],eax
    mov edx,[esi+CLength]       ;' Length
    mov [d ds:@C2_M+2],edx
IFNDEF PMODEASM
 ASSUME DS:DGROUP
ENDIF
    mov bh, [esi+CMonoVol]      ;' Volume Left/Right
    mov edi,[esi+CCountI]       ;' Counter Integer
    mov cx, [esi+CCountF]       ;' Counter Fract.
    mov dx, [esi+CIncF]         ;' Inc-Factor Fract.
    mov ebp,[esi+CIncI]         ;' Inc-Factor Integer
    mov esi,[_MixBufP]
    jmp @Loop4Sample_M
     @Loop4Sample_M:
@C2_M: cmp edi, 11111111h       ;' End Reached ?                    ³CoDeMaN³
       jae @LoopSample_M        ;' If so, jmp to extra Routine
       @SampleLooped_M:
@C1_M: mov bl,[01010101h+EDI]   ;' bl = Sample-Byte                 ³CoDeMaN³
       mov al,[_VolTable+EBX]   ;' Get effective Sample HIWORD EBX = 0 !
       cbw
       add [ESI],ax
       add cx, dx               ;' Add Fractional Part
       adc edi,ebp              ;' Add Integer Part + Carry-Flag
       add esi,2                ;' Inc MixBuf-Index
       sub ecx,10000h           ;' Dec BytesPerTick  HiWord of ECX! 0-??
     jns @Loop4Sample_M
    pop esi                     ;' Get CSample-Index
    mov [esi+CCountI],edi
    mov [esi+CCountF],cx
    @NxtChannel_M:              ;' Guess what.
    add esi,64                  ;' next Channel in CSamples
    dec [_ChCount]              ;' Next channel
  jne @Loop4Channels_M


;{°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Convert Mixbuffer °°°°°}

  xor eax,eax
  mov ebp,eax
  mov ebx,[_PostProcP]
  mov cx, [_C_BPT]
  sub [_Bytes2Fill], cx
  sub [_Bytes4Tick], cx
  mov esi,[_MixBufP]
  mov edi,[_C_BufPosition]
  @ConvertLoop_M:
   lodsw
   mov [esi-2],bp
   mov al,[EBX+EAX]
   stosb                        ;' Very nice code, eh ?
   dec cx
  jne @ConvertLoop_M
  mov [_C_BufPosition],edi
  popad
  Ret

;{°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Loop/Cut Sample °°°°°}

  @LoopSample_M:
   mov eax,[SS:ESP]             ;' Get CSample-Index
   mov edi,[EAX+CLStart]        ;' Set Loop-Start
   cmp edi,-1                   ;' Loop ?
   jne @SampleLooped_M          ;' Okay, then jmp back
   and [B EAX+CStatus],254      ;' Else disable Channel...  Mask out bit 1!
   pop esi
   jmp @NxtChannel_M            ;' ...and goto nxt Channel

 Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
    PROC CalcVolTable  ; D:--- N:---   Calculates Volume-Table ( 65*256 Bytes )
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  Xor bx,bx
  mov edi, o _VolTable
  @VolLoop:
   xor cx,cx
   @VolSampleLoop:
     mov al,cl
     imul bl
     sar ax,6
     stosb
     inc cl
   jne @VolSampleLoop
   inc bl
   cmp bl,65
  jne @VolLoop
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC CalcPostProc  ; D:--- N:--- Calculates PostProc-Table 65536 Bytes
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad
  mov edi,[_PostProcP]
  mov eax,0FFFFFFFFh
  mov ecx,8192         ;' * 4 -> EAX
  rep stosd
  xor eax,eax
  mov ecx,8192
  rep stosd            ;' Okay, Table Initialised.
  xor ebx,ebx
  mov bp,[_MasterSpace] ;' BP=Counter!
  shr bp,1
  mov bx,bp
  dec bp               ;' 0 needs not to be calculated.
  xor dx,dx
  mov ax,8000h
  div bx               ;' AX = Inc-Factor ( Steigung der Geraden )

  mov dx,8000h
  mov bx,8000h
  mov edi,[_PostProcP] ;' 2nd Value
  mov [edi],bh         ;' Set 1st
  mov esi,[_PostProcP]
  add esi,65535        ;' Same here.
  @PostLoop:
   inc edi
   add dx,ax
   sub bx,ax
   mov [edi],dh        ;' Positive Part
   mov [esi],bh        ;' Negative Part
   dec esi
   dec bp
  jne @PostLoop
  popad
  Ret
 ENDP


;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC InitTM3
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  mov [_TM3SyncCount],0
  mov [_Bytes4Tick], 0
  mov [_SongLoop],0
  mov [_PatternJMP], 0FFh
  mov [_OrdNum], 255   ;' Force Pattern=0 at beginning
  mov al,[_Speed]
  sub al,5
  mov [_Ticks],al       ;' Force new line at beginning
  mov [_PatternLine],63 ;' Force new Pattern at beginning
  mov [_DMAFlipFlop],3
  mov eax,[_DMABuf]
  mov [_C_BufPosition],eax

;{°°° Calc BytesPerTick °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  mov ax,[_SamplingRate]
  xor dx,dx
  xor bx,bx
  mov bl, [_Tempo]
  div bx                ;' ax= Bytes per second
  mov [_BytesPerTick],ax
  mov [_MaxSampleBytes],ax

;{°°° Calc DivConst.. °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  xor ebx,ebx
  mov bx,[_Samplingrate]
  mov edx,0DAh
  mov eax,77900000h
  div ebx
  mov [_DivConst],eax
;'-------------------------------------------------
  xor eax,eax             ;' Initialize Length for all Channels:
  mov edi,[_CSampleP]
  xor ecx,ecx
  mov cl,[_Channels]
  shl ecx,4
  rep stosd
  xor ebx,ebx
  mov edi,[_CSampleP]
  mov dl,[_Channels]
  @InitChannels:
   mov [d edi+CC2SPD],00010000h
   mov [d edi+CPERIOD],1000h
   mov [d edi+CDSTPERIOD],1000h
   mov ah,[_Panning+ebx]
   mov [edi+CPanning],ah
   add edi,64
   inc ebx
   dec dl
  jne @InitChannels
;' -------------------------------------------------
  mov eax,080808080h
  mov edi, [_DMABuf]
  mov ecx, 16000             ;' HighWord of ECX = 0
  rep stosd

  xor ax,ax
  mov edi, [_MixBufP]
  mov cx, 6891               ;' HighWord of ECX = 0
  rep stosb


;{°°° Miscellaneous... °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}


  Call CalcVolTable
  Call CalcPostProc

  Ret
 ENDP

 SetStereo db 80h        ;' Stereo-Byte to send...

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC PlayTM3_ near
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad

  xor edx,edx
  mov eax,0F424000h
  xor ebx,ebx
  mov bx,[_SamplingRate]
  cmp [_Stereo],1
  jne @GetMonoSMPLRate
   shl ebx,1
  @GetMonoSMPLRate:
  div ebx
  neg ax
  xor al,al
  neg ax
  mov ebx,eax
  xor edx,edx
  mov eax,0F424000h
  div ebx
  cmp [_Stereo],1
  jne @SetMonoSMPLRate
   shr eax,1
  @SetMonoSMPLRate:
  mov [_SamplingRate],ax

  mov [_IRQ_Stop],0
  mov [_IRQ_Finished],0
  Call InitTM3
  cmp [_SoundCard],0
  je @NoSBDetected
   Call SetUpSB
   popad
   mov al,1
   Ret
  @NoSBDetected:
  mov [MixProc],O MixSilent
  popad
  xor al,al
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC StopTM3_ near
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad
  cmp [_IRQ_Finished],1
  je @SongEnded
  mov [_IRQ_Stop],1
  @STLoop:
   cmp [_IRQ_Finished],1
   jne @STLoop
  @SongEnded:
  popad
  Ret
 ENDP