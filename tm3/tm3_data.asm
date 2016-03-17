;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;'ßßßßßßßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßÛßÛÛÛÛÛÛÜ	ßßßßßßßßßßÛÛÛÛÛÛÜ THE MODULE V3.00á  '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ ß ÛÛÛÛÛÛÛ		ßßÛÛÛÛÛÛÛ  (C) Spring 1997   '
;'          ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ	ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß by Syrius / Alpine '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
;' DATA-INSPECTION-ROUTINES ( NOT PART OF FINAL TM3 )                        '
;'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

HeadLine db "     Start    Length    LStart     LEnd    Pan  Vol   C2SPD    LVol  RVol$"
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC SampleValues ;D:--- N:---  Lists Sample-Structure.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  pushad
  SPrint CRLF
  SPrint HeadLine
  mov edi,0B8000h+3*160+20
  sub edi,[_Code32a]
  xor eax,eax
  mov al,1;[SmpNum]
  mov ebp,eax
  mov ebx,[SampleP]
  @SmpValLoop:
   mov edx,[ebx]        ; Start
   mov cl,8
    Call HexWrite
   add edi,20
   mov edx,[ebx+4]      ; Length
   mov cl,8
    Call Hexwrite
   add edi,20
   mov edx,[ebx+8]      ; LStart
   mov cl,8
    Call Hexwrite
   add edi,20
   mov edx,[ebx+12]     ; C2SPD
   mov cl,8
    Call Hexwrite
   add ebx,16
   add edi,100
   dec bp
  jne @SmpValLoop
  Call Wait4Key
  popad
  ret
 ENDP


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC CSampleValues ;D:---                           Lists CSample-Structure.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
  pushad
  mov ebx,[StartChannel]
  mov [ChNum],bl
  shl ebx,6
  add ebx,[CSampleP]
  mov edi,0B9060h
  sub edi,[_Code32a]
  mov bp,4
  @CSmpValLoop:
   mov dl,[CHNum]
   inc [CHNum]
   mov cx,0102h
    Call HexWrite
   add edi,160*2+12
   mov edx,[EBX+CLength]
   mov cx,8
    Call HexWrite
   add edi,160
   mov edx,[EBX+CLStart]
   mov cl,8
    Call HexWrite
   add edi,160
   mov edx,[EBX+CC2SPD]
   mov cl,8
    Call HexWrite
   add edi,150
   mov edx,[EBX+CVolume]
   mov cl,2
    Call HexWrite
   add edi,8
   mov edx,[EBX+CMonoVol]
   mov cl,2
    Call HexWrite
   add edi,152
   mov edx,[EBX+CVolLeft]
   mov cl,2
    Call HexWrite
   add edi,8
   mov edx,[EBX+CVolRight]
   mov cl,2
    Call HexWrite
   add edi,162
   mov edx,[EBX+CPanning]
   mov cl,2
    Call HexWrite
   add edi,160
   mov edx,[EBX+CCountI]
   mov cl,8
    Call HexWrite
   add edi,160
   mov edx,[EBX+CPeriod]
   mov cl,4
    Call HexWrite
   add edi,160
   mov edx,[EBX+CDstPeriod]
   mov cl,4
    Call HexWrite
   add edi,150
   mov edx,[EBX+CLoopStart]
   mov cl,2
    Call HexWrite
   add edi,8
   mov edx,[EBX+CLoopCount]
   mov cl,2
    Call HexWrite
   add edi,162
   mov edx,[EBX+CLastVSld]
   mov cl,2
    Call HexWrite
   add edi,150
   mov edx,[EBX+CLastPSldU]
   mov cl,2
    Call HexWrite
   add edi,10
   mov edx,[EBX+CLastPSldD]
   mov cl,2
    Call HexWrite
   add edi,160
   mov edx,[EBX+CLastTPorta]
   mov cl,2
    Call HexWrite
   add edi,150
   mov edx,[EBX+CLastVibPos]
   mov cl,2
    Call HexWrite
   add edi,10
   mov edx,[EBX+CLastVib]
   mov cl,2
    Call HexWrite
   add edi,150
   mov edx,[EBX+CTickCmd]
   mov cl,2
    Call HexWrite
   add edi,10
   mov edx,[EBX+CTickCmd2]
   mov cl,2
    Call HexWrite
   add edi,148
   mov edx,[EBX+CWorkByte]
   mov cl,2
    Call HexWrite
   add edi,06
   mov edx,[EBX+CWorkByte2]
   mov cl,2
    Call HexWrite
   add edi,06
   mov edx,[EBX+CWorkByte3]
   mov cl,2
    Call HexWrite
   add ebx,64
   sub edi,17*160-22
   dec bp
  jne @CSmpValLoop

  popad
  ret
 ENDP


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 PROC TrackWindow  ;D:--- N:---
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
 DISPLINES = 10
  pushad
  xor ebx,ebx
  mov bl, [PatternLine]
  sub ebx, DISPLINES
  mov eax,5
  mov ah,[channels]
  mul ah
  mov [CHINC],eax
  imul ebx
  mov esi, [StartPattern]
  add esi,eax
  mov eax,5
  mov ah, [b StartChannel]
  mul ah
  add esi,eax

  mov edi,0B80B4h
  sub edi,[_Code32a]

  xor edx,edx
  mov dl,[CPattern]
  mov bp,dx
  mov dh,1
  mov cl,2
  Call HexWrite

  add edi,6
  mov dl,[Songlen]
  mov dh,1
  mov cl,2
  Call HexWrite

  add edi,28
  mov dl,[Order+bp]
  mov dh,1
  mov cl,2
  Call HexWrite

  add edi,6
  mov dl,[PatNum]
  mov dh,1
  mov cl,2
  Call HexWrite

  add edi,22
  mov dl,[PatternLine]
  Call HexWrite

  add edi,24
  mov dl,[Speed]
  mov cl,2
  Call HexWrite

  add edi,6
  mov dl,[BPM]
  mov cl,2
  Call HexWrite

  add edi,214
  mov bp,DISPLINES*2+1
  @Lines:
   cmp bl, 64
   jb @NoNegativ
    mov eax,07000700h
    mov ecx,77
    rep stosw
    add edi,6
    add esi,[CHINC]
    jmp @NxtLine
   @NoNegativ:
   xor edx,edx
   add edi, 2
   mov cx,2
   mov dl,bl
   Call HexWrite
   mov [B edi+4],'İ'

   REPT 4
    local @NoEffColumn, @EffColR
    xor edx,edx
    mov cx,2
    add edi, 12
    mov dl,[esi+1]
    mov dh,dl
    Call HexWrite
    add edi, 4
    push esi
     mov esi, [esi+2]
     and esi, 0FFh
     shl esi, 1
     add esi, o Notes
     movsb
     inc edi
     movsb
     inc edi
     movsb
     inc edi
    pop esi

    add edi,4
    mov dl,[esi]
    mov eax,[edi-2]
    and eax,0F0FFF0FFh
    mov cx,2
    or dl,dl
    jz @NoEffColumn
     dec dl
     mov ch,1
     add eax,09000900h
     jmp @EffColR
    @NoEffColumn:
     add eax,07000700h
    @EffColR:
    mov [edi-2],eax
    Call HexWrite
    add edi,2

    xor edx,edx
    mov dl,[esi+3]
    or  dl,dl
    setne ch
    shl edx,2
    mov edx,[d Effect+edx]
    mov eax,[edi]
    and eax,0F000F000h
    or  eax,edx
    mov [edi],eax
    shr eax,16
    mov [edi+5],ah
    mov [edi+7],ah
    add edi,6
    mov cl,02h
    mov dl,[esi+4]
    Call HexWrite
    add esi,5
    mov [B edi+6],'İ'
   ENDM

   add esi,[CHINC]
   sub esi,20
   add edi,22
   @NxtLine:
   inc bl
   dec bp
  jne @Lines

  popad
  Ret
 ENDP

