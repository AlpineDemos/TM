;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; ßßßßßßßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßÛßÛÛÛÛÛÛÜ  ßßßßßßßßßßÛÛÛÛÛÛÜ  THE MODULE V3.00á ;
;           ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ ß ÛÛÛÛÛÛÛ          ßßÛÛÛÛÛÛÛ   (C) Spring 1997  ;
;           ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ  ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß  by Syrius / Alpine;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; S3M-to-TM3-Converter...                                                    ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
IDEAL
P386
ASSUME CS:CODE, DS:Buffer

 FX_A = 01h
 FX_B = 02h
 FX_C = 03h
 FX_D = 04h
 FX_E = 05h
 FX_F = 06h
 FX_G = 07h
 FX_H = 08h
 FX_I = 09h
 FX_J = 0Ah
 FX_K = 0Bh
 FX_L = 0Ch
 FX_M = 0Dh
 FX_N = 0Eh
 FX_O = 0Fh
 FX_P = 10h
 FX_Q = 11h
 FX_R = 12h
 FX_S = 13h
 FX_T = 14h
 FX_U = 15h
 FX_V = 16h
 FX_W = 17h
 FX_X = 18h
 FX_Y = 19h
 FX_Z = 1Ah

B EQU Byte Ptr
W EQU Word Ptr
D EQU DWORD Ptr

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; S3M-2-TM3-Converter                                                        ;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
SEGMENT CODE USE16
 S3MFile  db 255 dup (0)
 TM3File  db 255 dup (0)
 TM3Ext   db 'TM3'

 ErrorMSG db ' Error during converting, probably File not found! ',13,10,'$'
 OkayMSG  db ' Converted successfully... ',13,10,'$'
 S3MHandle dw ?
 TM3Handle dw ?
 PanningConst db 0,4,9,13,17,21,26,30,34,38,43,47,51,55,60,64
 Panning        db 32  dup (7)
 PDirection     db 32  dup (0)
 SampleVols     db 100 dup (?)

;ÄHeaderÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 SongName   db 32 dup (?)
 SongLength dw ?
 SmpNum     dw ?
 PatNum     dw ? ; unused Patterns inclusive!
 Flags      dw ?
 Cwt        dw ?
 Signed     dw ?
 SCRM       dd ?
 GlobalVol  db ?
 InitSpeed  db ?
 InitBPM    db ?
 MasterVol  db ?        ; Ignored
 Ultraclick db ?
 DefaultPan db ?
 DummyH1    db 8 dup (?)
 Special    dw ?
 Channel32  db 32 dup (?)

 Order               db 256 dup (?)
 RealOrder           db 256 dup (?)
 RealSonglen         dw ?
 RealPatNum          db ?

 PatternPointer    dw 100 dup (?)
 SampleDataPointer dw 100 dup (?)
 SamplePointer     dd 100 dup (?)
 SampleSaveLen     dd 100 dup (?)
 Remap          db 32  dup (31)

 ChannelNum dw 0
 MasterSpace dw ?

 CRLF db 13,10,'$'

;ÄSampleHeaderÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 SmpHeader  db ?
 FileName   db 12 dup (?)
 Memseg     db 3 dup (?)
 SampleLen  dw 2 dup (?)
 LoopBegin  dw 2 dup (?)
 LoopEnd    dw 2 dup (?)
 Volume     db ?
 DummyS1    db ?
 Packing    db ?
 LoopFlag   db ?
 C2SPD      dw 2 dup (?)

 WriteBuf dd ?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO SPrint ADDR    ; Destroys eax, ebx   Needs: Eax = Offset of Message
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  pushad
  push ds
  push cs
  pop ds
  mov dx, offset addr
  mov ah, 09
  int 21h
  pop ds
  popad
 ENDM

  Digits db 'o123456789ABCDEF'
  Buf    db '        $'
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO HexPrint Num; Destroys: ---   Needs: DX = Number; Num = Digits
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  pushad
  Xor bx,bx
  HEXINC = 1
  REPT Num
   mov bl,dl
   and bl,0Fh
   mov al,[Digits+bx]
   mov [Buf+Num-HEXINC],al
   shr edx,4
  HEXINC = HEXINC + 1
  ENDM
  mov [Buf+Num],'$'
  SPrint Buf
  popad
 ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO FRead Handle, Num, Adress    ; Destroys: AX,DX,
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  pusha
  mov ah,3Fh
  mov bx, Handle
  mov cx, Num
  IFNB <ADRESS>
   lea dx, Adress
  ENDIF
  int 21h
  popa
  jc @Errors
 ENDM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO FWrite Handle, Num, Adress   ; Destroys: AX,DX,  Needs: BX=Handle
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  pusha
  mov ah,40h
  mov bx, Handle
  mov cx, Num
  IFNB <ADRESS>
   lea dx, Adress
  ENDIF
  int 21h
  popa
  jc @Errors
 ENDM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO FSeek Handle     ; Destroys: AX,DX,  Needs: CX:DX = POS!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  pusha
  mov ax,4200h
  mov bx, Handle
  int 21h
  popa
  jc @Errors
 ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 MACRO TestEffect Num, Val  ; Destroys: ---  Needs: Num=S3M, Val=TM3-EFFECT!
  local @NotThisEffect
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  cmp al,Num
  jne @NotThisEffect
   mov al,Val
   jmp @FX_Ready
  @NotThisEffect:
 ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC LoadS3M    ; Destroys: All, Needs: --- , Returns: AX=ErrorCode=0 ->Okay
                 ; Function: Converts S3M to TM3
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  push ds
  pop es
  mov ax, 3D40h
  lea dx, [S3MFile]
  int 21h
  jc @Errors
  mov [S3MHandle],ax
  FRead [S3MHandle], 96, [SongName]          ; Read Header

  mov ax,08000h                              ; MASTERVOL
  xor bx,bx
  xor dx,dx
  mov bl,[MasterVol]
  and bl,127
  cmp bl,16
  jae @NoMV16
    mov bl,16
  @NoMV16:
  div bx
  mov [MasterSpace],ax

  FRead [S3MHandle], [Songlength], [Order]
  mov cx,[SmpNum]                              ; Read Parapointers
  shl cx,1
  FRead [S3MHandle], cx, [SampleDataPointer]
  mov cx,[PatNum]
  shl cx,1
  FRead [S3MHandle], cx, [PatternPointer]
  mov dl,[DefaultPan]
  HexPrint 2
  cmp [DefaultPan],0FCh
  jne @NoPanningInfo
   test [MasterVol],128
   jz @NoPanningInfo                           ; ie MONO-Flag was set!
     FRead [S3MHandle], 32, [Panning]
     xor di,di
     @ANDLoop:
      and [Panning+di],0Fh
      inc di
      test di,32
     jz @ANDLoop
  @NoPanningInfo:

