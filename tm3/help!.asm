;����������������������������������������������������������������������������;
 MACRO Wait4Key   ; Destroys: AL        Needs: ---
;����������������������������������������������������������������������������;
  mov [v86r_ax], 00
  mov al,16h
  int 33h
  mov al,[v86r_al]
 ENDM

;����������������������������������������������������������������������������;
 MACRO GetKey     ; Destroys: AL        Needs: ---
;����������������������������������������������������������������������������;
  mov [v86r_ax], 0100h
  mov al,16h
  int 33h
  mov al,[v86r_al]
 ENDM

;����������������������������������������������������������������������������;
 MACRO SPrint ADDR    ; Destroys eax, ebx   Needs: Eax = Offset of Message
;����������������������������������������������������������������������������;
  pushad
  mov eax, o ADDR
  add eax, [_Code32a]
  shld ebx,eax,28
  and eax, 0Fh
  mov [v86r_ds], bx
  mov [v86r_dx], ax
  mov [v86r_ah], 09
  mov al, 21h

  int 33h
  popad
 ENDM

  Leer db ' $'
  CRLF db 13,10,'$'
  Digits db 'o123456789ABCDEF'
  Buf    db '        $'
;����������������������������������������������������������������������������;
 MACRO HexPrint Num; Destroys: ---   Needs: DX = Number; Num = Digits
;����������������������������������������������������������������������������;
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
  SPrint Leer
  popad
 ENDM
