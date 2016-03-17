const name='Module5';
var f:file;t:text;d:longint;

Function D2H(dez:longint):String;Var G1,M:LongInt;Hx:String;
Const W:Array[0..15] of char = '0123456789ABCDEF';
Begin
  hx:='';
  For G1:= 1 to 8 Do Begin
     Hx:=w[dez and 15]+Hx;
     dez:=dez shr 4;
  End;
  D2H:='0'+Hx;
End;

begin
 Assign(f,name+'.grf');Reset(f,1);
 Assign(t,name+'.raw');Rewrite(t);
 While not eof(f) do begin
  if not eof(f) then begin blockread(f,d,4); Write  (t,' DD ',D2h(d),'h');end;
  if not eof(f) then begin blockread(f,d,4); Write  (t,',',D2h(d),'h'); end;
  if not eof(f) then begin blockread(f,d,4); Write  (t,',',D2h(d),'h'); end;
  if not eof(f) then begin blockread(f,d,4); Write  (t,',',D2h(d),'h'); end;
  if not eof(f) then begin blockread(f,d,4); Write  (t,',',D2h(d),'h'); end;
  if not eof(f) then begin blockread(f,d,4); Write  (t,',',D2h(d),'h'); end;
  if not eof(f) then begin blockread(f,d,4); Write  (t,',',D2h(d),'h'); end;
  if not eof(f) then begin blockread(f,d,4); Writeln(t,',',D2h(d),'h'); end;
 End;
 Close(f);Close(t);

end.