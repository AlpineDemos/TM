;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;'ßßßßßßßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßÛßÛÛÛÛÛÛÜ	ßßßßßßßßßßÛÛÛÛÛÛÜ THE MODULE V3.00á  '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ ß ÛÛÛÛÛÛÛ		ßßÛÛÛÛÛÛÛ  (C) Spring 1997   '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ	ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß by Syrius / Alpine '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;' VARIABLES NEEDED FOR TM3-PLAYER                                           '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

;{Û²±° General Data... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}

 StartPattern dd ?
 TM3SyncF     dw ?
 TM3SyncCount dd ?

 ChCount      db ?                ;' Channel-Counter
 Stereo       db ?                ;' 0=Mono, 1=Stereo
 SongLoop     db ?
 PatternLen   dd ?

 ALIGN 16

 PTRPattern  dd 128 dup (?)
 DMABuf      dd ?                 ;' Pointer to Start of TM3Buffer
 TM3_IRQ     dd ?
 SBVer       dw ?

;{Û²±° Hardware Data... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}

 ADR   dw ?
 IRQ   db ?
 DMA   db ?

 IRQ2 dd ?
 IRQ3 dd ?
 IRQ5 dd ?
 IRQ7 dd ?
 IRQA dd ?

 SB_OldIrq   dd ?
 SB_CallBack dd ?
 SB_Stub_Buf db 21 dup (?)

 Port21 db ?
 PortA1 db ?
 DMAFlipFlop db ?        ;' Flipflop indicates current of the 4 Buffers
 MixProc     dd ?        ;' Offset of MixStereo or MixMono

;{Û²±° Mixer Data... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}

 DivConst      dd  ?     ;' Current Mixing-Frequency`s DIV-Const
                         ;' ( for Period->Frequ-Calc )
 SamplingRate  dw  ?
 CPattern      db  ?     ;' Current Position in ORDERS
 C_BufPosition dd  ?     ;' Buffer-Address !

 Bytes2Fill    dw  ?     ;' How many Bytes have to be calced from this IRQ yet ?
                         ;'  If this gets 0, the amount of Bytes to calc in this
                         ;'  IRQ is reached, quit IRQ!
 MaxSampleBytes dw ?     ;' Length of 1 Buffer
 Bytes4Tick    dw  ?     ;' Bytes from last tick, that have to be calced yet.
 C_BPT         dw  ?     ;' Current Bytes Per Tick to be mixed
                         ;' It`s just a counter for the Mixing-Procs!!!
 BytesPerTick  dw  ?     ;' Bytes per Tick -> changes with BPM-Rate!!!
                         ;'  NOT equal to Length of Len of DMA-Buffer
                         ;'  which is in MaxSampleBytes!
 Ticks         db  ?     ;' Ticks = Speed - 1

 PatternJMP    db  ?     ;' Pattern to jump to ( not ORDER! )
 PatternROW    db  ?     ;' Row to jump to
 PatternLine   db  ?     ;' Current Line in Pattern
 LoopIt        db  ?     ;' Loop Song ?
 IRQ_Stop      db  ?     ;' 1=Enable Self-Switch-Down
 IRQ_Finished  db  ?     ;' 1=Switch-Down fulfilled...
 ChPointer     dd  ?     ;' Pointer to Current Channel in Pattern
 TM3CalcBuf    dd  ?

 ALIGN 16

 IFNDEF TM3INC
  MasterSpace  dw ?
  GlobalVol    db ?
  Speed        db ?
  BPM          db ?     ;' BPM default = 50
  Tempo        db ?
  Channels     db ?
  SongLen      db ?
  Order        db 128 dup (?)
  PatNum       db ?
  SmpNum       db ?
  Panning      db 32 dup (?)
  SampleVols   db 100 dup (?)
  LineAdd      dd ?
  PackedLen    dw ?
  TM3Handle    dw ?
 ENDIF


;{Û²±° Buffer... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}

 CSampleP   dd ?
 SampleP    dd ?
 TM3BufferP dd ?
 MixBufP    dd ?
 PostProcP  dd ?

 Voltable    db 16640 dup (?)

;'STRUC SampleStruc
;' Start     dd ?     ;0
;' Length    dd ?     ;4
;' LStart    dd ?     ;8
;' C2SPD     dd ?     ;12
;'ENDS
;'
;'STRUC CurrentSampleStruc   64 Byte pro Channel = 256 Bytes
;' Start      dd ?     ;0
;' Length     dd ?     ;4
;' LStart     dd ?     ;8
;' C2SPD      dd ?     ;12
;' Volume     db ?     ;16
;' ;---------------------^ 17 Byte Loaded from SampleStruc!
;' MonoVol    db ?     ;17
;' VolLeft    db ?     ;18
;' VolRight   db ?     ;19
;' Panning    db ?     ;20
;' Status     db ?     ;21  Bit 0:  1-> Playing, 0-> Stopped.
;'                     ;    Bit 7:  1-> Left Orientated, 0-> Right orientated
;' Period     dw ?     ;22   Porta 2 note
;' CountI     dd ?     ;24
;' CountF     dw ?     ;28
;' IncF       dw ?     ;30   Intel-Format!!! Lo-Hi
;' IncI       dd ?     ;32
;' DstPeriod  dw ?     ;36   Destination Period for Tone Porta / Source for Vibrato
;' SmpIndex   db ?     ;38 ¿
;' NoteIndex  db ?     ;39 ³    Save it for e.g.
;' VolumeCol  db ?     ;40 ³
;' Effect     db ?     ;41 ³ this @$%#() NOTE-DELAY
;' FXByte     db ?     ;42 Ù          !!!
;'
;' TickCmd    db ?     ;43   Command-Byte as Index to JmpTable2
;' TickCmd2   db ?     ;44   Command-Byte as Index to JmpTable2
;' WorkByte   db ?     ;45
;' WorkByte2  db ?     ;46
;' WorkByte3  db ?     ;47
;' LastVSld   db ?     ;48
;' LastPSldD  db ?     ;49
;' LastPSldU  db ?     ;50
;' LastPorta  db ?     ;51
;' LastVib    db ?     ;52
;' LastVibPos db ?     ;53
;' LastRetrig db ?     ;54
;' LoopStart  db ?     ;55
;' LoopCount  db ?     ;56
;' db57       db ?     ;57
;' db58       db ?     ;58
;' db59       db ?     ;59
;' db60       db ?     ;60
;' db61       db ?     ;61
;' db62       db ?     ;62
;' db63       db ?     ;63
;'ENDS
