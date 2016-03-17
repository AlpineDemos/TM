;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;'ßßßßßßßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßÛßÛÛÛÛÛÛÜ	ßßßßßßßßßßÛÛÛÛÛÛÜ THE MODULE V3.00á  '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ ß ÛÛÛÛÛÛÛ		ßßÛÛÛÛÛÛÛ  (C) Spring 1997   '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ	ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß by Syrius / Alpine '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;' TM3 - Loader                                                              '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC FileRead         ; Destroys: ---         Needs: EAX:ADDR CX:NUM
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad
  add eax, [_Code32a]
  shld ebx,eax,28
  and eax,0Fh
  mov [v86r_ds],bx
  mov [v86r_dx],ax
  mov [v86r_cx],cx
  mov [v86r_ax],3F00h
  mov ax,[TM3Handle]
  mov [v86r_bx],ax
  mov al,21h
  int 33h
  popad
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     MACRO FRead Addr, Num  ; Destroys: EAX, CX Needs: CX = Num, EAX = ADDR
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  mov eax, O Addr
  IFNB <Num>
    mov cx,Num
  ENDIF
  Call FileRead
  jc @TM3Error
 ENDM

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC LoadTM3    ; Destroys ---        Needs: Eax = Offset of SongName
                     ; Returns: AL = 0 (OKAY)  <>  0 (ERRORCODE)
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);

  mov eax,110256  ;'Quadro+Stereo+Other buffer.
  call _getlomem
  jc @MEMError
  mov [TM3BufferP],eax
  push ecx
   mov edi,eax
   mov eax,80808080h
   mov ecx,27564
   rep stosd
  pop ecx

  mov eax,65536
  call _getlomem
  jc @MEMError
  mov [PostProcP],eax

  mov eax,2048
  call _getlomem
  jc @MEMError
  mov [CSampleP],eax

  add ecx,[_Code32a]
  shld ebx,ecx,28
  and ecx,0Fh
  mov [v86r_ds],bx
  mov [v86r_dx],cx
  mov [v86r_ax],03D40h
  mov al,21h
  int 33h
  jc @TM3Error
  mov ax,[v86r_ax]
  mov [TM3Handle],ax
  FRead Masterspace,2
  FRead GlobalVol,1
  FRead Speed,1
  FRead BPM,1
  xor ax,ax
  mov al,[BPM]
  shl ax,1
  mov bl,5
  div bl
  mov [Tempo],al

  FRead Channels,1
  FRead SongLen, 1
  xor cx,cx
  mov cl, [Songlen]
  FRead Order
  FRead PatNum,1
  FRead SmpNum,1
  mov cl,[Channels]
  FRead Panning

  xor eax,eax
  mov al,[SmpNum]
  inc al            ;' + ein LeerSample.
  shl eax,4
  call _getmem
  jc @MEMError
  mov [SampleP],eax

  mov eax, 320  ;'64*5
  xor ebx,ebx
  mov bl,[Channels]
  mul bx
  mov [PatternLen],eax

 ;{°°°° GENERAL SAMPLE-DATA °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

  Call CalcVolTable
  mov edi,[SampleP]
  xor ecx,ecx
  mov cl,[SmpNum]
  mov ebp,ecx
  @SmpDLoop:
    mov cx, 12
    mov eax, edi
    add eax, 4
    Call FileRead
    mov eax,[edi+4]
    call _getmem        ;' Allocate himem for Samples
    jc @MEMError
    mov [edi],eax       ;' Save Offset in Himem.
    add edi,16
    dec ebp
  jne @SmpDLoop
  xor eax,eax           ;' Set up 1 Empty Sample!
  stosd
  stosd
  dec eax
  stosd
  mov eax,00010000h
  stosd

  mov cl,[SmpNum]
  FRead SampleVols

 ;{°°°° READ PATTERNS °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  xor eax,eax
  mov al, [PatNum]
  mov ebp,[PatternLen]
  shr ebp,2
  mul ebp
  call _gethimem
  jc @MEMError
  mov edi,eax
  xor eax,eax
  mov al,5
  mul [Channels]
  mov [LineAdd],eax
  mov dl,[PatNum]
  mov ebx,o PTRPattern
  @PattrnLoop:
   mov [EBX],edi          ;' Save Start of Pattern
   FRead PackedLen, 2
   mov eax, [PostProcP]
   mov cx,[PackedLen]
   Call FileRead
   mov ecx,ebp
   xor eax,eax
   push edi
   rep stosd
   pop edi                ;' ECX=0
   mov esi,[PostProcP]
   push ebx
   @UnPackPattern:
    mov dh,[ESI]
    inc esi
    or dh,dh
    jne @NoNextLine
      add edi,[LineAdd]
      inc ecx
      cmp ecx,64
      jne @UnPackPattern
      jmp @EndUnpackPattern
    @NoNextLine:
    xor ebx,ebx
    mov bl,dh
    and bl,31
    cmp bl,[Channels]
    jb @NoChOverflow
      test dh,32                ;' If Channel>MaxChannel -> Skip these vals...
      jz @NoNoteSmpX
       add esi,2
      @NoNoteSmpX:
      test dh,64
      jz @NoVolumeColX
       inc esi
      @NoVolumeColX:
      test dh,128
      jz @NoEffectX
       add esi,2
      @NoEffectX:
      jmp @UnPackPattern
    @NoChOverflow:
    lea ebx,[4*ebx+ebx]         ;' * 5 ;)  -> EBX+EDI = ADDRESS!
    test dh,32
    jz @NoNoteSmp
     lodsw
     mov [EDI+EBX+1],ax
    @NoNoteSmp:
    test dh,64
    jz @NoVolumeCol
     lodsb
     mov [EDI+EBX],al
    @NoVolumeCol:
    test dh,128
    jz @NoEffect
     lodsw
     mov [EDI+EBX+3],ax
    @NoEffect:
   jmp @UnPackPattern
   @EndUnpackPattern:
   pop ebx
   add ebx,4
   dec dl
  jne @PattrnLoop

 ;{°°°° READ SAMPLES °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  xor edx,edx
  mov dl,[SmpNum]
  mov ebx,[SampleP]
  @SmpLoop:
   mov edi,[EBX]                ;' Get Start of Sample
   mov ebp, [EBX+4]
   mov eax, [PostProcP]
   mov cx,bp
   Call FileRead
   mov ecx, ebp
   mov esi, [PostProcP]         ;' Offset of TM3Buffer
   rep movsb
   add ebx,16
   dec edx
  jne @SmpLoop

 ;{°°°° CLOSE FILE °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

@Close:

  mov ax,[TM3Handle]
  mov [v86r_bx],ax
  mov [v86r_ah],3Eh
  mov al,21h
  int 33h
  clc
  Ret

 ;{°°°° ERRORS °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  @TM3Error:
  stc
  Ret
  @MEMError:
  stc
  Ret
 ENDP


