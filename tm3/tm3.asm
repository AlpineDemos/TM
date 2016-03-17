;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'
;'ЯЯЯЯЯЯЯЯЯЯЫЫЫЫЫЫЬ  ЫЫЫЫЫЫЫЯЫЯЫЫЫЫЫЫЬ	ЯЯЯЯЯЯЯЯЯЯЫЫЫЫЫЫЬ THE MODULE V3.00б  '
;'          ЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫ Я ЫЫЫЫЫЫЫ		ЯЯЫЫЫЫЫЫЫ  (C) Spring 1997   '
;'          ЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫ   ЫЫЫЫЫЫЫ	ЬЬЬЬЬЬЬЬЬЬЫЫЫЫЫЫЯ by Syrius / Alpine '
;'ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД'
IDEAL
P386
ASSUME  cs:code32,ds:code32

o EQU OFFSET
b EQU BYTE PTR
w EQU WORD PTR
d EQU DWORD PTR

SEGMENT code16  PARA PUBLIC USE16
ENDS

SEGMENT code32  PARA PUBLIC USE32
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
; Code                                                                       ;
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
 INCLUDE "TM3_CONST.ASM"
 INCLUDE "TM3_MIX.ASM"
 GLOBAL SBDetect:Proc
 GLOBAL SBWriteInfo:Proc
 GLOBAL PlayTM3:Proc
 GLOBAL StopTM3:Proc
 GLOBAL LoadTM3:Proc

 GLOBAL TM3SyncCount: DWord
 GLOBAL SBVer: Word
 GLOBAL Stereo: Byte
 GLOBAL LoopIt: Byte
 GLOBAL SamplingRate:Word

 GLOBAL ADR: Word
 GLOBAL IRQ: Byte
 GLOBAL DMA: Byte

 GLOBAL SampleP:DWord
 GLOBAL CSampleP:DWord
 GLOBAL PatternLine:Byte
 GLOBAL Speed:Byte
 GLOBAL GlobalVol:Byte

 GLOBAL Channels:Byte
 GLOBAL StartPattern:DWord
 GLOBAL CPattern:Byte
 GLOBAL Songlen:Byte
 GLOBAL OrderP:DWord
 GLOBAL PatNum:Byte

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
; Data                                                                       ;
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД;
 INCLUDE "TM3_VARS.ASM"
ENDS

END

