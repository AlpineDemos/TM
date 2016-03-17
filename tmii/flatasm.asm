;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
; Flat-Mode-Manager for Assembler [INCLUDE]                       .Syrius.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;

IDEAL
P386
GROUP Data IData,UData
ASSUME CS:Code, DS:Data

B EQU Byte  Ptr
W EQU Word  Ptr
D EQU DWord Ptr

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
SEGMENT Code Public
  XMS_Handle dw 0
  XMS_Add    dd 0

  GDT_Off db 16,0,0,0,0,0
  GDT     db  00h, 00h,00h,00h,00h,00h, 00h, 00h
          db 0FFh,0FFh,00h,00h,00h,92h,0CFh,0FFh

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
PROC Multitasker Near
 mov eax,cr0
 and ax,1
 xor ax,1
 ret
ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
PROC XMSAvail near
 mov ax,4300h
 int 2fh
 cmp al,80h
 jne @Kein_XMS
 mov ax,4310h
 int 2fh
 mov [W XMS_Add+0],bx
 mov [W XMS_Add+2],es
 xor ax,ax
 call [XMS_Add]
 cmp ax,0200h
 jb @Kein_XMS
 mov ax,1
 jmp @Ende_XMS
 @Kein_XMS:
  mov ax,0
 @Ende_XMS:
 Ret
ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
PROC EnableA20 Near
 mov ax,0300h
 call [XMS_Add]
 Ret
ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
PROC DisableA20 Near
 mov ax,0400h
 call [XMS_Add]
 Ret
ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
PROC GetXMS Near
 mov ax,0800h
 call [XMS_Add]
 sub ax,64
 mov [FlatAvail],ax
 Cmp ax,[FlatRequired]
 jb @NoXMS
 mov ax,0900h
 mov dx,[FlatRequired]
 call [XMS_Add]
 cmp ax,1
 jne @NoXMS
 mov [XMS_Handle],dx
 mov ax,0C00h
 call [XMS_Add]
 shl edx,16
 mov dx,bx
 mov [FlatStart],edx
 mov ax,1
 jmp @CheckOk
 @NoXMS:
 mov ax,0
 @CheckOk:
 Ret
ENDP


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
PROC FreeXMS Near
 mov ax,0d00h
 mov dx,[XMS_Handle]
 call [XMS_Add]
 mov ax,0a00h
 mov dx,[XMS_Handle]
 call [XMS_Add]
 Ret
ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
PROC EnablePM Near
 Mov eax,Seg GDT
 shl eax,4
 xor ebx,ebx
 mov bx, Offset GDT
 add eax,ebx
 mov [D GDT_Off+2],eax
 lgdt [pword ptr GDT_off]
 mov bx,08
 push ds
 cli
 mov eax,cr0
 or eax,1
 mov cr0,eax
 jmp In_PM
 In_PM:
 mov gs,bx
 mov fs,bx
 mov es,bx
 mov ds,bx
 and al,0FEh
 mov cr0,eax
 jmp in_RM
 In_RM:
 sti
 pop ds
 Ret
ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
Public InitFlatMEM
PROC InitFlatMEM Far
 mov ah,09h
 lea dx,[FlatHello]
 int 21h

 call Multitasker
 cmp ax,1
 je @flatinit1
  mov ah,09h
  lea dx,[FlatEMS]
  int 21h
  mov ax,1         ;Multitasker
  jmp @initend
 @flatinit1:
 call XMSAvail
 cmp ax,1
 je @flatinit2
  mov ah,09h
  lea dx,[FlatNoXMS]
  int 21h
  mov ax,1         ;NoXMSAvail
  jmp @initend
 @flatinit2:
 call GetXMS
 cmp ax,1
 je  @flatinit3
  mov ah,09h
  lea dx,[FlatNoMEM]
  int 21h
  mov ax,1         ;Not enough XMS available
  jmp @initend
 @flatinit3:
 call EnableA20
 call EnablePM
 mov ah,09h
 lea dx,[FlatOK]
 int 21h
 xor ax,ax
 @initend:
 Ret
ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
Public CloseFlatMEM
PROC CloseFlatMEM Pascal
 call DisableA20
 Call freeXMS
 mov ah,09h
 lea dx,[FlatOKCls]
 int 21h
 Ret
ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
Public WriteFlat
PROC WriteFlat Pascal FlatP:dword, Memory:dword, laenge:word
push es
pusha
 les di,[Memory]
 xor ax,ax
 mov gs,ax
 mov ebx,[FlatP]
 mov cx,[laenge]
@WFLoop:
 mov al,[B gs:ebx]
 mov [es:di],al
 inc ebx
 inc di
loop @WFLoop
popa
pop es
Ret
ENDP

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
Public ReadFlat
PROC ReadFlat Pascal Memory:dword, FlatP:dword, laenge:word
push es
pusha
 les di,[Memory]
 xor ax,ax
 mov gs,ax
 mov ebx,[FlatP]
 mov cx,[laenge]
@RFLoop:
 mov al,[es:di]
 mov [B gs:ebx],al
 inc ebx
 inc di
loop @RFLoop
popa
pop es
Ret
ENDP

ENDS

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴;
SEGMENT IData Public
  FlatHello db " 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[ ASM-FlatMode-Manager by Syrius ]�",13,10,"$"
  FlatEMS   db " [ERROR] Multitasker active! Please reboot without EMM386 !",13,10,"$"
  FlatNOXMS db " [ERROR] No XMS-Manager Found! Please reboot with HIMEM.SYS!",13,10,"$"
  FlatNOMEM db " [ERROR] Not enough XMS available ! ",13,10,"$"
  FlatOK    db " OK, RMEM initialized successfully...",13,10,"$"
  FlatOKCls db " OK, RMEM Closed successfully...",13,10,"$"
ENDS
SEGMENT UData Public
  FlatStart    dd ?
  FlatAvail    dw ?
  FlatRequired dw ?
ENDS
