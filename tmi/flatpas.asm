;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
; FLAT-MODE-MANAGER FOR TURBO PASCAL                              .Syrius.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

.Model TPascal
.Data
  EXTRN FlatStart:DWord
  EXTRN FlatAvail:Word
  EXTRN FlatRequired:Word

.Code
.386P
  XMS_Handle dw 0
  XMS_Add dd 0

  GDT_Off db 16,0,0,0,0,0
  GDT     db  00h, 00h,00h,00h,00h,00h, 00h, 00h
          db 0FFh,0FFh,00h,00h,00h,92h,0CFh,0FFh

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Multitasker aktiv? ÄÄÄ;
Multitasker Proc Near
 mov eax,cr0
 and ax,1
 xor ax,1
 ret
Multitasker EndP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ XMS-Treiber geladen ÄÄ;
XMSAvail Proc near
 mov ax,4300h
 int 2fh
 cmp al,80h
 jne @Kein_XMS
 mov ax,4310h
 int 2fh
 mov word ptr XMS_Add[0],bx
 mov word ptr XMS_Add[2],es
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
XMSAvail EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
EnableA20 Proc Near
 mov ax,0300h
 call dword ptr [XMS_Add]
 Ret
EnableA20 EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
DisableA20 Proc Near
 mov ax,0400h
 call dword ptr [XMS_Add]
 Ret
DisableA20 EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Allocate XMS ÄÄÄÄÄÄÄÄÄ;
GetXMS Proc Near
 mov ax,0800h
 call dword ptr [XMS_Add]
 sub ax,64
 mov FlatAvail,ax
 Cmp ax,FlatRequired
 jb @NoXMS
 mov ax,0900h
 mov dx,FlatRequired
 call dword ptr [XMS_Add]
 cmp ax,1
 jne @NoXMS
 mov XMS_Handle,dx
 mov ax,0C00h
 call dword ptr [XMS_Add]
 shl edx,16
 mov dx,bx
 mov FlatStart,edx
 mov ax,1
 jmp @CheckOk
 @NoXMS:
 mov ax,0
 @CheckOk:
 Ret
GetXMS EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Free XMS ÄÄÄÄÄÄÄÄÄÄÄÄÄ;
FreeXMS Proc Near
 mov ax,0d00h
 mov dx,XMS_Handle
 call dword ptr [XMS_Add]
 mov ax,0a00h
 mov dx,XMS_Handle
 call dword ptr [XMS_Add]
 Ret
FreeXMS Endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Initialise Flat ÄÄÄÄÄÄ;
EnablePM Proc Near
 Mov eax,Seg GDT
 shl eax,4
 xor ebx,ebx
 mov bx, Offset GDT
 add eax,ebx
 mov dword ptr GDT_Off[2],eax
 lgdt pword ptr GDT_off
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
EnablePM EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ In das Flatmodel ÄÄÄÄ;
Public InitFlatMEM
InitFlatMEM Proc Pascal
 call Multitasker
 cmp ax,1
 je @flatinit1
  mov ax,1         ;1=Multitasker
  jmp @initend
 @flatinit1:
 call XMSAvail
 cmp ax,1
 je @flatinit2
  mov ax,2         ;2=NoXMSAvail
  jmp @initend
 @flatinit2:
 call GetXMS
 cmp ax,1
 je  @flatinit3
  mov ax,3         ;3=Not enough XMS available
  jmp @initend
 @flatinit3:
 call EnableA20
 call EnablePM
 xor ax,ax
 @initend:
 Ret
InitFlatMEM Endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Aus dem Flatmodel ÄÄÄ;
Public CloseFlatMEM
CloseFlatMEM Proc Pascal
 call DisableA20
 Call freeXMS
 Ret
CloseFlatMEM Endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;
Public WriteFlat
WriteFlat Proc Pascal FlatP:dword, Memory:dword, laenge:word
push es
 les di,Memory
 xor ax,ax
 mov gs,ax
 mov ebx,FlatP
 mov cx,laenge
@WFLoop:
 mov al,byte ptr gs:[ebx]
 mov es:[di],al
 inc ebx
 inc di
loop @WFLoop
pop es
Ret
WriteFlat EndP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ;

Public ReadFlat
ReadFlat Proc Pascal Memory:dword, FlatP:dword, laenge:word
push es
 les di,Memory
 xor ax,ax
 mov gs,ax
 mov ebx,FlatP
 mov cx,laenge
@RFLoop:
 mov al,es:[di]
 mov byte ptr gs:[ebx],al
 inc ebx
 inc di
loop @RFLoop
pop es
Ret
ReadFlat EndP


end
