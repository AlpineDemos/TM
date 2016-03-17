{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                                           }
{ Text-Tools: (C) Sept 96 DeCITE                                           }
{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                                           }
{ Contains: û WriteXY : Writes String at Position <X,Y>                    }
{           û GotoXY  : Sets Cursor at Position <X,Y>                      }
{           û Border  : Paints Border                                      }

Var   Page :Word;
Const SMode:Word=8000;
      Q=16;
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Procedure Border(X1,Y1,X2,Y2,CT1,CT2,CB:Byte;Druck:Boolean);
Var W,W2:Word;C1,C2:byte;
Begin Dec(Y1);Dec(Y2);Dec(X1);Dec(X2);
 If Druck Then Begin C1:=CT2;C2:=CT1; End
          Else Begin C1:=CT1;C2:=CT2; End;
 For W:=Y1*80+X1 To Y1*80+X2 Do Begin
     Mem[$B800:Page*SMode+w*2]:=196;Mem[$B800:Page*SMode+w*2+1]:=cb shl 4+c1;
 End;
 For W:=Y2*80+X1 To Y2*80+X2 Do Begin
     Mem[$B800:Page*SMode+w*2]:=196;mem[$B800:Page*SMode+w*2+1]:=cb shl 4+c2;
 End;
 Mem[$B800:Page*SMode+y1*160+x1*2]:=218;Mem[$B800:Page*SMode+y1*160+x1*2+1]:=CB Shl 4+c1;
 Mem[$B800:Page*SMode+y1*160+x2*2]:=191;Mem[$B800:Page*SMode+y1*160+x2*2+1]:=CB Shl 4+c2;
 Mem[$B800:Page*SMode+y2*160+x1*2]:=192;Mem[$B800:Page*SMode+y2*160+x1*2+1]:=CB Shl 4+c1;
 Mem[$B800:Page*SMode+y2*160+x2*2]:=217;Mem[$B800:Page*SMode+y2*160+x2*2+1]:=CB Shl 4+c2;
 For W:=Y1+1 To Y2-1 Do Begin
  For W2:=X1 To X2 Do Begin
    Mem[$B800:Page*SMode+w*160+w2*2]:=32;
    If Druck Then Mem[$B800:Page*SMode+W*160+w2*2+1]:=C2
             Else Mem[$B800:Page*SMode+W*160+w2*2+1]:=CB Shl 4+c2;
  End;
  Mem[$B800:Page*SMode+w*160+x1*2]:=179;Mem[$B800:Page*SMode+w*160+x1*2+1]:=CB Shl 4+C1;
  Mem[$B800:Page*SMode+w*160+x2*2]:=179;Mem[$B800:Page*SMode+w*160+x2*2+1]:=CB Shl 4+C2;
 End;
End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

Procedure GotoXY(X,Y,CMode:Byte);
Begin Dec(X);Dec(Y);
 Port[$3d4]:=$0E;Port[$3d5]:=Hi((Page*(SMode div 2))+y*80+x);
 Port[$3d4]:=$0F;Port[$3d5]:=Lo((Page*(SMode div 2))+y*80+x);
 If CMode=0 Then Begin Port[$3d4]:=$0A;Port[$3d5]:=Port[$3d5] or 32;  End;
 if CMode=1 Then Begin Port[$3d4]:=$0A;Port[$3d5]:=Port[$3d5] and 223;End;
 if CMode=2 Then Begin Port[$3d4]:=$0A;Port[$3d5]:=0;Port[$3d4]:=$0B;Port[$3d5]:=8;End;
 if CMode=3 Then Begin Port[$3d4]:=$0A;Port[$3d5]:=7;Port[$3d4]:=$0B;Port[$3d5]:=8;End;
End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

Procedure WriteXY(X,Y:Byte;S:String;FC,BC:Byte);Var G:Word;col:Byte;
Begin dec(X);dec(Y);
 For G:=1 to Length(S) do begin
  Mem[$B800:Page*SMode+(Y*160)+2*X+(G-1)*2]:=ord(S[G]);
  col:=Mem[$B800:Page*Smode+(Y*160)+2*X+(G-1)*2+1];
  if FC<16 then col:=(col and $F0)+ FC;
  if BC<16 then col:=(col and $0F)+ (BC shl 4);
  Mem[$B800:Page*SMode+(Y*160)+2*X+(G-1)*2+1]:=col;
 End;
End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

Procedure SwPage(APage:word);
Begin
 Port[$3d4]:=$0D;Port[$3d5]:=Lo(APage*(SMode div 2));
 Port[$3d4]:=$0C;Port[$3d5]:=Hi(APage*(SMode div 2));
 Page:=APage;
End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

Procedure LoadGrf(FileName:String;APage:word);Var F:File;Error:Byte;
Begin
{$I-}Assign(F,FileName);Reset(F,1);{$I+}
 If ioresult=0 Then Begin
    BlockRead(F,mem[$B800:APage*Smode],SMode);
 End;
  Close(F);
End;

{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}

