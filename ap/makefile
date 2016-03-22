# makefile for the Alpine 3D Engine

.c.obj:
        wcc386 /d2 $[@
.asm.obj:
        tasm $[@ /m2

APLAYC.exe : APlayC.obj AP_C.OBJ
        wlink D A OPTION DOSSEG system pmodew file APlayC.obj, AP_C.obj

APlayC.obj   : APlayC.C APlayC.H
AP_C.obj     : AP_C.asm AP_MIX.asm AP_C_SB.asm AP_Vars.asm AP_CONST.asm AP_FX1.asm AP_FX2.asm AP_JMP.asm
