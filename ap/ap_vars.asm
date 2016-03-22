;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;'ßßßßßßßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßÛßÛÛÛÛÛÛÜ	ßßßßßßßßßßÛÛÛÛÛÛÜ THE MODULE V3.00á  '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ ß ÛÛÛÛÛÛÛ		ßßÛÛÛÛÛÛÛ  (C) Spring 1997   '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ	ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß by Syrius / Alpine '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;' VARIABLES NEEDED FOR TM3-PLAYER                                           '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

;{Û²±° General Data... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}

 _StartPattern dd ?
 _TM3SyncF     dw ?
 _TM3SyncCount dd ?

 _ChCount      db ?                ;' Channel-Counter
 _Stereo       db ?                ;' 0=Mono, 1=Stereo
 _SongLoop     db ?
 _PatternLen   dd ?

 _CSampleP   dd ?
 _SampleP    dd ?
 _TM3BufferP dd ?
 _MixBufP    dd ?
 _PostProcP  dd ?

;ALIGN 16

 _VolTable db 16640 dup (?)

 _PTRPattern  dd 128 dup (?)
 _DMABuf      dd ?                 ;' Pointer to Start of TM3Buffer
 _TM3_IRQ     dd ?
 _SoundCard   dw ?

;{Û²±° Hardware Data... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}

 _ADR   dw ?
 _IRQ   db ?
 _DMA   db ?
 _TIRQ  db ?

 _IRQ2 dd ?
       dd ?
 _IRQ3 dd ?
       dd ?
 _IRQ5 dd ?
       dd ?
 _IRQ7 dd ?
       dd ?
 _IRQA dd ?
 _IActive db ?

 _SB_OldIrq   dd ?
              dd ?
 _SB_CallBack dd ?
 _SB_Stub_Buf db 21 dup (?)

 _Port21 db ?
 _PortA1 db ?
 _DMAFlipFlop db ?        ;' Flipflop indicates current of the 4 Buffers
 MixProc     dd ?         ;' Offset of MixStereo or MixMono

;{Û²±° Mixer Data... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}

 _DivConst      dd  ?     ;' Current Mixing-Frequency`s DIV-Const
                         ;' ( for Period->Frequ-Calc )
 _SamplingRate  dw  ?
 _OrdNum        db  ?     ;' Current Position in ORDERS
 _C_BufPosition dd  ?     ;' Buffer-Address !

 _Bytes2Fill    dw  ?     ;' How many Bytes have to be calced from this IRQ yet ?
                         ;'  If this gets 0, the amount of Bytes to calc in this
                         ;'  IRQ is reached, quit IRQ!
 _MaxSampleBytes dw ?     ;' Length of 1 Buffer
 _Bytes4Tick    dw  ?     ;' Bytes from last tick, that have to be calced yet.
 _C_BPT         dw  ?     ;' Current Bytes Per Tick to be mixed
                          ;' It`s just a counter for the Mixing-Procs!!!
 _BytesPerTick  dw  ?     ;' Bytes per Tick -> changes with BPM-Rate!!!
                         ;'  NOT equal to Length of DMA-Buffer
                         ;'  which is in MaxSampleBytes!
 _Ticks         db  ?     ;' Ticks = Speed - 1

 _PatternJMP    db  ?     ;' Pattern to jump to ( not ORDER! )
 _PatternROW    db  ?     ;' Row to jump to
 _PatternLine   db  ?     ;' Current Line in Pattern
 _LoopIt        db  ?     ;' Loop Song ?
 _IRQ_Stop      db  ?     ;' 1=Enable Self-Switch-Down
 _IRQ_Finished  db  ?     ;' 1=Switch-Down fulfilled...
 _ChPointer     dd  ?     ;' Pointer to Current Channel in Pattern

; ALIGN 16

 IFNDEF TM3INC
  _MasterSpace  dw ?
  _GlobalVol    db ?
  _Speed        db ?
  _BPM          db ?     ;' BPM default = 50
  _Tempo        db ?
  _Channels     db ?
  _SongLen      db ?
  _Order        db 128 dup (?)
  _PatNum       db ?
  _SmpNum       db ?
  _Panning      db 32 dup (?)
  _SampleVols   db 100 dup (?)
  _LineAdd      dd ?
  _PackedLen    dw ?
  _TM3Handle    dw ?
 ENDIF


;{Û²±° Buffer... °±²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ}


;ALIGN 16

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
