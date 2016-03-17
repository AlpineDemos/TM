;����������������������������������������������������������������������������;
; F�I���D�S�B  V1.o                                               [ Syrius ]
;����������������������������������������������������������������������������;


IDEAL
P386
ASSUME CS:Code, DS:Data

D EQU DWORD PTR
W EQU WORD  PTR
B EQU BYTE  PTR

SEGMENT Code Public

;����������������������������������������������������������������������������;
MACRO WDsp Wert
 Local @WD1
 mov dx,[ADR]
 add dx,0Ch
 @WD1:
  in al,dx
  Cmp al,128
 jae @WD1
 mov al,Wert
 out dx,al
EndM
;����������������������������������������������������������������������������;
MACRO WMixer Reg, Wert
 mov dx,[ADR]
 add dx,04h
 mov al,Reg
 out dx,al
 inc dx
 mov al,Wert
 out dx,al
ENDM

;����������������������������������������������������������������������������;
MACRO RMixer Reg, Ziel
 mov dx,[ADR]
 add dx,04h
 mov al,Reg
 out dx,al
 inc dx
 in al,dx
 Ifnb <Ziel>
  mov Ziel, al
 Endif
ENDM
;����������������������������������������������������������������������������;
MACRO SBDetectMixer
 WMixer 00h, 0
 RMixer 22h, bl
 WMixer 22h, 243
 RMixer 22h
 xor bh,bh
 cmp al,243
 sete [SBPro]
 WMixer 22h, bl
ENDM

;����������������������������������������������������������������������������;
PROC InitSB Near
 push cx
 add dx,06h
 mov al,1
 out dx,al
 mov cx,100
 @l1:
 loop @l1
 xor al,al
 out dx,al
 mov cx,200
 @l2:
 loop @l2
 add dx,08h
 in  al,dx
 sub dx,0Eh
 pop cx
 ret
ENDP

;����������������������������������������������������������������������������;
PROC TestBlock ;The REAL and ONLY one !
  mov al,4
  add al,[DMA]
  out 0Ah, al
  mov al,48h
  add al,[DMA]
  out 0Bh, al
  xor al,al
  out 0Ch, al
  xor bh,bh
  xor dh,dh
  mov bl,[DMA]
  mov dl,[DMA_ADR+bx]
  xor eax,eax
  out dx,al
  out dx,al
  mov dl,[DMA_PAGE+bx]
  out dx,al
  xor al,al
  out 0Ch, al
  mov dl,[DMA_LEN+bx]
  mov al,00Fh
  out dx,al
  xor al,al
  out dx,al
  WDsp 40h
  WDsp 211
  WDsp 14h
  WDsp 00Fh
  WDsp 00h
  WDsp 0D3h
  mov al,[DMA]
  out 0Ah,al
  Ret
ENDP

;����������������������������������������������������������������������������;
PROC SB_Int
 pushf
 Pushad
 Push ds
  mov dx,data
  mov ds,dx
  mov dx,[ADR]
  add dx,0Eh
  in  al,dx
  mov al,0Bh    ;First PIC for IRQs 2,3,5,7
  out 20h,al
  in  al,20h
  xor dl,dl
  @I1:
   inc dl
   shr al,1
  jne @I1
  dec dl
  mov [IRQ],dl
  mov al,0Bh    ;Second PIC for IRQ 10!
  out 0A0h,al
  in al,0A0h
  test al,al
  je @No_PIC_2
   mov [IRQ],10
   mov al,20h
   out 0A0h,al
  @No_PIC_2:
  mov al,20h
  Out 20h,al
 Pop ds
 Popad
 popf
 Iret
ENDP

;����������������������������������������������������������������������������;
PROC DetectBase
 mov dx,200h
 mov cx,7
 @DB1:
  add dx,10h
  Call InitSB
  add dx,0Ah
  in al,dx
  sub dx,0Ah
  cmp al,0AAh
  je @DB2
 loop @DB1
 mov [ADR],0
 Ret
 @DB2:
 mov [ADR],dx
 SBDetectMixer
 Ret
ENDP

;����������������������������������������������������������������������������;
MACRO Bin2Hex Source, Dest, Len
Local @Lp1, @nohex
 xor dh,dh
 mov dl,[B Source]
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
  shr dx,4
  dec bx
 jne @lp1
ENDM

