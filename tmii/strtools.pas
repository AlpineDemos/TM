{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴                                         }
{ String-Tools: (C) Sept 96 DeCITE                                         }
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴                                         }
{ Contains: � Fill    : Fills up a string to a constant len with 1 char    }
{           � Strg    : Converts Number to String with constant len        }
{           � Strg0   : Converts Number to String with constant len (0)    }
{ Uses: ---                                                                }

{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� }
 Function Fill(S:String;Len:Byte;C:Char):String;
 Var B:Byte;
 Begin
   For B:=1 to Len-Length(S) do S:=S+C;
   Fill:=S;
 End;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� }
 Function FillL(S:String;Len:Byte;C:Char):String;
 Var B:Byte;
 Begin
   For B:=1 to Len-Length(S) do S:=C+S;
   FillL:=S;
 End;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� }
 Function Strg(V:word;B:byte):String;
 Var S:string;
 Begin
  Str(V,S);
  While Length(S)<B Do S:=' '+S;
  Strg:=S;
 End;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� }
 Function Strg0(V:word;B:byte):String;
 Var S:string;
 Begin
  Str(V,S);
  While Length(S)<B Do S:='O'+S;
  Strg0:=S;
 End;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� }
 Function STG(V:Byte;C:Char):String;
 Var B:Byte;S:String;
 Begin
  S:='';For B:=1 to V do S:=S+C;
  STG:=S;
 End;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� }
 Function UCase(s:String):String;
 Var B:Byte;
 Begin
  For B:=1 to Length(s) do S[b]:=Upcase(S[b]);
  UCase:=S;
 End;
{ 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� }