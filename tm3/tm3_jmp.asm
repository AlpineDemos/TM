;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'
;'賽賽賽賽賽栢栢栢�  栢栢栢幡幡栢栢栢�	賽賽賽賽賽栢栢栢� THE MODULE V3.00�  '
;'          栢栢栢�  栢栢栢� � 栢栢栢�		賽栢栢栢�  (C) Spring 1997   '
;'          栢栢栢�  栢栢栢�   栢栢栢�	複複複複複栢栢栢� by Syrius / Alpine '
;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'
;' JUMP-TABLE FOR EFFECTS...                                                 '
;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'

JumpTable   dd O @ChannelFinished;'00h
            dd O @SetSpeed       ;'01h
            dd O @PatternJMP     ;'02h
            dd O @PatternBreak   ;'03h
            dd O @VSlide         ;'04h
            dd O @PortaDn        ;'05h
            dd O @PortaUp        ;'06h
            dd O @TonePorta      ;'07h
            dd O @Vibrato        ;'08h
            dd O @Vibrato        ;'09h
            dd O @Tremor         ;'0Ah
            dd O @Arpeggio       ;'0Bh
            dd O @VibVSlide      ;'0Ch
            dd O @PortaVSlide    ;'0Dh
            dd O @SampleOffset   ;'0Eh
            dd O @Retrig         ;'0Fh
            dd O @Tremolo        ;'10h
            dd O @PatternDelay   ;'11h
            dd O @SetLoopStart   ;'12h
            dd O @LoopPattern    ;'13h
            dd O @NoteCut        ;'14h
            dd O @NoteDelay      ;'15h
            dd O @SetTempo       ;'16h
            dd O @SetGlobalVol   ;'17h
            dd O @SetPanning     ;'18h

JumpTableTx dd O @ChannelFinishedTx ;'00h
            dd O @VSlideUp          ;'01h
            dd O @VSlideDn          ;'02h
            dd O @PSlideDn          ;'03h
            dd O @PSlideUp          ;'04h
            dd O @TRetrig           ;'05h
            dd O @TVibrato          ;'06h


RetrigVols  dd O @ChannelFinishedTx
            dd O @RVol_1
            dd O @RVol_2
            dd O @RVol_4
            dd O @RVol_8
            dd O @RVol_16
            dd O @RVol23
            dd O @RVol12
            dd O @ChannelFinishedTx
            dd O @RVol1
            dd O @RVol2
            dd O @RVol4
            dd O @RVol8
            dd O @RVol16
            dd O @RVol32
            dd O @RVol2