; At this Point the Header is ready, so convert the data and save it into TM3!

  mov cx, [Songlength]
  xor edi,edi
  xor esi,esi
  xor ah,ah                     ; ah=Num of Patterns!
  @ReOrder:
   mov al,[Order+di]
   cmp al,254
   jae @SkipMarker
     mov [RealOrder+Si],al
     inc si
     cmp al,ah
     jb @SkipMarker
     mov ah,al
   @SkipMarker:
   inc di
   cmp di,cx
  jne @ReOrder
  inc ah
  mov [RealSongLen],si
  mov [RealPatNum] ,ah

  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ So, now, let's get the Num of Channels...

  xor di,di
  xor bx,bx
  @chk:
   mov al,[Channel32+di]
   test al,128
   jnz @ChDisabled
    mov [Remap+di],bl
    cmp al,7
    jbe @LeftOr
     mov [PDirection+bx],64     ; Set Panning-Direction to Right
    @LeftOr:
    push bx
    mov bl,[Panning+di]
    mov al,[PanningConst+bx]
    pop bx
    mov [Panning+bx],al   ; Panning Values!!!
    inc bx
   @ChDisabled:
   inc di
   cmp di,32
  jne @chk
  mov [ChannelNum],bx

  mov ah, 3Ch                 ; Create TM3-File
  xor cx,cx
  lea dx, [TM3File]
  int 21h
  jc @Errors
  mov [TM3Handle],ax

  FWrite [TM3Handle], 2, [MasterSpace]
  FWrite [TM3Handle], 3, [GlobalVol]
  FWrite [TM3Handle], 1, [ChannelNum]
  FWrite [TM3Handle], 1, [RealSongLen]
  FWrite [TM3Handle], [RealSongLen], [RealOrder]
  FWrite [TM3Handle], 1, [RealPatNum]
  FWrite [TM3Handle], 1, [SmpNum]

  cmp [DefaultPan],0FCh
  jne @DirectionSave
   FWrite [TM3Handle], [ChannelNum], [Panning]
   jmp @EndDirect
  @DirectionSave:
   FWrite [TM3Handle], [ChannelNum], [PDirection]
  @EndDirect:
  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ so the header is ready, let's go to the Sample-Data

  xor di,di
  xor si,si
  xor bp,bp
  @LoadInstruments:
   xor edx,edx
   mov dx,[SampleDataPointer+di]
   shl edx,4
   shld ecx,edx,16                      ; CX:DX = Offset in File!
   FSeek [S3MHandle]
   FRead [S3MHandle], 36, [SmpHeader]
   mov al,[Volume]
   mov [SampleVols+bp],al
   xor eax,eax
   mov al,[MemSeg]
   shl eax,16
   mov ax,[w Memseg+1]
   Shl eax,4
   mov [SamplePointer+si],eax      ; Save Real Pointer to Samples
   xor eax,eax
   xor ebx,ebx
   mov ax,[SampleLen]
   mov [w SampleSaveLen+Si],ax     ; LowWord = Bytes to be Read
   mov ax,[LoopEnd]
   mov bx,[LoopBegin]
   test [LoopFlag],1
   jnz @LoopOn
    mov ax, [SampleLen]
    mov ebx,-1
   @LoopOn:
   mov [w SampleSaveLen+Si+2],ax     ; HiWord = Bytes to be Written
   mov [WriteBuf],eax
   FWrite [TM3Handle],4,[WriteBuf]      ; Write SampleLength
   mov [WriteBuf],ebx
   FWrite [TM3Handle],4,[WriteBuf]      ; Write Loop-Start
   xor edx,edx
   mov eax,20AB0000h
   xor ebx,ebx
   mov bx,[C2SPD]
   div ebx
   mov [WriteBuf],eax
   FWrite [TM3Handle],4,[WriteBuf]      ; Write C2SPD
   add si,4
   add di,2
   inc bp
   cmp bp,[SmpNum]
  jne @LoadInstruments
   FWrite [TM3Handle],[SmpNum],[SampleVols]

  ;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Sample-Data is Read, now it's the pattern's turn!

  push BUFFER
  pop ds
  xor di,di
  @LoopDaPatterns:
   xor edx,edx
   mov dx,[PatternPointer+di]
   shl edx,4
   shld ecx,edx,16              ; CX:DX = offset to Pattern in File
   FSeek  [S3MHandle]
   FRead  [S3MHandle], 2, [PatternLength]
   FRead  [S3MHandle], [PatternLength], [PatternData]
   FWrite [TM3Handle], 2, [PatternLength]

   lea si,[PatternData]    ; Modify PatternData!
   xor bx,bx
   mov bp,64
   @LineLoop:
    mov bl,[si]
    or bl,bl
    jne @LineNotReady
     inc si
     dec bp
     jne @LineLoop
     jmp @EndLineLoop
    @LineNotReady:
    and bx,31           ; Do Remapping
    mov al,[Remap+bx]
    mov bl,[si]
    and bl,11100000b
    add bl,al
    mov [si],bl
    inc si

    test bl,32          ; Instrument/Note ?
    jz @NoSmpNote
      mov ah,[si]       ; Note
      mov al,[si+1]     ; Inst!
      cmp al,[b SmpNum]
      jb @NoMaxInst
       mov al,[b SmpNum]
      @NoMaxInst:
      mov [si],ax
      mov al,ah
      cmp al,254
      jb @No255Note
      je @NoNote
       mov [b si+1],0
       jmp @NoNote
      @No255Note:
       mov dl,al
       and dl,0Fh
       shr al,4
       mov ah,12
       mul ah
       add al,dl
       inc al
       shl al,1
       mov [si+1],al
      @NoNote:
       add si,2
    @NoSmpNote:
    test bl,64
    jz @NoVolumeCol
     inc [b si]          ; Inc Volume (0=no entry!)
     inc si
    @NoVolumeCol:
    test bl,128
    jz @NoEffect
     mov ax,[si]
     TestEffect FX_A, 01h
     TestEffect FX_B, 02h
     TestEffect FX_C, 03h
     TestEffect FX_D, 04h
     TestEffect FX_E, 05h
     TestEffect FX_F, 06h
     TestEffect FX_G, 07h
     TestEffect FX_H, 08h
     TestEffect FX_U, 09h
     TestEffect FX_I, 0Ah
     TestEffect FX_J, 0Bh
     TestEffect FX_K, 0Ch
     TestEffect FX_L, 0Dh
     TestEffect FX_O, 0Eh
     TestEffect FX_Q, 0Fh
     TestEffect FX_R, 10h
     TestEffect FX_T, 16h
     TestEffect FX_V, 17h
     TestEffect FX_X, 18h

;Û²²±±°° S: Extended Functions °°±±²²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ;

     cmp al,FX_S
     jne @NoFX_S
      mov dl,ah
      cmp dl,0B0h
      jne @NoSetPatternLoop
       mov al,12h
       xor ah,ah
       jmp @FX_Ready
      @NoSetPatternLoop:
      and dl,0F0h
      cmp dl,0E0h
      jne @NoPatternDelay
       mov al,11h
       and ah,0Fh
       jmp @FX_Ready
      @NoPatternDelay:
      cmp dl,0B0h
      jne @NoPatternLoop
       mov al,13h
       and ah,0Fh
       jmp @FX_Ready
      @NoPatternLoop:
      cmp dl,0C0h
      jne @NoNoteCut
       mov al,14h
       and ah,0Fh
       jmp @FX_Ready
      @NoNoteCut:
      cmp dl,0D0h
      jne @NoNoteDelay
       mov al,15h
       and ah,0Fh
       jmp @FX_Ready
      @NoNoteDelay:
     @NoFX_S:

     xor ax,ax          ; For all other Non-Supported functions...

     @FX_Ready:
     mov [si],ax
     add si,2
    @NoEffect:
   jmp @LineLoop
   @EndLineLoop:
   FWrite [TM3Handle], [PatternLength], [PatternData] ; Write modified data...

   add di,2
   dec [RealPatNum]
  jne @LoopDaPatterns


  ;--- Pattern-Data saved, along with its Length, now to the Samples

  mov bp,[SmpNum]
  xor di,di
  @SmpReadWriteLoop:
    mov dx,[w SamplePointer+di]
    mov cx,[w SamplePointer+di+2]
    FSeek  [S3MHandle]
    mov cx,[w SampleSaveLen+Di]
    FRead  [S3MHandle], cx, [PatternLength]
     cmp [signed],1
     je  @NotUnSigned
      mov cx, [w SampleSaveLen+Di]
      xor si, si
      @SignLoop:
       xor [b si], 128
       inc si
       dec cx
      jne @SignLoop
    @NotUnsigned:

    mov cx,[w SampleSaveLen+Di+2]
    FWrite [TM3Handle], cx, [PatternLength]
    add di,4
    dec bp
  jne @SmpReadWriteLoop

  mov bx,[TM3Handle]   ; Close Files...
  mov ah,3Eh
  int 21h
  mov bx,[S3MHandle]
  mov ah,3Eh
  int 21h
  xor ax,ax
  Ret
 @Errors:
  mov ax,1
  Ret
 ENDP


Start:
 mov ax,cs
 mov ds,ax
 mov es,ax      ; We don't need no other Segments...

 mov ah,62h
 int 21h
 push ds
   mov di,Offset S3MFile
   mov ds,bx
   xor cx,cx
   mov cl,[B 80h]
   dec cl
   mov si,82h
   rep movsb
   xor al,al
   stosb
   mov di,Offset TM3File
   mov cl,[B 80h]
   sub cl,4
   mov si,82h
   rep movsb
 pop ds
 lea si,[TM3Ext]
 movsw
 movsb
 stosb

 Call LoadS3M
 push cs
 pop ds
 lea dx,[OkayMSG]
 cmp ax,1
 jne @Converted
  lea dx,[ErrorMSG]
 @Converted:
 mov ah,09h
 int 21h
 mov ax,4C00h
 int 21h
