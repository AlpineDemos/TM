;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'
;'賽賽賽賽賽栢栢栢�  栢栢栢幡幡栢栢栢�	賽賽賽賽賽栢栢栢� THE MODULE V3.00�  '
;'          栢栢栢�  栢栢栢� � 栢栢栢�		賽栢栢栢�  (C) Spring 1997   '
;'          栢栢栢�  栢栢栢�   栢栢栢�	複複複複複栢栢栢� by Syrius / Alpine '
;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'
;' TM3 - No Output!                                                          '
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
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
;(* Code                                                                   *);
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);

MASM
INCLUDE C:\'ALPINE\PMODE\pmode.inc
IDEAL
PUBLIC  _main

INCLUDE "TM3_MIX.ASM"

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
  _MAIN: STI
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);

 Call SBDetect
 Call SBWriteInfo

 jmp _exit

;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
;(* Data                                                                   *);
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
 ;昉굅 MainProc... 갚꾼栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

 ;昉굅 Constants... 갚꾼栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢
 INCLUDE "TM3_CONS.ASM"
 INCLUDE "TM3_VARS.ASM"
ENDS

END

