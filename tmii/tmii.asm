IDEAL
P386

 PLAYINSTEREO  EQU 1
 ENDLESSLOOP   EQU 1


GROUP Data IData, UData
ASSUME CS:Code, DS:Data

INCLUDE "FLATASM.ASM"
INCLUDE "SB1.ASM"
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
SEGMENT Code Public
PROC GetMODName
 mov ah,62h
 int 21h
 push ds
 push es
 mov ax,DATA2
 mov es,ax
 lea di,[LoadName]
 mov ds,bx
 xor cx,cx
 mov cl,[B 80h]
 dec cl
 mov si,82h
 rep movsb
 xor al,al
 stosb
 pop es
 pop ds
 Ret
ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
PROC LoadGrf Near
 push es
 push ds
 xor di,di
 lea si,[TXTPIC]
 mov ax,0B800h
 mov es,ax
 mov ax,DATA3
 mov ds,ax
 mov cx,2000
 rep movsd
 pop ds
 pop es
 Ret
ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
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

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
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
  mov [B Dest+bx-1],al
  shr edx,4
  dec bx
 jne @lp1
ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
MACRO WriteHex Pos,Len
 local @lp1,@nohex
 mov bx,Len
 @lp1:
  mov al,dl
  and al,15
  add al,'0'
  cmp al,'9'
  jbe @nohex
   add al,'A'-'9'-1
  @nohex:
  mov [B es:Pos+bx-2],al
  shr edx,4
  sub bx,2
 jne @lp1
ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
PROC InfoBox Near
 mov dl,[patnum]
 WriteHex 43*160+60, 4
 mov dl,[speed]
 WriteHex 45*160+60, 4
 mov dx,[patternline]
 WriteHex 44*160+60, 4
 Ret
ENDP

MACRO Line address, len
 local @lf
 lea si, address
 mov cl, len
 @Lf:
  movsb
  inc di
  dec cl
 jne @Lf
ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;Byte 0 [şşşş][şşşş]
;        HInst HNote
;Byte 1 [şşşşşşşş]
;        LowNote
;Byte 1 [şşşş][şşşş]
;        LInst EffNr.
;Byte 3 [şşşşşşşş]
;        EffByte

MACRO WriteData Position
local @@1,@@2,@@E,@@NoEff,@@NoInst,@@NoNote
push bx
push dx
or eax,eax
jne @@1
 lea si,[NDATA]
jmp @@E
@@1:
 mov ecx,08FA08FAh
 mov [D SDATA+00],ecx
 mov [D SDATA+04],ecx
 mov [W SDATA+08],cx
 mov [D SDATA+12],ecx
 mov [W SDATA+16],cx   ;Restore Original Form

 mov cx,ax
 shr eax,16
 mov bl,al
 shr bl,4
 mov bh,cl
 and bh,0F0h
 add bl,bh
 jz @@NoInst
  mov dl,bl
  xor bh,bh
  and bl,0Fh
  mov bl,[Chars+bx]
  mov [B SDATA+02],bl
  mov bl,dl
  shr bl,4
  mov bl,[Chars+bx]
  mov [B SDATA+00],bl
 @@NoInst:

 mov bh,cl
 and bh,0Fh
 mov bl,ch
 test bx,bx
 jz @@NoNote
  mov [B SDATA+05],15
  mov [B SDATA+07],15
  mov [B SDATA+09],15
  mov dx,bx
  xor bh,bh
  and bl,0Fh
  mov bl,[Chars+bx]
  mov [B SDATA+08],bl
  mov bl,dl
  shr bl,04
  mov bl,[Chars+bx]
  mov [B SDATA+06],bl
  mov bl,dh
  mov bl,[Chars+bx]
  mov [B SDATA+04],bl
 @@NoNote:

 mov bx,ax
 and bx,0Fh
 jz  @@NoEff
  mov dl,[Cols+bx]
  mov [B SDATA+13],dl
  mov [B SDATA+15],dl
  mov [B SDATA+17],dl
  mov bl,[Effects+bx]
  mov [B SDATA+12],Bl
  mov bl,ah
  and bl,0Fh
  mov bl,[Chars+bx]
  mov [B SDATA+16],Bl
  mov bl,ah
  shr bl,4
  mov bl,[Chars+bx]
  mov [B SDATA+14],Bl
 @@NoEff:
 lea si,[SDATA]
@@E:
mov cl,9
@@2:
 movsb
 mov al,[si]
 mov ah,[es:di]
 and ah,0F0h
 add al,ah
 stosb
 inc si
 dec cl
