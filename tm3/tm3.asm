;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'
;'賽賽賽賽賽栢栢栢�  栢栢栢幡幡栢栢栢�	賽賽賽賽賽栢栢栢� THE MODULE V3.00�  '
;'          栢栢栢�  栢栢栢� � 栢栢栢�		賽栢栢栢�  (C) Spring 1997   '
;'          栢栢栢�  栢栢栢�   栢栢栢�	複複複複複栢栢栢� by Syrius / Alpine '
;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'
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
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
; Code                                                                       ;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
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

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
; Data                                                                       ;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
 INCLUDE "TM3_VARS.ASM"
ENDS

END

