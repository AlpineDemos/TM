;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'
;'賽賽賽賽賽栢栢栢�  栢栢栢幡幡栢栢栢�	賽賽賽賽賽栢栢栢� THE MODULE V3.00�  '
;'          栢栢栢�  栢栢栢� � 栢栢栢�		賽栢栢栢�  (C) Spring 1997   '
;'          栢栢栢�  栢栢栢�   栢栢栢�	複複複複複栢栢栢� by Syrius / Alpine '
;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'
;' TM3 - Loader                                                              '
;'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�'


;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);
     PROC LoadTM3    ; Destroys ---        Needs: Eax = Offset of SongName
                     ; Returns: AL = 0 (OKAY)  <>  0 (ERRORCODE)
;(*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴*);

 ;{같같 READ PATTERNS 같같같같같같같같같같같같같같같같같같같같같같같같같같같�}

  mov eax,O Samples
  mov [SampleP],eax

  mov eax,55128*2
  call _getmem
  jc @MEMError
  mov [TM3BufferP],eax
  push ecx
   mov edi,eax
   mov eax,80808080h
   mov ecx,27564
   rep stosd
  pop ecx


  mov eax,2048
  call _getmem
  jc @MEMError
  mov [CSampleP],eax

  mov eax,65536
  call _getmem
  jc @MEMError
  mov [PostProcP],eax

  mov eax,[MaxMemNeeded]
  mov ebp, eax
  call _getmem
  jc @MEMError
  shr ebp,2
  mov edi,eax
  mov dl,[PatNum]
  mov ebx,o PTRPattern
  mov esi,O PackedPatterns
  @PattrnLoop:
   mov [EBX],edi          ;' Save Start of Pattern
   mov ecx,ebp
   xor eax,eax
   push edi
   rep stosd
   pop edi                ;' ECX=0
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
  xor ax,ax

  Ret
  @MEMError:
  mov al,255
  Ret
 ENDP


