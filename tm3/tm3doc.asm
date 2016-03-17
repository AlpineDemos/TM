TM3 V3.0                                       Summer 1997 by Syrius / Alpine
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

 Function of asynchron Buffer-Fill:

 At IRQ:
   Get Number of Sample-Bytes to Fill ( MaxSampleBytes )
   Current Buffer is empty -> 'Bytes2Fill' = 'MaxSampleBytes'.
   Get Bytes, that have to be calced to complete last tick: Bytes4Tick.
   compare, if this amount is larger than Bytes2Fill:
            yes, calc all 'Bytes2Fill' Bytes, recalc 'Bytes4Tick', quit.
            no, calc 'Bytes4Tick' Bytes -> 'Bytes4Tick' = 0 -> next tick can
                be calced. Recalc 'Bytes2Fill' !

 For the Mainloop:
   Get 'BytesPerTick' which depends on 'BPM' and is NOT equal to
          'MaxSampleBytes'!!!
   This value becomes 'Bytes4Tick' and gets decreased by the MixingProc.
   Now compare, if the whole Tick fits into the Buffer (cmp with 'Bytes2Fill')
         no: calc 'Bytes2Fill' Bytes and quit current IRQ.
         yes: calc all 'Bytes4Tick' Bytes )
              then start the new Tick...

