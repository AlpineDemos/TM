;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;'ÜÛÛÛÛÛßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßßßÛÛÛÛÛÛÜ	ßßßßßßßßßßÛÛÛÛÛÛÜ ALPINE PLAYER V3.00'
;'ÛÛÛÛÛÛ    ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ		ßßÛÛÛÛÛÛÛ  (C) 1997          '
;'ÛÛÛÛÛÛ ßßßÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛßßßßßßßßß 	ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß by Syrius / Alpine '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;' TM3 - No Output!                                                          '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

    ;{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²²±±° VSlide Up.....: (01h) °±±²²²ÛÛÛÛÛ}
    @VSlideUp:
      mov bl, [edi+CVolume]
      add bl, [edi+CWorkByte3]
      cmp bl,65                   ;' No Overflow!
      jb @NoVSU
       mov bl,64
      @NoVSU:
       mov [edi+CVolume],bl       ;' Save Volume
       mov bh,[_GlobalVol]
       mov bl,[_VolTable+ebx]      ;' Adjust to GlobalVolume
       mov [edi+CMonoVol],bl      ;' -> Got MonoVolume
       mov bh,[edi+CPanning]      ;' Get Panning: 0..64
       mov bh,[_Voltable+ebx]      ;' Get Volume Right
       sub bl,bh                  ;' Get Volume Left
       mov [Edi+CVolLeft],bx      ;' Ready
      jmp @ChannelFinishedTx


    ;{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²²±±° VSlide Dn.....: (02h) °±±²²²ÛÛÛÛÛ}
    @VSlideDn:
      mov bl, [edi+CVolume]
      sub bl, [edi+CWorkByte3]
      jns @NoVSD
       xor bl,bl
      @NoVSD:
       mov [edi+CVolume],bl       ;' Save Volume
       mov bh,[_GlobalVol]
       mov bl,[_VolTable+ebx]      ;' Adjust to GlobalVolume
       mov [edi+CMonoVol],bl      ;' -> Got MonoVolume
       mov bh,[edi+CPanning]      ;' Get Panning: 0..64
       mov bh,[_Voltable+ebx]      ;' Get Volume Right
       sub bl,bh                  ;' Get Volume Left
       mov [Edi+CVolLeft],bx      ;' Ready
      jmp @ChannelFinishedTx


    ;{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²²±±° PSlide Dn.....: (03h) °±±²²²ÛÛÛÛÛ}
    @PSlideDn:
      xor eax,eax
      mov al, [edi+CWorkByte]
      shl eax, 2
      mov bx, [edi+CPeriod]
      add ebx, eax
      cmp bx,[edi+CDstPeriod]
      jbe @NoStopPSLDD
       mov bx,[edi+CDstPeriod]
       mov al, [edi+CTickCmd2]
       mov [b edi+CTickCmd],al
      @NoStopPSLDD:
      mov eax,[_DivConst]     ;' (14317056 DIV SamplingRate) shl 16 !
      xor edx,edx
      div ebx                ;' EDX = 0!
      mov [d edi+CIncF],eax  ;' Ready.
      mov [edi+CPeriod],bx
      mov al, [edi+CTickCmd2]
      or al,al
       jnz @2NDEffect
      jmp @ChannelFinishedTx

    ;{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²²±±° 2ND Effect: VSlide... °±±²²²ÛÛÛÛÛ}

      @2NDEffect:
      dec al
      jz  @VSlideUp           ;' TickCmd2 = 1 -> Slide Up!
      jmp @VSlideDn           ;' TickCmd2 = 2 -> Slide Dn!

    ;{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²²±±° PSlide Up.....: (04h) °±±²²²ÛÛÛÛÛ}
    @PSlideUp:
      xor eax,eax
      mov al, [edi+CWorkByte]
      shl eax, 2             ;' Multiply Inc-Factor by 4 ( S3M-Period ! )
      mov bx, [edi+CPeriod]
      sub bx, ax
      js  @SetPSLDU
      cmp bx,[edi+CDstPeriod]
      jae @NoStopPSLDU
       @SetPSLDU:
       mov bx,[edi+CDstPeriod]
       mov al, [edi+CTickCmd2]
       mov [b edi+CTickCmd],al
      @NoStopPSLDU:
      mov eax,[_DivConst]     ;' (14317056 DIV SamplingRate) shl 16 !
      xor edx,edx
      div ebx                ;' EDX = 0!
      mov [d edi+CIncF],eax  ;' Ready.
      mov [edi+CPeriod],bx
      mov al, [edi+CTickCmd2]
      or al,al
       jnz @2NDEffect
      jmp @ChannelFinishedTx

    ;{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²²±±° Retrig........: (05h) °±±²²²ÛÛÛÛÛ}
    @TRetrig:
     dec [B edi+CWorkByte]
     jnz @ChannelFinishedTx
      mov al, [edi+CWorkByte2]
      mov [edi+CWorkByte],al
      xor eax,eax
      mov [edi+CCountI],eax
      mov [edi+CCountF],ax
      xor ebx,ebx
      mov bl,[edi+CWorkByte3]
      shl bl,2
      jmp [RetrigVols+ebx]
      mov bl,[edi+CVolume]        ;' Save Volume
      @RVol_1:
       dec bl
       jmp @SetRetVol
      @RVol_2:
       sub bl,2
       jmp @SetRetVol
      @RVol_4:
       sub bl,4
       jmp @SetRetVol
      @RVol_8:
       sub bl,8
       jmp @SetRetVol
      @RVol_16:
       sub bl,16
       jmp @SetRetVol
      @RVol23:
       mov al,171
       mul bl
       mov bl,al
       jmp @SetRetVol
      @RVol12:
       shr bl,1
       jmp @SetRetVol
      @RVol1:
       inc bl
       jmp @SetRetVol
      @RVol2:
       add bl,2
       jmp @SetRetVol
      @RVol4:
       add bl,4
       jmp @SetRetVol
      @RVol8:
       add bl,8
       jmp @SetRetVol
      @RVol16:
       add bl,16
       jmp @SetRetVol
      @RVol32:
       mov al,3
       mul bl
       shr al,1
       mov bl,al
       jmp @SetRetVol
      @RVolm2:
       shl bl,1
      @SetRetVol:
       js @RetVol0
       cmp bl,64
       jbe @RetNoClip64
        mov bl,64
       @RetNoClip64:
       mov [edi+CVolume],bl       ;' Save Volume
       mov bh,[_GlobalVol]
       mov bl,[_VolTable+ebx]      ;' Adjust to GlobalVolume
       mov [edi+CMonoVol],bl      ;' -> Got MonoVolume
       mov bh,[edi+CPanning]      ;' Get Panning: 0..64
       mov bh,[_Voltable+ebx]      ;' Get Volume Right
       sub bl,bh                  ;' Get Volume Left
       mov [Edi+CVolLeft],bx      ;' Ready
      jmp @ChannelFinishedTx
      @RetVol0:
       xor ebx,ebx
       mov [Edi+CVolume],ebx      ;' Ready
      jmp @ChannelFinishedTx



    ;{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²²±±° Vibrato.......: (06h) °±±²²²ÛÛÛÛÛ}
    @TVibrato:
      mov dl,[edi+CLastVibPos]
      mov bl,dl
      and ebx,31