jne @@2
add di,2
pop dx
pop bx
ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
PROC WritePattern4
 xor ebx,ebx
 mov bp, 23
 mov dx, [PatternLine]
 sub dx,11
 jl  @skipadd
  mov bx,dx
 @skipadd:
 shl bx,4
 add ebx,[apattern]

 mov di,02*160
 @LineLoop:
  test dx,11000000b
  jnz @DummyLine
   xor eax,eax
   WriteData
   xor ax,ax
   WriteData
   mov eax,[gs:ebx+00]
   WriteData
   mov eax,[gs:ebx+04]
   WriteData
   mov eax,[gs:ebx+08]
   WriteData
   mov eax,[gs:ebx+12]
   WriteData
   xor eax,eax
   WriteData
   xor ax,ax
   WriteData
   add ebx,16
  jmp @NxtOne
  @DummyLine:
   Line [Dummy],79
   add di,2
  @NxtOne:
  inc dx
  dec bp
 jne @LineLoop
 Ret
ENDP


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
PROC WritePattern8
 xor ebx,ebx
 mov bp, 23
 mov dx, [PatternLine]
 sub dx,11
 jl  @skipaddS
  mov bx,dx
 @skipaddS:
 shl bx,5
 add ebx,[apattern]

 mov di,02*160
 @LineLoopS:
  test dx,11000000b
  jnz @DummyLineS
   mov eax,[gs:ebx+00]
   WriteData
   mov eax,[gs:ebx+04]
   WriteData
   mov eax,[gs:ebx+08]
   WriteData
   mov eax,[gs:ebx+12]
   WriteData
   mov eax,[gs:ebx+16]
   WriteData
   mov eax,[gs:ebx+20]
   WriteData
   mov eax,[gs:ebx+24]
   WriteData
   mov eax,[gs:ebx+28]
   WriteData
   add ebx,32
  jmp @NxtOneS
  @DummyLineS:
   Line [Dummy],79
   add di,2
  @NxtOneS:
  inc dx
  dec bp
 jne @LineLoopS
 Ret
ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
Start:
 shl di,4
 mov dx,Data
 mov ds,dx
 mov ax,Data2
 shl eax,16
 mov [LoadBuffer],eax   ;Initialize Data
 InitText 50
 mov ax,1003h
 mov bl,0
 int 10h

 Call GetMODName
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


 mov [modloop],ENDLESSLOOP
 mov [stereo],PLAYINSTEREO
 Call PlayMod

 Call LoadGrf
 mov ah,01h
 mov cx,2000h
 int 10h

 xor ebp,ebp
 mov ax,0B800h
 mov es,ax
 xor ax,ax
 mov gs,ax

 mov dx,[ADR]
 WriteHex 43*160+110, 6
 mov dl,[IRQ]
 WriteHex 44*160+112, 4
 mov dl,[DMA]
 WriteHex 45*160+112, 4
 mov dl,[ModLen]
 WriteHex 43*160+66, 4
 cmp [SBPro],1
 jne @SkipPro
   mov [B es:45*160+88],"P"
   mov [B es:45*160+90],"r"
   mov [B es:45*160+92],"o"
 @SkipPro:
 ;---------------Main-Loop
 @W1:
  mov ah,01
  int 16h
  jnz @outloop

  call InfoBox
  cmp [tracks],1024
  jne @8Tracks
   Call WritePattern4
   jmp @Tready
  @8Tracks:
   Call WritePattern8
  @TReady:

 cmp [EndeMod],1
 jne @W1
 @outloop:
 ;--------------Until-Here
 xor ah,ah
 int 16h

 Call StopMod
 InitText 25

 Call CloseFlatMEM
 @EndePlayer:
 mov ax,4C00h
 int 21h
ENDS

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

SEGMENT Data3
 Include "MODULE5.RAW"
Ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
SEGMENT SSeg STACK
 db 5000 dup (?)
ENDS

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
SEGMENT IData
 TXTName db "MODULE5.ASM","$",0h
 ErrorLoad db " ERROR Reading MOD-File!",13,10,"$"

 Real    db "úúúúú úúú³úúúúú úúú³úúúúú úúú³úúúúú úúú³úúúúú úúú³úúúúú úúú³úúúúú úúú³úúúúú úúú"
 Dummy   db "         ³         ³         ³         ³         ³         ³         ³         "
 NDATA   db "ú",8,"ú",8,"ú",8,"ú",8,"ú",8," ",8,"ú",8,"ú",8,"ú",8
 SDATA   db "ú",8,"ú",8,"ú",8,"ú",8,"ú",8," ",8,"ú",8,"ú",8,"ú",8
 Chars   db "o123456789ABCDEF"
 Effects db "Û",13,"~~~ğ! -""$"
 Cols    db 07h,02h,02h,02h,02h,02h,02h,03h,02h,04h,03h,04h,03h,04h,04h,04h

ENDS
SEGMENT UData
 Hex dd ?
ENDS

SEGMENT Data2
 LoadName  db 256 dup (?)
 DUMMi DB 65279 dup (?)
ENDS



END Start