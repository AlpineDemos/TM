;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'
;'蔔栢栢賽賽栢栢栢�  栢栢栢幡賽栢栢栢�  賽賽賽賽賽栢栢栢� ALPINE PLAYER V3.00'
;'栢栢栢    栢栢栢�  栢栢栢�   栢栢栢�          賽栢栢栢�  (C) 1997          '
;'栢栢栢 賽賞栢栢栢  栢栢栢幡賽賽賽賽   複複複複複栢栢栢� by Syrius / Alpine '
;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'
;' AP 3.0 PMODE ASM  - Protected Mode - Link-Version.
;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'






o EQU offset
b EQU byte ptr
w EQU word ptr
d EQU dword ptr

IDEAL
P386
ASSUME  cs:code32,ds:code32

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
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

;(*컴컴 VARIABLES........컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);

 INCLUDE "AP_VARS.ASM"

ENDS

End