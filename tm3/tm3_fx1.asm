;'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ'
;'ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€€€€€€‹  €€€€€€€ﬂ€ﬂ€€€€€€‹	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€€€€€€‹ THE MODULE V3.00·  '
;'          €€€€€€€  €€€€€€€ ﬂ €€€€€€€		ﬂﬂ€€€€€€€  (C) Spring 1997   '
;'          €€€€€€€  €€€€€€€   €€€€€€€	‹‹‹‹‹‹‹‹‹‹€€€€€€ﬂ by Syrius / Alpine '
;'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ'
;' ROW-EFFECTS                                                               '
;'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ'



 ;{€€€≤≤≤±±∞ SETSPEED......: [01h] T0:[x] IN:[ ] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @SetSpeed:
     mov [Speed],dh
     jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ PATTERNJMP....: [02h] T0:[x] IN:[ ] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @PatternJMP:
     mov [PatternJMP],dh
     mov [PatternROW],0
     jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ PATTERNBREAK..: [03h] T0:[x] IN:[ ] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @PatternBreak:
     mov al,dh
     mov ah,10
     shr al,4
     mul ah
     and dh,0Fh
     add al,dh
     cmp al,64
     jb @NoWrapBRK
       mov al,63
     @NoWrapBRK:
     mov [PatternROW],al
     cmp [PatternJMP],0FFh
     jne @ChannelFinished
      mov dl,[CPattern]
      inc dl
      mov [PatternJMP],dl
      jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ SETGLOBALVOL..: [17h] T0:[x] IN:[ ] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @SetGlobalVol:
     cmp dh,64
     jbe @NoMaxGV
      mov dh,64
     @NoMaxGV:
     mov [GlobalVol],dh
     mov esi,[CSampleP]
     mov dl,[Channels]
     @ResetVols:
       mov bl,[esi+CVolume]       ;' Load Volume
       mov bh,dh
       mov bl,[VolTable+ebx]      ;' Adjust to GlobalVolume
       mov [esi+CMonoVol],bl      ;' -> Got MonoVolume
       mov bh,[esi+CPanning]      ;' Get Panning: 0..64
       mov bh,[Voltable+ebx]      ;' Get Volume Right
       sub bl,bh                  ;' Get Volume Left
       mov [Esi+CVolLeft],bx      ;' Save
       add esi,64
       dec dl
     jne @ResetVols
     jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ VOLUME SLIDE..: [04h] T0:[ ] IN:[x] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @VSlide:
      or dh,dh
      jnz @NoEmptyVSLD
       mov dh, [edi+CLastVSld]
      @NoEmptyVSLD:
      mov [edi+CLastVSld],dh

      mov al,dh                   ;' Effect-Byte!
      and al,0Fh
      jnz @NoVSlideUp
       shr dh,4
       mov [edi+CWorkByte3] ,dh
       mov [b edi+CTickCmd],01h   ;' 01h = VSlide up
       jmp @ChannelFinished
      @NoVSlideUp:
      mov ah,dh
      shr ah,4
      jnz @NoVSlideDn
       and dh,0Fh
       mov [edi+CWorkByte3] ,dh
       mov [b edi+CTickCmd],02h   ;' 02h = VSlide Down
       jmp @ChannelFinished
      @NoVSlideDn:

      cmp al,0Fh
      jne @NoVFineSlideUp          ;' Fine Volume Slide Up!
       shr dh,4
       mov bl, [edi+CVolume]
       add bl, dh
       cmp bl, 65
       jb  @SetVol
        mov bl,64
        jmp @SetVol
      @NoVFineSlideUp:

      and dh,0Fh                  ;' Fine Volume Slide down
      mov bl, [edi+CVolume]
      sub bl, dh
      jns @SetVol
        xor bl,bl
      @SetVol:
       mov [edi+CVolume],bl       ;' Save Volume
       mov bh,[GlobalVol]
       mov bl,[VolTable+ebx]      ;' Adjust to GlobalVolume
       mov [edi+CMonoVol],bl      ;' -> Got MonoVolume
       mov bh,[edi+CPanning]      ;' Get Panning: 0..64
       mov bh,[Voltable+ebx]      ;' Get Volume Right
       sub bl,bh                  ;' Get Volume Left
       mov [Edi+CVolLeft],bx      ;' Ready
       jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ TPORTA+VSLIDE.: [1Ah] T0:[ ] IN:[x] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @PortaVSlide:     ;'1Ah

     mov al, [edi+CLastTPorta]      ;' Set Tone-Porta-Values
     mov [edi+CWorkByte],al
     mov dl,04h
     mov ax,[edi+CPeriod]
     mov bx,[edi+CDstPeriod]
     cmp ax,bx
     ja  @TPortaUpVSLD
       mov dl,03h
     @TPortaUpVSLD:
     mov [b edi+CTickCmd],dl

     or dh,dh                       ;' Set Volume-Slide-Values
     jnz @NoEmptyVSLD_T
      mov dh, [edi+CLastVSld]
     @NoEmptyVSLD_T:
     mov [edi+CLastVSld],dh
     mov al,dh                      ;' Effect-Byte!
     and al,0Fh
     jnz @NoVSlideUp_T
     shr dh,4
      mov [edi+CWorkByte3] ,dh
      mov [b edi+CTickCmd2],01h     ;' 01h = VSlide up
      jmp @ChannelFinished
     @NoVSlideUp_T:
     mov ah,dh
     shr ah,4
     jnz @NoVSlideDn_T
      and dh,0Fh
      mov [edi+CWorkByte3] ,dh
      mov [b edi+CTickCmd2],02h     ;' 02h = VSlide Down
      jmp @ChannelFinished
     @NoVSlideDn_T:

     cmp al,0Fh
     jne @NoVFineSlideUp_T          ;' Fine Volume Slide Up!
      shr dh,4
      mov bl, [edi+CVolume]
      add bl, dh
      cmp bl, 65
      jb  @SetVol_T
       mov bl,64
       jmp @SetVol_T
     @NoVFineSlideUp_T:

     and dh,0Fh                     ;' Fine Volume Slide down
     mov bl, [edi+CVolume]
     sub bl, dh
     jns @SetVol_T
       xor bl,bl
     @SetVol_T:
      mov [edi+CVolume],bl          ;' Save Volume
      mov bh,[GlobalVol]
      mov bl,[VolTable+ebx]         ;' Adjust to GlobalVolume
      mov [edi+CMonoVol],bl         ;' -> Got MonoVolume
      mov bh,[edi+CPanning]         ;' Get Panning: 0..64
      mov bh,[Voltable+ebx]         ;' Get Volume Right
      sub bl,bh                     ;' Get Volume Left
      mov [Edi+CVolLeft],bx         ;' Ready
      jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ SETTEMPO......: [24h] T0:[x] IN:[ ] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @SetTempo:        ;'24h

     mov al,dh             ;' Get BPM-Rate
     mov [BPM],dh
     mov bl,67h            ;' * 2 div 50
     mul bl
     xor bx,bx
     mov bl,ah
     mov [Tempo],ah        ;' Sampling div Tempo
     mov ax,[SamplingRate]
     xor dx,dx
     div bx
     dec ax
     mov [BytesPerTick],ax ;' = Bytes per Tick

     jmp @ChannelFinished


 ;{€€€≤≤≤±±∞ PORTA DOWN....: [05h] T0:[ ] IN:[x] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @PortaDn:
     or dh,dh
     jnz @NoEmptyPSLDD
       mov dh, [edi+CLastPSldD]
     @NoEmptyPSLDD:
     mov [edi+CLastPSldD],dh
     mov al,dh
     shr al,4
     cmp al,0Eh
     jae @FinePortaDown
      mov [edi+CWorkByte] ,dh
      mov [b edi+CTickCmd],03h   ;' 03h = PSlide Dn
      mov [w edi+CDstPeriod], 27392
      jmp @ChannelFinished
     @FinePortaDown:
     mov dl,dh
     and edx,0Fh
     mov bx, [edi+CPeriod]
     cmp al,0Fh
     jne @NoFinePortaDown
      shl dl,2
     @NoFinePortaDown:
     add ebx, edx
     xor edx, edx
     mov eax,[DivConst]     ;' (14317056 DIV SamplingRate) shl 16 !
     div ebx                ;' EDX = 0!                      *DIV*
     mov [d edi+CIncF],eax  ;' Ready.
     mov [edi+CPeriod],bx
     jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ PORTA UP......: [06h] T0:[ ] IN:[x] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @PortaUp:
     or dh,dh
     jnz @NoEmptyPSLDU
       mov dh, [edi+CLastPSldU]
     @NoEmptyPSLDU:
     mov [edi+CLastPSldU],dh
     mov al,dh
     shr al,4
     cmp al,0Eh
     jae @FinePortaUp
      mov [edi+CWorkByte] ,dh
      mov [b edi+CTickCmd],04h   ;' 04h = PSlide Up
      mov [w edi+CDstPeriod], 14
      jmp @ChannelFinished
     @FinePortaUp:
     mov dl,dh
     and edx,0Fh
     mov bx, [edi+CPeriod]
     cmp al,0Fh
     jne @NoFinePortaUp
      shl dl,2
     @NoFinePortaUp:
     sub ebx, edx
     xor edx, edx
     mov eax,[DivConst]     ;' (14317056 DIV SamplingRate) shl 16 !
     div ebx                ;' EDX = 0!                      *DIV*
     mov [d edi+CIncF],eax  ;' Ready.
     mov [edi+CPeriod],bx
     jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ TONE PORTA....: [07h] T0:[ ] IN:[x] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @TonePorta:
     or dh,dh
     jnz @NoEmptyTPorta
       mov dh, [edi+CLastTPorta]
     @NoEmptyTPorta:
     mov [edi+CLastTPorta],dh
     mov dl,04h
     mov ax,[edi+CPeriod]
     mov bx,[edi+CDstPeriod]
     cmp ax,bx
     ja  @TPortaUp
       mov dl,03h
     @TPortaUp:
     mov [edi+CWorkByte] ,dh
     mov [b edi+CTickCmd],dl
     jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ RETRIG&VSLIDE.: [0Fh] T0:[ ] IN:[x] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @Retrig:
     mov [B edi+CTickCmd],05h
     and dh,0Fh
     jnz @NoOldRetrig
       mov dh,[Edi+CLastRetrig]
     @NoOldRetrig:
     mov [Edi+CLastRetrig],dh
     mov [edi+CWorkbyte],dh
     mov [edi+CWorkbyte2],dh

     jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ SETLOOPSTART..: [12h] T0:[ ] IN:[x] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @SetLoopStart:
     mov al,[PatternLine]
     mov [edi+CLoopStart],al
     jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ LOOPPATTERN...: [13h] T0:[ ] IN:[x] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @LoopPattern:
     dec [B edi+CLoopCount]
     jz @ChannelFinished
     jns @NoNewLoop
      mov [edi+CLoopCount],dh
     @NoNewLoop:
      mov al,[edi+CLoopStart]
      mov [PatternROW],al
      mov dl,[CPattern]
      mov [PatternJMP],dl
     jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ (FINE) VIBRATO: [08/09h] T0:[ ] IN:[x] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€}
   @Vibrato:
     mov eax,02E0C166h  ;' shl ax,2
     cmp dl,09h         ;' FineVibrato?
     jne @NoFineVib     ;
      mov eax,90909090h
     @NoFineVib:
     mov [@CHFineVibrato],eax
     mov al,dh
     shr al,4                   ;' Get Vibrato-Speed
     jnz @NoOldVSpeed
      mov al,[edi+CLastVib]
      shr al,4
     @NoOldVSpeed:
     mov [Edi+CWorkbyte],al     ;' Save current VSpeed in W1
     shl al,4                   ;' For CLastVib
     and dh,0Fh                 ;' Get VDepth
     jnz @NoOldDepth
      mov dh,[edi+CLastVib]
      and dh,0Fh
     @NoOldDepth:
     mov [edi+CWorkbyte2],dh    ;' Save current VDepth in W2
     or al,dh
     mov [edi+CLastVib],al      ;' Save new CLastVib!
     mov [B edi+CTickCmd],06h   ;' TVibrato.
     jmp @ChannelFinished

 ;{€€€≤≤≤±±∞ VIBRATO+VSLIDE: [0Ch] T0:[ ] IN:[x] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}
   @VibVSlide:
     mov al,[edi+CLastVib]
     shr al,4
     mov [Edi+CWorkbyte],al     ;' Save current VSpeed in W1
     mov al,[edi+CLastVib]
     and al,0Fh
     mov [edi+CWorkbyte2],al    ;' Save current VDepth in W2
     mov [B edi+CTickCmd],06h   ;' TVibrato.

     or dh,dh                       ;' Set Volume-Slide-Values
     jnz @NoEmptyVSLD_V
      mov dh, [edi+CLastVSld]
     @NoEmptyVSLD_V:
     mov [edi+CLastVSld],dh
     mov al,dh                      ;' Effect-Byte!
     and al,0Fh
     jnz @NoVSlideUp_V
     shr dh,4
      mov [edi+CWorkByte3] ,dh
      mov [b edi+CTickCmd2],01h     ;' 01h = VSlide up
      jmp @ChannelFinished
     @NoVSlideUp_V:
     mov ah,dh
     shr ah,4
     jnz @NoVSlideDn_V
      and dh,0Fh
      mov [edi+CWorkByte3] ,dh
      mov [b edi+CTickCmd2],02h     ;' 02h = VSlide Down
      jmp @ChannelFinished
     @NoVSlideDn_V:

     cmp al,0Fh
     jne @NoVFineSlideUp_V          ;' Fine Volume Slide Up!
      shr dh,4
      mov bl, [edi+CVolume]
      add bl, dh
      cmp bl, 65
      jb  @SetVol_V
       mov bl,64
       jmp @SetVol_V
     @NoVFineSlideUp_V:

     and dh,0Fh                     ;' Fine Volume Slide down
     mov bl, [edi+CVolume]
     sub bl, dh
     jns @SetVol_V
       xor bl,bl
     @SetVol_V:
      mov [edi+CVolume],bl          ;' Save Volume
      mov bh,[GlobalVol]
      mov bl,[VolTable+ebx]         ;' Adjust to GlobalVolume
      mov [edi+CMonoVol],bl         ;' -> Got MonoVolume
      mov bh,[edi+CPanning]         ;' Get Panning: 0..64
      mov bh,[Voltable+ebx]         ;' Get Volume Right
      sub bl,bh                     ;' Get Volume Left
      mov [Edi+CVolLeft],bx         ;' Ready
      jmp @ChannelFinished


 ;{€€€≤≤≤±±∞ UNIMPLEMENTED.: [xxh] T0:[?] IN:[?] ∞±±≤≤≤€€€€€€€€€€€€€€€€€€€€€€}

   @FineVibrato:     ;'13h
     jmp @ChannelFinished
   @Tremor:          ;'14h
     jmp @ChannelFinished
   @Arpeggio:        ;'15h
     jmp @ChannelFinished
   @SampleOffset:    ;'1Ch
     jmp @ChannelFinished
   @Tremolo:         ;'1Eh
     jmp @ChannelFinished
   @PatternDelay:    ;'1Fh
     jmp @ChannelFinished
   @NoteCut:         ;'22h
     jmp @ChannelFinished
   @NoteDelay:       ;'23h
     jmp @ChannelFinished
   @SetPanning:      ;'26h
     jmp @ChannelFinished
