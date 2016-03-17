{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                                         }
{ String-Tools: (C) Sept 96 DeCITE                                         }
{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                                         }
{ Contains: û Fill    : Fills up a string to a constant len with 1 char    }
{           û Strg    : Converts Number to String with constant len        }
{           û Strg0   : Converts Number to String with constant len (0)    }
{ Uses: ---                                                                }

{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
 Function Fill(S:String;Len:Byte;C:Char):String;
 Var B:Byte;
 Begin
   For B:=1 to Len-Length(S) do S:=S+C;
   Fill:=S;
 End;
{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
 Function FillL(S:String;Len:Byte;C:Char):String;
 Var B:Byte;
 Begin
   For B:=1 to Len-Length(S) do S:=C+S;
   FillL:=S;
 End;
{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
 Function Strg(V:word;B:byte):String;
 Var S:string;
 Begin
  Str(V,S);
  While Length(S)<B Do S:=' '+S;
  Strg:=S;
 End;
{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
 Function Strg0(V:word;B:byte):String;
 Var S:string;
 Begin
  Str(V,S);
  While Length(S)<B Do S:='O'+S;
  Strg0:=S;
 End;
{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
 Function STG(V:Byte;C:Char):String;
 Var B:Byte;S:String;
 Begin
  S:='';For B:=1 to V do S:=S+C;
  STG:=S;
 End;
{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
 Function UCase(s:String):String;
 Var B:Byte;
 Begin
  For B:=1 to Length(s) do S[b]:=Upcase(S[b]);
  UCase:=S;
 End;
{ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }