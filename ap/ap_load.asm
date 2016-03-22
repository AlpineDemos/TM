;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;'ÜÛÛÛÛÛßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßßßÛÛÛÛÛÛÜ	ßßßßßßßßßßÛÛÛÛÛÛÜ ALPINE PLAYER V3.00'
;'ÛÛÛÛÛÛ    ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ		ßßÛÛÛÛÛÛÛ  (C) 1997          '
;'ÛÛÛÛÛÛ ßßßÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛßßßßßßßßß 	ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß by Syrius / Alpine '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;' TM3 - No Output!                                                          '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC APOpen            ; Destroys: ---         Needs: EAX:ADDR CX:NUM
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  add ecx,[_Code32a]
  shld ebx,ecx,28
  and ecx,0Fh
  mov [v86r_ds],bx
  mov [v86r_dx],cx
  mov [v86r_ax],03D40h
  mov al,21h
  int 33h
  mov ax,[v86r_ax]
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC APClose           ; Destroys: ---         Needs: EAX:ADDR CX:NUM
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  mov ax,[_TM3Handle]
  mov [v86r_bx],ax
  mov [v86r_ah],3Eh
  mov al,21h
  int 33h
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC APRead           ; Destroys: ---         Needs: EAX:ADDR CX:NUM
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad
  add eax, [_Code32a]
  shld ebx,eax,28
  and eax,0Fh
  mov [v86r_ds],bx
  mov [v86r_dx],ax
  mov [v86r_cx],cx
  mov [v86r_ax],3F00h
  mov ax,[_TM3Handle]
  mov [v86r_bx],ax
  mov al,21h
  int 33h
  popad
  Ret
 ENDP

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
    MACRO APReadM Addr, Num       ; D: EAX, CX   N: CX = Num, EAX = ADDR
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  mov eax, O Addr
  IFNB <Num>
    mov cx,Num
  ENDIF
  Call APRead
  jc @TM3Error
 ENDM

;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
     PROC LoadTM3_ near  ; Destroys ---    Needs: Ecx = Offset of SongName
                         ; Returns: AL = 0 (OKAY)  <>  0 (ERRORCODE)
;(*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*);
  pushad
  Call APOpen
  jc @TM3Error
  mov [_TM3Handle],ax
  APReadM _Masterspace,2
  APReadM _GlobalVol,1
  APReadM _Speed,1
  APReadM _BPM,1
  xor ax,ax
  mov al,[_BPM]
  shl ax,1
  mov bl,5
  div bl
  mov [_Tempo],al

  APReadM _Channels,1
  APReadM _SongLen, 1
  xor cx,cx
  mov cl, [_Songlen]
  APReadM _Order
  APReadM _PatNum,1
  APReadM _SmpNum,1
  mov cl,[_Channels]
  APReadM _Panning

  xor eax,eax
  mov al,[_SmpNum]
  inc al            ;' + ein LeerSample.
  shl eax,4
  call _getmem
  jc @MEMError
  mov [_SampleP],eax

  mov eax, 320  ;'64*5
  xor ebx,ebx
  mov bl,[_Channels]
  mul bx
  mov [_PatternLen],eax

 ;{°°°° GENERAL SAMPLE-DATA °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

  Call CalcVolTable
  mov edi,[_SampleP]
  xor ecx,ecx
  mov cl,[_SmpNum]
  mov ebp,ecx
  @SmpDLoop:
    mov cx, 12
    mov eax, edi
    add eax, 4
    Call APRead
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

  mov cl,[_SmpNum]
  APReadM _SampleVols

 ;{°°°° READ PATTERNS °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  xor eax,eax
  mov al, [_PatNum]
  mov ebp,[_PatternLen]
  mul ebp
  shr ebp,2
  call _gethimem
  jc @MEMError
  mov edi,eax
  xor eax,eax
  mov al,5
  mul [_Channels]
  mov [_LineAdd],eax
  mov dl,[_PatNum]
  mov ebx,o _PTRPattern
  @PattrnLoop:
   mov [EBX],edi          ;' Save Start of Pattern
   APReadM _PackedLen, 2
   mov eax, [_PostProcP]
   mov cx,[_PackedLen]
   Call APRead
   mov ecx,ebp
   xor eax,eax
   push edi
   rep stosd
   pop edi                ;' ECX=0
   mov esi,[_PostProcP]
   push ebx
   @UnPackPattern:
    mov dh,[ESI]
    inc esi
    or dh,dh
    jne @NoNextLine
      add edi,[_LineAdd]
      inc ecx
      cmp ecx,64
      jne @UnPackPattern
      jmp @EndUnpackPattern
    @NoNextLine:
    xor ebx,ebx
    mov bl,dh
    and bl,31
    cmp bl,[_Channels]
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
  mov dl,[_SmpNum]
  mov ebx,[_SampleP]
  @SmpLoop:
   mov edi,[EBX]                ;' Get Start of Sample
   mov ebp, [EBX+4]
   mov eax, [_PostProcP]
   mov cx,bp
   Call APRead
   mov ecx, ebp
   mov esi, [_PostProcP]         ;' Offset of TM3Buffer
   rep movsb
   add ebx,16
   dec edx
  jne @SmpLoop

 ;{°°°° CLOSE FILE °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}

@Close:
  Call APClose
  popad
  mov al,1
  Ret

 ;{°°°° ERRORS °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°}
  @TM3Error:
  popad
  xor al,al
  Ret
  @MEMError:
  popad
  xor al,al
  Ret
 ENDP