LABEL @CHVibratoTable DWORD   ;' Later CodeManipulation for ramp down etc.
      mov al,[_Vibratotable+ebx]
      mov bl,[edi+CWorkByte2]
      mul bl
      shr ax,7
      shl ax,2     ;' * 4 S3M-Period!
      mov bx,[edi+CPeriod]
      test dl,32   ;' Sign-Test!
      jnz @SubVibrato
       add bx,ax
       jmp @VibSubAddReady
      @SubVibrato:
       sub bx,ax
      @VibSubAddReady:
       add dl,[edi+CWorkByte]  ;' Calc next Position in SinTab
       and dl,63
       mov [edi+CLastVibPos],dl
       mov eax,[_DivConst]       ;' Calc INC-F
       xor edx,edx
       div ebx
      mov [d edi+CIncF],eax    ;' Ready.
      mov al, [edi+CTickCmd2]  ;' 2nd effect ?
      or al,al
       jnz @2NDEffect
      jmp @ChannelFinishedTx

    ;{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²²±±° FineVibrato...: (07h) °±±²²²ÛÛÛÛÛ}
    @TFineVibrato:
      mov dl,[edi+CLastVibPos]
      mov bl,dl
      and ebx,31
LABEL @CHFVibratoTable DWORD   ;' Later CodeManipulation for ramp down etc.
      mov al,[_Vibratotable+ebx]
      mov bl,[edi+CWorkByte2]
      mul bl
      shr ax,7
      mov bx,[edi+CPeriod]
      test dl,32   ;' Sign-Test!
      jnz @SubFVibrato
       add bx,ax
       jmp @FVibSubAddReady
      @SubFVibrato:
       sub bx,ax
      @FVibSubAddReady:
       add dl,[edi+CWorkByte]  ;' Calc next Position in SinTab
       and dl,63
       mov [edi+CLastVibPos],dl
       mov eax,[_DivConst]       ;' Calc INC-F
       xor edx,edx
       div ebx
      mov [d edi+CIncF],eax    ;' Ready.
      mov al, [edi+CTickCmd2]  ;' 2nd effect ?
      or al,al
       jnz @2NDEffect
      jmp @ChannelFinishedTx

    ;{ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ²²²±±° NoteDelay.....: (08h) °±±²²²ÛÛÛÛÛ}
    @TNoteDelay:
     dec [b edi+CWorkByte]
     jnz @ChannelFinishedTx
      mov [b edi+CTickCmd],0

      ;{°°°° Set Sample °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

      mov bx,[edi+CSmpIndex]                 ;' dl = Sample-Index
      or bx,bx
      jz @DSkipVolCol
        dec bh
        js @DNoNewSample
         mov [edi+CSmpIndex],bh
        @DNoNewSample:
        dec bl
        jns @DVolumeCol
         mov esi,ebx
         shr esi,8
         mov bl,[_SampleVols+esi]  ;'
        @DVolumeCol:
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
      @DSkipVolCol:

     ;{°°°° Set Note/Period °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

      mov bx,[edi+CSmpIndex+2]   ;' bh = Effect, bl = Note Index
      or bl,bl
      jz @ChannelFinishedTx
       sub bl,2
       cmp bl,0FCh     ;' Note Cut ?
       je @DCutNote
       mov si,[edi+CSmpIndex]
       and esi,0FFh
       shl esi,4                         ;' * 16 ( SampleBuffer )
       add esi,[_SampleP]
       movsd
       movsd
       movsd
       movsd
       sub edi,16

       xor eax,eax
       mov [edi+CCountF],ax
       mov [edi+CLastVibPos],al
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
       jmp @ChannelFinishedTx
      @DCutNote:
       and [B edi+CStatus],254    ;' Cut Active Channel
      jmp @ChannelFinishedTx



















