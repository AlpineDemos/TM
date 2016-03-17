;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;'ßßßßßßßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßÛßÛÛÛÛÛÛÜ	ßßßßßßßßßßÛÛÛÛÛÛÜ THE MODULE V3.00á  '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ ß ÛÛÛÛÛÛÛ		ßßÛÛÛÛÛÛÛ  (C) Spring 1997   '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ	ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß by Syrius / Alpine '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;' MiXING-PROCEDURES / MAIN SB-IRQ-ROUTINE                                   '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

;BORDERS = 1

INCLUDE "TM3_SB.ASM"
IFDEF TM3INC
 INCLUDE "TM3_LOD2.ASM"
ELSE
 INCLUDE "TM3_LOAD.ASM"
ENDIF
INCLUDE "TM3_JMP.ASM"

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


MACRO QUIT
   SetBorder 0
  Pop es
  Pop ds
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
;    TM3_SB_IRQ Exceptions 						     ;
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
@FinishIRQ:
   Call QuitTM3
@NoCalcBuf:
  quit

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC TM3_SB_IRQ
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  Pushad
  Push ds
  push es
   mov dx,[cs:_Seldata]
   mov ds,dx
   mov es,dx
   mov dx,[ADR]
   add dx,0Eh
   in  al,dx
   sti
   mov al,20h
   Out 20h,al
   Out 0A0h,al

   SetBorder 50
   cmp [IRQ_Stop],1
   je @FinishIRQ
   Xor ebx,ebx

   ;' Play last Tick to End...

   inc [DMAFlipFlop]
   and [DMAFlipFlop],3
   jnz @2ndDMABuf
    mov eax,[DMABuf]
    mov [C_BufPosition],eax
   @2ndDMABuf:

   mov dx, [MaxSampleBytes]
   mov [Bytes2Fill],dx	     ;' Buffer-Length reinitialize

   mov ax, [Bytes4Tick]
   or ax,ax
   jz @SBIRQ_MAINLOOP
   cmp ax, dx
   jb  @NoClipLast
     mov ax, dx
     mov [C_BPT],ax
     Call [MixProc]
     quit
   @NoClipLast:
   mov [C_BPT],ax
   Call [MixProc]

   @SBIRQ_MAINLOOP:
   inc [Ticks]
   mov al,[Speed]
   cmp [Ticks],al
   jne @InTicks 		;' inbetween
    inc [TM3SyncCount]
    mov [Ticks],0
    mov bl,[PatternJMP] 	;' Pattern Jump & Break
    inc bl
    jz	@NoPatternJump
      dec bl
      xor bh,bh
      mov dl, [PatternROW]
      mov [PatternLine],dl
      cmp bl,[SongLen]
      jne @NoExitTM3
	mov bl,[SongLoop]
	cmp [LoopIt],0
	jne @NoExitTM3
	 mov [IRQ_Stop],1
	 jmp @EndIRQ
      @NoExitTM3:
      mov [CPattern],bl
      xor eax,eax
      mov al,[Order+ebx]
      shl ax,2			 ;  DWORD!
      mov edi,[PTRPattern+EAX]
      mov [StartPattern],edi
      mov al,5			 ;  Set correct Line..
      mul [Channels]
      mul dl
      add edi,eax
      mov [ChPointer],edi
      jmp @NoNewPattern
    @NoPatternJump:

    inc [PatternLine]
    cmp [PatternLine],64
    jne @NoNewPattern
     mov [PatternLine],0
     xor bh,bh
     mov bl,[CPattern]
     inc bl
     cmp bl,[SongLen]
     jne @NoEndTM3
      mov bl,[SongLoop]
      cmp [LoopIt],0
      jne @NoEndTM3
       mov [IRQ_Stop],1
       jmp @EndIRQ
     @NoEndTM3:
     mov [CPattern],bl
     xor edx,edx
     mov dl,[Order+ebx]
     shl edx,2                  ;  DWORD!
     mov edi,[PTRPattern+EDX]
     mov [StartPattern],edi
     mov [ChPointer],edi
    @NoNewPattern:			 ;  Ab hier Tick 0!
     mov ecx,[ChPointer]
     mov edi,[CSampleP]
     mov [PatternJMP],0FFh
     mov al,[Channels]
     mov [ChCount],al

    @ChLoop:

 ;{°°°° Set Sample °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

     mov bx,[ecx]		  ;' dl = Sample-Index
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
	mov bl,[SampleVols+esi]   ;' Copy whole Sample-Data, Volume in AL
       @VolumeCol:
       mov [edi+CVolume],bl	  ;' Save Volume
       mov bh,[GlobalVol]
       mov bl,[VolTable+ebx]	  ;' Adjust to GlobalVolume
       mov [edi+CMonoVol],bl	  ;' -> Got MonoVolume
       mov bh,[edi+CPanning]	  ;' Get Panning: 0..64
       mov bh,[Voltable+ebx]	  ;' Get Volume Right
       sub bl,bh		  ;' Get Volume Left
       mov [Edi+CVolLeft],bx	  ;' Save
     @SkipVolCol:


 ;{°°°° Set Note/Period °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

     mov bx,[ecx+2]   ;' bh = Effect, bl = Note Index
     @NoQuitVibrato:
     or bl,bl
     jnz @ProcessNote
      cmp [B edi+CTickCmd],06
      jne @NoNote
      cmp bh,08h ;' Vibrato-Effect!
      je @NoNote
        mov bx, [edi+CPeriod] ;'!!! Vibrato finished, no new Note in Line!
        mov eax,[DivConst]
        xor edx,edx
        div ebx
        mov [d edi+CIncF],eax  ;' Ready.
        jmp @NoNote
     @ProcessNote:
      sub bl,2
     ;'or bx,bx
     ;'jz @NoNote
     ;'sub bl,2	      ; Word
     ;'jc @NoNote
      mov si,[edi+CSmpIndex]
      and esi,0FFh
      shl esi,4 			;' * 16 ( SampleBuffer )
      add esi,[SampleP]
      movsd
      movsd
      movsd
      movsd
      sub edi,16
      cmp bl,0FCh     ;' Note Cut ?
      je @CutNote
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
      mov bx,[OCTAVES+EBX]
      mov eax,[edi+CC2SPD]    ;' C2SPD
      mul ebx		      ;' EDX -> 0!!!		       *MUL*
      shr eax,16
      mov bx,ax 	      ;' BX = Period
      mov [edi+CDstPeriod],ax ;' Save DestPeriod= Period
      mov [edi+CPeriod],bx    ;' Save Period
      mov eax,[DivConst]      ;' (14317056 DIV SamplingRate) shl 16 !
      div ebx		      ;' EDX = 0!		      *DIV*
      mov [d edi+CIncF],eax   ;' Ready.
      or  [B edi+CStatus],1   ;' Set Active Channel
      jmp @NoNote
     @FX7_D:
      and ebx,0FFh
      mov [EDI+CNoteIndex],bl
      mov bx,[OCTAVES+EBX]
      mov eax,[edi+CC2SPD]	 ;' C2SPD
      mul ebx			 ;' EDX = 0!!!			 *MUL*
      shr eax,16
      mov [edi+CDstPeriod],ax	 ;' Save DestPeriod
      test [B edi+CStatus],1
      jnz @NoNote
       mov bx,ax	      ;' BX = Period
       mov [edi+CPeriod],bx   ;' Save DestPeriod
       mov eax,[DivConst]     ;' (14317056 DIV SamplingRate) shl 16 !
       div ebx		      ;' EDX = 0!		      *DIV*
       mov [d edi+CIncF],eax  ;' Ready.
       or  [B edi+CStatus],1  ;' Set Active Channel
       mov [d edi+CCountI],0
       mov [w edi+CCountF],0
       jmp @NoNote
     @CutNote:
      and [B edi+CStatus],254	 ;' Cut Active Channel
     @NoNote:

 ;{°°°° Effects °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

     xor ebx,ebx
     mov [edi+CTickCmd],ebx
     mov dx,[ecx+3]
     mov bl,dl
     shl ebx,2
     jmp [JumpTable+ebx]

     INCLUDE "TM3_FX1.ASM"

     @ChannelFinished:
     add ecx, 5
     add edi,64
     dec [ChCount]
    jne @ChLoop
    mov [ChPointer],ecx

    mov ax,[BytesPerTick]
    mov [Bytes4Tick],ax
    mov ax, [BytesPerTick]
    cmp [Bytes2Fill], ax
    jbe @ClipIt
     mov [C_BPT],ax
     Call [MixProc]
     jmp @SBIRQ_MAINLOOP	;' Calc next Tick.
    @ClipIt:			;' End of Buffer in reach.
     mov ax,[Bytes2Fill]
     mov [C_BPT],ax
     Call [MixProc]
   @EndIRQ:
  quit

 ;{°°°° Runtime Effects °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

  @InTicks:
   mov edi,[CSampleP]
   mov al,[Channels]
   mov [ChCount],al
   @ChLoopTx:
    xor ebx,ebx
    mov bl,[edi+CTickCmd]
    shl ebx,2			 ;' *4 DWord
    jmp [JumpTableTx+ebx]

    INCLUDE "TM3_FX2.ASM"

    @ChannelFinishedTx:
    add edi,64
    dec [ChCount]
   jne @ChLoopTx

   mov ax,[BytesPerTick]
   mov [Bytes4Tick],ax
   mov ax, [BytesPerTick]
   cmp [Bytes2Fill], ax
   jbe @ClipIt2
    mov [C_BPT],ax
    Call [MixProc]
    jmp @SBIRQ_MAINLOOP        ;' Calc next Tick.
   @ClipIt2:		       ;' End of Buffer in reach.
    mov ax,[Bytes2Fill]
    mov [C_BPT],ax
    Call [MixProc]
  @EndIRQ2:
  quit

 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC MixSilent   ; D: ---  N: ---     Registers see TM3.DOC
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad
  xor ecx,ecx
  mov cx, [C_BPT]
  sub [Bytes2Fill], cx
  sub [Bytes4Tick], cx
  add [C_BufPosition],ecx
  popad
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC MIXStereo   ; D: ---  N: ---     Registers see TM3.DOC
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad
  mov al, [Channels]
  mov [ChCount], al		;' Counter -> Only one MOV instead of push/pop
  mov esi, [CSampleP]
  xor ebx,ebx			;' HiWord ALWAYS 0 !!!
  @Loop4Channels:
    test [B esi+CStatus],1	;' Channel still active ? IT-Compatibility ;)
    jz @NxtChannel
    push esi
    mov cx, [C_BPT]		;' 0->439 !
    dec cx
    shl ecx,16
    mov eax, [esi+CStart]	;' Start
    mov [d @C1+2],eax
    mov edx,[esi+CLength]	;' Length
    mov [d @C2+2],edx
    mov ax, [esi+CVolLeft]	;' Volume Left/Right
    mov [b @C4+1],ah
    mov [b @C5+1],al
    mov edi,[esi+CCountI]	;' Counter Integer
    mov cx, [esi+CCountF]	;' Counter Fract.
    mov dx, [esi+CIncF] 	;' Inc-Factor Fract.
    mov ebp,[esi+CIncI] 	;' Inc-Factor Integer
    mov esi,[MixBufP]
     @Loop4Sample:
@C2:   cmp edi, 11111111h	;' End Reached ? 		    ³CoDeMaN³
       jae @LoopSample		;' If so, jmp to extra Routine
       @SampleLooped:
@C1:   mov bl,[01010101h+EDI]	;' bl = Sample-Byte		    ³CoDeMaN³
@C4:   mov bh,10h		;' bh = Volume Left...		    ³CoDeMaN³
       mov al,[VolTable+EBX]	;' Get effective Sample	HIWORD EBX = 0 !
       cbw
       add [ESI],ax
@C5:   mov bh,07h						 ;' ³CoDeMaN³
       mov al,[VolTable+EBX]	;' HIWORD EBX = 0 !
       cbw
       add [ESI+2],ax
       add cx, dx		;' Add Fractional Part
       adc edi,ebp		;' Add Integer Part + Carry-Flag
       add Esi,4		;' Inc MixBuf-Index
       sub ecx,10000h		;' Dec BytesPerTick  HiWord of ECX! 0-??
     jns @Loop4Sample
    pop esi			;' Get CSample-Index
    mov [esi+CCountI],edi
    mov [esi+CCountF],cx
    @NxtChannel:		;' Guess what.
    add esi,64			;' next Channel in CSamples
    dec [ChCount]		;' Next channel
  jne @Loop4Channels


;{°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Convert Mixbuffer °°°°°}

  xor eax,eax
  mov ebp,eax
  mov ebx,[PostProcP]
  mov cx, [C_BPT]
  sub [Bytes2Fill], cx
  sub [Bytes4Tick], cx
  mov esi,[MixBufP]
  mov edi,[C_BufPosition]
  @ConvertLoop:
   lodsw
   mov al,[EBX+EAX]
   stosb			;' Very nice code, eh ?
   lodsw
   mov [esi-4],ebp
   mov al,[EBX+EAX]
   stosb
   dec cx
  jne @ConvertLoop
  mov [C_BufPosition],edi

  popad
  Ret

;{°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Loop/Cut Sample °°°°°}

  @LoopSample:
   mov eax,[SS:ESP]		;' Get CSample-Index
   mov edi,[EAX+CLStart]	;' Set Loop-Start
   cmp edi,-1			;' Loop ?
   jne @SampleLooped		;' Okay, then jmp back
   and [B EAX+CStatus],254	;' Else disable Channel...  Mask out bit 1!
   pop esi
   jmp @NxtChannel		;' ...and goto nxt Channel
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC MIXMono     ; D: ---  N: ---     Registers see TM3.DOC
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad
  mov al, [Channels]
  mov [ChCount], al		;' Counter -> Only one MOV instead of push/pop
  mov esi, [CSampleP]
  xor ebx,ebx			;' HiWord ALWAYS 0 !!!
  @Loop4Channels_M:
    test [B esi+CStatus],1	;' Channel still active ? IT-Compatibility ;)
    jz @NxtChannel_M
    push esi
    mov cx, [C_BPT]		;' 0->439 !
    dec cx
    shl ecx,16
    mov eax, [esi+CStart]	;' Start
    mov [d @C1_M+2],eax
    mov edx,[esi+CLength]	;' Length
    mov [d @C2_M+2],edx
    mov bh, [esi+CMonoVol]	;' Volume Left/Right
    mov edi,[esi+CCountI]	;' Counter Integer
    mov cx, [esi+CCountF]	;' Counter Fract.
    mov dx, [esi+CIncF] 	;' Inc-Factor Fract.
    mov ebp,[esi+CIncI] 	;' Inc-Factor Integer
    mov esi,[MixBufP]
     @Loop4Sample_M:
@C2_M: cmp edi, 11111111h	;' End Reached ? 		    ³CoDeMaN³
       jae @LoopSample_M	;' If so, jmp to extra Routine
       @SampleLooped_M:
@C1_M: mov bl,[01010101h+EDI]	;' bl = Sample-Byte		    ³CoDeMaN³
       mov al,[VolTable+EBX]	;' Get effective Sample	HIWORD EBX = 0 !
       cbw
       add [ESI],ax
       add cx, dx		;' Add Fractional Part
       adc edi,ebp		;' Add Integer Part + Carry-Flag
       add esi,2		;' Inc MixBuf-Index
       sub ecx,10000h		;' Dec BytesPerTick  HiWord of ECX! 0-??
     jns @Loop4Sample_M
    pop esi			;' Get CSample-Index
    mov [esi+CCountI],edi
    mov [esi+CCountF],cx
    @NxtChannel_M:		;' Guess what.
    add esi,64			;' next Channel in CSamples
    dec [ChCount]		;' Next channel
  jne @Loop4Channels_M


;{°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Convert Mixbuffer °°°°°}

  xor eax,eax
  mov ebp,eax
  mov ebx,[PostProcP]
  mov cx, [C_BPT]
  sub [Bytes2Fill], cx
  sub [Bytes4Tick], cx
  mov esi,[MixBufP]
  mov edi,[C_BufPosition]
  @ConvertLoop_M:
   lodsw
   mov [esi-2],bp
   mov al,[EBX+EAX]
   stosb			;' Very nice code, eh ?
   dec cx
  jne @ConvertLoop_M
  mov [C_BufPosition],edi
  popad
  Ret

;{°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° Loop/Cut Sample °°°°°}

  @LoopSample_M:
   mov eax,[SS:ESP]		;' Get CSample-Index
   mov edi,[EAX+CLStart]	;' Set Loop-Start
   cmp edi,-1			;' Loop ?
   jne @SampleLooped_M		;' Okay, then jmp back
   and [B EAX+CStatus],254	;' Else disable Channel...  Mask out bit 1!
   pop esi
   jmp @NxtChannel_M		;' ...and goto nxt Channel


 Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
    PROC CalcVolTable  ; D:--- N:---   Calculates Volume-Table ( 65*256 Bytes )
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  Xor bx,bx
  mov edi, o VolTable
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
  mov edi,[PostProcP]
  mov eax,0FFFFFFFFh
  mov ecx,8192	       ;' * 4 -> EAX
  rep stosd
  xor eax,eax
  mov ecx,8192
  rep stosd	       ;' Okay, Table Initialised.
  xor ebx,ebx
  mov bp,[MasterSpace] ;' BP=Counter!
  shr bp,1
  mov bx,bp
  dec bp	       ;' 0 needs not to be calculated.
  xor dx,dx
  mov ax,8000h
  div bx	       ;' AX = Inc-Factor ( Steigung der Geraden )

  mov dx,8000h
  mov bx,8000h
  mov edi,[PostProcP]  ;' 2nd Value
  mov [edi],bh	       ;' Set 1st
  mov esi,[PostProcP]
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

  Ret
 ENDP


;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC InitTM3
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  mov [TM3SyncCount],0
  mov [CPattern], 255   ;' Force Pattern=0 at beginning
  mov al,[Speed]
  sub al,5
  mov [Ticks],al	;' Force new line at beginning
  mov [PatternLine],63	;' Force new Pattern at beginning
  mov [DMAFlipFlop],3

;{°°° Calc BytesPerTick °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  mov ax,[SamplingRate]
  xor dx,dx
  xor bx,bx
  mov bl, [Tempo]
  div bx		;' ax= Bytes per second
  mov [BytesPerTick],ax
  mov [Bytes4Tick],ax
  mov [MaxSampleBytes],ax
  mov ecx,55128
  mov eax,[TM3BufferP]
  mov ebx,eax
  add ebx,ecx
  add eax,[_Code32a]
  add eax,ecx
  cmp ax,cx
  jae @NoWrap
   sub ebx,ecx
   add eax,ecx
  @NoWrap:
  sub eax,ecx
  sub eax,[_Code32a]
  mov [DMABuf], eax
  mov [MixBufP],ebx

;{°°° Calc DivConst.. °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  xor ebx,ebx
  mov bx,[Samplingrate]
  mov edx,0DAh
  mov eax,77900000h
  div ebx
  mov [DivConst],eax
;'-------------------------------------------------
  xor eax,eax		  ;' Initialize Length for all Channels:
  mov edi,[CSampleP]
  xor ecx,ecx
  mov cl,[Channels]
  shl ecx,4
  rep stosd
  xor ebx,ebx
  mov edi,[CSampleP]
  mov dl,[Channels]
  @InitChannels:
   mov [d edi+CC2SPD],00010000h
   mov [d edi+CPERIOD],1000h
   mov [d edi+CDSTPERIOD],1000h
   mov ah,[Panning+ebx]
   mov [edi+CPanning],ah
   add edi,64
   inc ebx
   dec dl
  jne @InitChannels
;' -------------------------------------------------
  mov al,080h
  mov edi, [DMABuf]
  mov cx, [MaxSampleBytes]  ;' HighWord of ECX = 0
  rep stosd

  xor ax,ax
  mov edi, [MixBufP]
  mov cx, [MaxSampleBytes]  ;' HighWord of ECX = 0
  rep stosd


;{°°° Miscellaneous... °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

  xor edx,edx
  mov ax,[SamplingRate]
  mov bx,70
  div bx
  mov [MaxSampleBytes],ax

  Call CalcVolTable
  Call CalcPostProc
  mov eax,[DMABuf]
  mov [C_BufPosition],eax
  mov [TM3CalcBuf],0

  Ret
 ENDP

 SetStereo db 80h	 ;' Stereo-Byte to send...

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC PlayTM3
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  mov [IRQ_Stop],0
  mov [IRQ_Finished],0
  Call InitTM3
  cmp [SBVer],0
  je @NoSBDetected
  mov dx,[ADR]
  Call InitSB

  mov cl,[IRQ]
  cmp cl,10
  jae @I10
   in al,21h
   mov [PORT21],al
   mov ah,1
   shl ah,cl
   not ah
   and al,ah
   out 21h, al
   jmp @EndMsk
  @I10:
   in  al,0A1h
   mov [PORTA1],al
   and al,11111011b
   out 0A1h, al
  @EndMsk:
  cli
   mov bl,[IRQ]
   Call [_GetIrqVect]
   mov [SB_OldIrq],edx
  sti

  cmp [SBVer],400h
  jb @NoSB16Detected
   Call SetUpDMA_SB16
   clc
   Ret
  @NoSB16Detected:
  cmp [SBVer],300h
  jb @NoSBProDetected
   Call SetUpDMA_SBPro
   clc
   Ret
  @NoSBProDetected:
  cmp [SBVer],201h
  jb @NoSB201Detected
   Call SetUpDMA_SB201
   clc
   Ret
  @NoSB201Detected:
  cmp [SBVer],200h
  jb @NoSBDetected
   Call SetUpDMA_SBPro
   clc
   Ret
  @NoSBDetected:
  mov [MixProc],O MixSilent
  stc
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC QuitTM3
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  cmp [SBVer],0
  je @NothingToDo
  mov al,5
  out 0Ah,al	       ;' Stop DMA-Tranfer!
  mov dx,[ADR]
  Call InitSB
  cmp [IRQ],10
  je @DeIRQ10
   mov al,[PORT21]
   out 21h,al
   jmp @EndDeMASK
  @DeIRQ10:
   mov al,[PORTA1]
   out 0A1h,al
  @EndDeMASK:
  mov bl,[IRQ]
  cli
   mov edx,[SB_OldIrq]
   call [_SetIrqVect]
   mov eax,[SB_CallBack]
   call _rmpmirqfree
  sti
  WDsp 0D3h
  @NothingToDo:
  mov [IRQ_Finished],1
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC StopTM3
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  mov [IRQ_Stop],1
  Call QuitTM3
  @STLoop:
   cmp [IRQ_Finished],1
   jne @STLoop
  Ret
 ENDP