ENDS

SEGMENT BUFFER USE16
 PatternLength dw ?
 PatternData db 65530 dup (?)
ENDS

SEGMENT SSeg STACK
 db 500 dup (?)
ENDS
END Start





















@Rubbish:

;Û²²±±°° Volume-Slides °°±±²²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ;

     cmp al, FX_D ;VSlide
     jne NoFX_D
      or ah,ah
      jnz @NoEmptyFX
       mov al,04h
       jmp @FX_Ready
      @NoEmptyFX:
      mov dl,ah   ; Effect-Byte!
      and dl,0Fh
      jnz @NoVSlideUp
       shr ah,4
       mov al,06h
       jmp @FX_Ready
      @NoVSlideUp:
      cmp dl,0Fh
      jne @NoVFineSlideUp
       shr ah,4
       mov al,08h
       jmp @FX_Ready
      @NoVFineSlideUp:
      mov dl,ah
      shr dl,4
      jnz @NoVSlideDn
       and ah,0Fh
       mov al,05h
       jmp @FX_Ready
      @NoVSlideDn:
      cmp dl,0Fh
      jnz @NoVFineSlideDn
       and ah,0Fh
       mov al,07h
       jmp @FX_Ready
      @NoVFineSlideDn:
     NoFX_D:

;Û²²±±°° Pitch Slide Down °°±±²²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ;

     cmp al,FX_E
     jne @NoFX_E
     or ah,ah
     jnz @NoLastFX_E
      mov al,09h
      jmp @FX_Ready
     @NoLastFX_E:
     mov dl,ah
     shr dl,4
     cmp dl,0Fh
     jne @NoFinePortaDown
      and ah, 0Fh
      mov al, 0Bh
      jmp @FX_Ready
     @NoFinePortaDown:
     cmp dl,0Eh
     jne @NoXFinePortaDown
      and ah, 0Fh
      mov al, 0Ch
      jmp @FX_Ready
     @NoXFinePortaDown:
     mov al,0Ah
     jmp @FX_Ready
     @NoFX_E:

;Û²²±±°° Pitch Slide Up   °°±±²²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ;

     cmp al,FX_F
     jne @NoFX_F
     or ah,ah
     jnz @NoLastFX_F
      mov al,0Dh
      jmp @FX_Ready
     @NoLastFX_F:
     mov dl,ah
     shr dl,4
     cmp dl,0Fh
     jne @NoFinePortaUp
      and ah, 0Fh
      mov al, 0Fh
      jmp @FX_Ready
     @NoFinePortaUp:
     cmp dl,0Eh
     jne @NoXFinePortaUp
      and ah, 0Fh
      mov al, 10h
      jmp @FX_Ready
     @NoXFinePortaUp:
     mov al,0Eh
     jmp @FX_Ready
     @NoFX_F:

;Û²²±±°° Vibrato+VSlide   °°±±²²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ;

     cmp al,FX_K
     jne @NoFX_K
     or ah,ah
     jnz @NoLastFX_K
      mov al,16h
      jmp @FX_Ready
     @NoLastFX_K:
     cmp ah,10h
     jb @KSlideDown
      shr ah,4
      mov al,18h
      jmp @FX_Ready
     @KSlideDown:
      and ah,0Fh
      mov al,17h
      jmp @FX_Ready
     @NoFX_K:

;Û²²±±°° Porta + VolSlide °°±±²²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ;

     cmp al,FX_L
     jne @NoFX_L
     or ah,ah
     jnz @NoLastFX_L
      mov al,19h
      jmp @FX_Ready
     @NoLastFX_L:
     cmp ah,10h
     jb @LSlideDown
      shr ah,4
      mov al,1Bh
      jmp @FX_Ready
     @LSlideDown:
      and ah,0Fh
      mov al,1Ah
      jmp @FX_Ready
     @NoFX_L:

