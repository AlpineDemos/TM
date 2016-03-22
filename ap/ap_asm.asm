;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'
;'ЬЫЫЫЫЫЯЯЯЯЫЫЫЫЫЫЬ  ЫЫЫЫЫЫЫЯЯЯЫЫЫЫЫЫЬ  ЯЯЯЯЯЯЯЯЯЯЫЫЫЫЫЫЬ ALPINE PLAYER V3.00'
;'ЫЫЫЫЫЫ    ЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫ   ЫЫЫЫЫЫЫ          ЯЯЫЫЫЫЫЫЫ  (C) 1997          '
;'ЫЫЫЫЫЫ ЯЯЯЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫЯЯЯЯЯЯЯЯЯ   ЬЬЬЬЬЬЬЬЬЬЫЫЫЫЫЫЯ by Syrius / Alpine '
;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'
;' AP 3.0 PMODE ASM  - Protected Mode - Link-Version.
;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'






o EQU offset
b EQU byte ptr
w EQU word ptr
d EQU dword ptr

IDEAL
P386
ASSUME  cs:code32,ds:code32

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
SEGMENT code32  PARA PUBLIC USE32
MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL

 GLOBAL _StartPattern: DWord
 GLOBAL _TM3SyncCount: DWord
 GLOBAL _SongLoop    : Byte
 GLOBAL _PatternLen  : DWord

 GLOBAL _SoundCard   : Word
 GLOBAL _Stereo      : Byte
 GLOBAL _ADR         : Word
 GLOBAL _IRQ         : Byte
 GLOBAL _DMA         : Byte
 GLOBAL _SamplingRate: Word
 GLOBAL _LoopIt      : Byte

 GLOBAL _DMAFlipFlop : Byte
 GLOBAL _DIVConst    : DWord

 GLOBAL _OrdNum      : Byte
 GLOBAL _PatternLine : Byte

 GLOBAL _IRQ_Stop    : Byte
 GLOBAL _IRQ_Finished: Byte


 GLOBAL _MasterSpace : Word
 GLOBAL _GlobalVol   : Byte
 GLOBAL _Speed       : Byte
 GLOBAL _BPM         : Byte
 GLOBAL _Tempo       : Byte
 GLOBAL _Channels    : Byte
 GLOBAL _SongLen     : Byte
 GLOBAL _PatNum      : Byte
 GLOBAL _SmpNum      : Byte

 GLOBAL _LineAdd     : DWord
 GLOBAL _PackedLen   : Word

 GLOBAL _DMABuf      : DWord ; *

 GLOBAL _CSampleP    : DWord ; *
 GLOBAL _SampleP     : DWord ; *
 GLOBAL _TM3BufferP  : DWord ; *
 GLOBAL _MixBufP     : DWord ; *
 GLOBAL _PostProcP   : DWord ; *

 PUBLIC AP_InitPointers_
 PUBLIC PlayTM3_
 PUBLIC StopTM3_
 PUBLIC checkSBSettings_
 PUBLIC detectSB_

 GLOBAL _PTRPattern  : DWord : 128
 GLOBAL _Order       : Byte : 128
 GLOBAL _VolTable    : Byte : 16640
 GLOBAL _Panning     : Byte : 32
 GLOBAL _SampleVols  : Byte : 100

 INCLUDE "AP_ASM.INC"

;(*ДДДД VARIABLES........ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД*);

 INCLUDE "AP_VARS.ASM"

ENDS

End