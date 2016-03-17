IDEAL
P386
ASSUME CS:Code, DS:Data
INCLUDE "FLATASM.ASM"
INCLUDE "SB1.ASM"
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
SEGMENT Code Public

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
PROC LoadGrf Near
 mov ax,3D40h           ;Load GFX
 lea dx,[TXTName]
 int 21h
 mov bx,ax              ;Handle always in BX
 push ds
 mov ax,0B800h
 xor dx,dx
 mov ds,ax
 mov ah,3Fh
 mov cx,8000
 int 21h
 pop ds
 mov ah,3Eh
 int 21h
 Ret
ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
MACRO InitText Rows
 mov ax,0003h
 int 10h
 IF Rows EQ 50
  mov ax,1112h
  int 10h
 ENDIF
 mov ax,0600h
 xor cx,cx
 mov dx,3250h
 mov bh,7
 int 10h
ENDM

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
MACRO DBin2Hex Dest, Len
Local @Lp1, @nohex
 mov bx,Len
 @lp1:
  mov al,dl
  and al,15
  add al,'0'
  cmp al,'9'
  jbe @nohex
   add al,'A'-'9'-1
  @nohex:
  mov [Dest+bx-1],al
  shr edx,4
  dec bx
 jne @lp1
ENDM

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
Start:
 mov dx,Data
 mov ds,dx
 mov ax,Data2
 shl eax,16
 mov [LoadBuffer],eax   ;Initialize Data
 InitText 25
 Call SBDetect
 test al,al
 jnz @SBda
  mov ax,4C01h
  int 21h
 @SBda:
 mov [FlatRequired],200 ;200kB should do...
 call InitFlatMEM
 test al,al
 jz @AllesOK
  mov ax,4C00h
  int 21h
 @AllesOK:

 mov eax,[FlatStart]
 mov [FlatPos],eax      ;Set StartPoint for Mod in RMEM

 call ALoadMod          ;Load Mod
 test al,al
 jnz @OKLoaded
  mov ah,09h            ;Error During Loading...
  lea dx,[ErrorLoad]
  int 21h
  Call CloseFlatMEM
  mov ax,4C01h
  int 21h
 @OKLoaded:             ;Ok, Mod Loaded

 Xor ebx,ebx
 mov dx,3dah
 @wr1:
 in al,dx
 and al,8
 cmp al,0
 jne @wr1
 @wr2:
 in al,dx
 and al,8
 inc ebx
 cmp al,8
 jne @wr2
 mov [Performance],ebx



 mov [modloop],1
 Call PlayMod
 mov ah,09h
 lea dx,[Playing]
 int 21h


 ;---------------Main-Loop
 mov ax,0B800h
 mov es,ax
 @W1:
  mov ah,01
  int 16h
  jnz @outloop

  Xor ebx,ebx
  mov dx,3dah
  @wr3:
  in al,dx
  and al,8
  cmp al,0
  jne @wr3
  @wr4:
  in al,dx
  and al,8
  inc ebx
   cmp al,8
  jne @wr4
  mov [Performance],ebx

  mov edx,[Performance]
  DBin2Hex PF,8
  mov ah,09h
  lea dx, [perfect]
  int 21h

 cmp [EndeMod],1
 jne @W1
 @outloop:
 ;--------------Until-Here
 xor ah,ah
 int 16h

 Call StopMod

 mov ah,09h
 lea dx,[Stopped]
 int 21h

 Call CloseFlatMEM
 @EndePlayer:
 mov ax,4C00h
 int 21h
ENDS


SEGMENT Data
 Performance dd ?
 Perfect db "Performance needed in %"
 PF db "00000000h % of Processor Performance",13,10,"$"

 LoadName  db "C:\FT2\ASM.Mod",0
 TXTName   db "Module4.Grf",0
 Playing   db " STATUS: Playing...   Press Any Key To Exit...","$"
 Stopped   db 37 dup (8),"Stopped."
           db 50 dup (32)
           db 13,10,"$"
 ErrorLoad db " ERROR Reading MOD-File! Check For Correct Path! ",13,10,"$"
ENDS

SEGMENT Data2
 PAL db 768 dup (?)
 PIC db 64000 dup (?)
ENDS

SEGMENT SSeg STACK
 db 500 dup (?)
ENDS

END Start