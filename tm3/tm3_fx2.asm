;'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ'
;'ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€€€€€€‹  €€€€€€€ﬂ€ﬂ€€€€€€‹	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€€€€€€‹ THE MODULE V3.00·  '
;'          €€€€€€€  €€€€€€€ ﬂ €€€€€€€		ﬂﬂ€€€€€€€  (C) Spring 1997   '
;'          €€€€€€€  €€€€€€€   €€€€€€€	‹‹‹‹‹‹‹‹‹‹€€€€€€ﬂ by Syrius / Alpine '
;'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ'
;' TICK-EFFECTS                                                              '
;'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ'

    ;{€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€≤≤≤±±∞ VSlide Up.....: [01h] ∞±±≤≤≤€€€€€}
    @VSlideUp:
      mov bl, [edi+CVolume]
      add bl, [edi+CWorkByte3]
      cmp bl,65                   ;' No Overflow!
      jb @NoVSU
       mov bl,64
      @NoVSU:
       mov [edi+CVolume],bl       ;' Save Volume
       mov bh,[GlobalVol]
       mov bl,[VolTable+ebx]      ;' Adjust to GlobalVolume
       mov [edi+CMonoVol],bl      ;' -> Got MonoVolume
       mov bh,[edi+CPanning]      ;' Get Panning: 0..64
       mov bh,[Voltable+ebx]      ;' Get Volume Right
       sub bl,bh                  ;' Get Volume Left
       mov [Edi+CVolLeft],bx      ;' Ready
      jmp @ChannelFinishedTx


    ;{€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€≤≤≤±±∞ VSlide Dn.....: [02h] ∞±±≤≤≤€€€€€}
    @VSlideDn:
      mov bl, [edi+CVolume]
      sub bl, [edi+CWorkByte3]
      jns @NoVSD
       xor bl,bl
      @NoVSD:
       mov [edi+CVolume],bl       ;' Save Volume
       mov bh,[GlobalVol]
       mov bl,[VolTable+ebx]      ;' Adjust to GlobalVolume
       mov [edi+CMonoVol],bl      ;' -> Got MonoVolume
       mov bh,[edi+CPanning]      ;' Get Panning: 0..64
       mov bh,[Voltable+ebx]      ;' Get Volume Right
       sub bl,bh                  ;' Get Volume Left
       mov [Edi+CVolLeft],bx      ;' Ready
      jmp @ChannelFinishedTx


    ;{€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€≤≤≤±±∞ PSlide Dn.....: [03h] ∞±±≤≤≤€€€€€}
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
      mov eax,[DivConst]     ;' (14317056 DIV SamplingRate) shl 16 !
      xor edx,edx
      div ebx                ;' EDX = 0!
      mov [d edi+CIncF],eax  ;' Ready.
      mov [edi+CPeriod],bx
      mov al, [edi+CTickCmd2]
      or al,al
       jnz @2NDEffect
      jmp @ChannelFinishedTx

    ;{€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€≤≤≤±±∞ 2ND Effect: VSlide... ∞±±≤≤≤€€€€€}

      @2NDEffect:
      dec al
      jz  @VSlideUp           ;' TickCmd2 = 1 -> Slide Up!
      jmp @VSlideDn           ;' TickCmd2 = 2 -> Slide Dn!

    ;{€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€≤≤≤±±∞ PSlide Up.....: [04h] ∞±±≤≤≤€€€€€}
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
      mov eax,[DivConst]     ;' (14317056 DIV SamplingRate) shl 16 !
      xor edx,edx
      div ebx                ;' EDX = 0!
      mov [d edi+CIncF],eax  ;' Ready.
      mov [edi+CPeriod],bx
      mov al, [edi+CTickCmd2]
      or al,al
       jnz @2NDEffect
      jmp @ChannelFinishedTx

    ;{€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€≤≤≤±±∞ Retrig........: [05h] ∞±±≤≤≤€€€€€}
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
       mov bh,[GlobalVol]
       mov bl,[VolTable+ebx]      ;' Adjust to GlobalVolume
       mov [edi+CMonoVol],bl      ;' -> Got MonoVolume
       mov bh,[edi+CPanning]      ;' Get Panning: 0..64
       mov bh,[Voltable+ebx]      ;' Get Volume Right
       sub bl,bh                  ;' Get Volume Left
       mov [Edi+CVolLeft],bx      ;' Ready
      jmp @ChannelFinishedTx
      @RetVol0:
       xor ebx,ebx
       mov [Edi+CVolume],ebx      ;' Ready
      jmp @ChannelFinishedTx



    ;{€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€≤≤≤±±∞ Vibrato.......: [06h] ∞±±≤≤≤€€€€€}
    @TVibrato:
      mov dl,[edi+CLastVibPos]
      mov bl,dl
      and ebx,31
LABEL @CHVibratoTable DWORD   ;' Later CodeManipulation for ramp down etc.
      mov al,[Vibratotable+ebx]
      mov bl,[edi+CWorkByte2]
      mul bl
      shr ax,7
LABEL @CHFineVibrato DWORD ;' Gets shl ax,0...
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
       mov eax,[DivConst]       ;' Calc INC-F
       xor edx,edx
       div ebx
      mov [d edi+CIncF],eax    ;' Ready.
      mov al, [edi+CTickCmd2]  ;' 2nd effect ?
      or al,al
       jnz @2NDEffect
      jmp @ChannelFinishedTx



