;����������������������������������������������������������������������������;
Public SBDetect
PROC SBDetect Far
 mov ax,DATA

 mov ah,09h
 lea dx,[SBHello]
 int 21h

 mov [DMA],255
 mov [IRQ],0
 Call DetectBASE
 cmp [ADR],0
 je  @Failed

 xor ax,ax
 mov es,ax
 mov eax,[D es:0Ah*4]
 mov [IRQ2],eax
 mov eax,[D es:0Bh*4]
 mov [IRQ3],eax
 mov eax,[D es:0Dh*4]
 mov [IRQ5],eax
 mov eax,[D es:0Fh*4]
 mov [IRQ7],eax
 mov eax,[D es:72h*4]
 mov [IRQA],eax

 mov ax,cs
 shl eax,16
 lea ax,[SB_Int]

 cli
  mov [D es:0Ah*4],eax
  mov [D es:0Bh*4],eax
  mov [D es:0Dh*4],eax
  mov [D es:0Fh*4],eax
  mov [D es:72h*4],eax
 sti

 in  al,21h
 mov [PORT21],al
 and al,01010011b
 out 21h,al

 in  al,0A1h
 mov [PORTA1],al
 and al,11111011b
 out 0A1h,al

 ;����������������DMA 1
  mov dx,[ADR]
  Call InitSB
  mov [DMA],1
  xor eax,eax
  mov bx,0Fh
  mov cx,bx
  Call TransferBlock
  WDsp 0D3h             ;Speakers off
  mov ecx,9FFFFh
  @d1:
  loopd @d1
  cmp [IRQ],0
  jne @DMAEnd
 ;����������������DMA 0
  mov dx,[ADR]
  Call InitSB
  mov [DMA],0
  xor eax,eax
  mov bx,0Fh
  mov cx,bx
  Call TransferBlock
  WDsp 0D3h             ;Speakers off
  mov ecx,9FFFFh
  @d2:
  loopd @d2
  cmp [IRQ],0
  jne @DMAEnd
 ;����������������DMA 3
  mov dx,[ADR]
  Call InitSB
  mov [DMA],3
  xor eax,eax
  mov bx,0Fh
  mov cx,bx
  Call TransferBlock
  WDsp 0D3h             ;Speakers off
  mov ecx,9FFFFh
  @d3:
  loopd @d3
  cmp [IRQ],0
  jne @DMAEnd

 mov [DMA],255
 @DMAEnd:
 mov al,[PORT21]
 out 21h,al
 mov al,[PORTA1]
 out 0A1h,al

 cli
  mov eax,[IRQ2]
  mov [D es:0Ah*4],eax
  mov eax,[IRQ3]
  mov [D es:0Bh*4],eax
  mov eax,[IRQ5]
  mov [D es:0Dh*4],eax
  mov eax,[IRQ7]
  mov [D es:0Fh*4],eax
  mov eax,[IRQA]
  mov [D es:72h*4],eax
 sti
 @EndSB:
 cmp [DMA],255
 je @Failed
  Bin2Hex ADR,SBADR,2
  Bin2Hex IRQ,SBIRQ,2
  Bin2Hex DMA,SBDMA,2
  cmp [SBPro],1
  je @SBProFound
   mov [SBDMA+6],"$"
  @SBProFound:
  mov ah,09h
  lea dx,[SBOk]
  int 21h
  mov al,1
  Ret
 @Failed:
  mov ah,09h
  lea dx,[SBError]
  int 21h
  xor al,al
  Ret
ENDP

;����������������������������������������������������������������������������;
ENDS

;����������������������������������������������������������������������������;
;����������������������������������������������������������������������������;
SEGMENT Data Public
 ADR dw ?
 IRQ db ?
 DMA db ?
 SBPro db ?

 IRQ2 dd ?
 IRQ3 dd ?
 IRQ5 dd ?
 IRQ7 dd ?
 IRQA dd ?

 PORT21 db ?
 PORTA1 db ?

 ;Messages
 SBHello db " ���������������������������������������[ FindSB V0.5 SB-Detection by Syrius ]�",13,10,"$"
 SBError db " Sorry, No SoundBlaster-Card Found ! ",13,10,"$"
 SBOk    db " SoundBlaster-Card Found at: ",13,10
         db " ADR: 2"
 SBADR   db "??h ",13,10
         db " IRQ: "
 SBIRQ   db "0?h ",13,10
         db " DMA: "
 SBDMA   db "0?h ",13,10,0
         db "SoundBlaster Pro Detected.",13,10,"$"


ENDS

;����������������������������������������������������������������������������;
;����������������������������������������������������������������������������;


