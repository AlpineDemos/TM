{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{ ASSEMBLER - EDITOR V1.o  BY  SYRIUS / ALPINE                               }
{ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
uses crt;
Procedure WriteXY(X,Y:Byte;Str:String;CF,CB:Byte); Var A,B:Byte;
Begin Dec(X);Dec(Y);
 For B:=0 To Length(Str)-1 do Begin
  Mem[$B800:Y*160+(X+B) shl 1 ]:=Ord(Str[B+1]);
  A:=Mem[$B800:Y*160+(X+B) shl 1+1];
   if CF<>255 then A:=(A and $F0)+CF;
   if CB<>255 then A:=(A and $0F)+(CB shl 4);
   Mem[$B800:Y*160+(X+B) shl 1+1]:=A;
 End;
End;

Function MStr(C:Char;A:Byte):String; Var B:Byte;S:String;
Begin S[0]:=#0;
 For B:=1 to A do S:=S+C;
 MStr:=S;
End;

Procedure Border(X1,Y1,X2,Y2:Byte;Message:String;CF,CB:Byte; Active:Boolean); Var B:Byte;
Begin
 If Active then Begin
   WriteXY(X1,Y1,'É'+MSTR('Í',X2-X1-1)+'»',CF,CB);
   For B:=Y1+1 to Y2-1 do WriteXY(X1,B,'º'+MSTR(' ',X2-X1-1)+'º',CF,CB);
   WriteXY(X1,Y2,'È'+MSTR('Í',X2-X1-1)+'¼',CF,CB);
 End else begin
   WriteXY(X1,Y1,'Ú'+MSTR('Ä',X2-X1-1)+'¿',CF,CB);
   For B:=Y1+1 to Y2-1 do Begin
       WriteXY(X1,B,'³',CF,CB);
       WriteXY(X2,B,'³',CF,CB);
   End;
   WriteXY(X1,Y2,'À'+MSTR('Ä',X2-X1-1)+'Ù',CF,CB);
 End;
 WriteXY(X1+2,Y1,' '+Message+' ',CF,CB);
End;


Begin Textmode(259);
 Border(1,2,80,50,'AEdit.PAS',15,1,True);
 WriteXY(1,01,' File  Options                                AEditor (C) 1996 by Syrius/Alpine ',0,7);


End.



