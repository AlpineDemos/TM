uses crt;

Type BlockType= Array[0..65530] of Byte;
     PattrnType = Array[0..63,0..31,1..5] of Byte;
Const Dir:array[0..1] of String[5]=('Left ','Right');
Var F:File;
    MasterSpace:Word;
    GlobalVol:Byte;
    InitSpeed:Byte;
    InitBPM  :Byte;
    Channels :Byte;
    Songlen  :Byte;
    PatNum   :Byte;
    SmpNum   :Byte;

    CLine    :Byte;
    CChn     :Byte;
    Point    :Word;
    Work     :Byte;

    PPannVal  :Array[1..32] of Byte;
    SampleVols:Array[1..100] of Byte;
    SmpLength :Array[1..100] of Longint;
    Order     :Array[0..128] of Byte;

    I,W,Indx :Word;
    D:LongInt;
    B,Line,Ch,Note1,Note2:Byte;
    Buff     :Array[0..2560] of Byte;
    c:char;
    PackedPat:^BlockType;
    Pattern  :^PattrnType;
    PatLen:Word;

Const Digits:Array[0..15] of Char = 'o123456789ABCDEF';


Function D2H(d:LongInt;Num:Byte):String;Var Hx:String;M,G1:Byte;
  { Wandelt Dezimalzahl in Hex-String um }
Begin If D=0 then Begin Hx:='תתתתתתתת';Hx[0]:=Chr(Num); End Else Begin
  hx:='';
  For G1:= 1 to Num Do Begin
     m:=d and 15;Hx:=Digits[M]+Hx;d:=d shr 4;
  End;
  End;
  D2H:=Hx;
End;



Begin New(PackedPat); New(Pattern);
 TextMode(259);
 Assign(F,'NOTH2.TM3'); ReSet(F,1);

 BlockRead(F,MasterSpace,2); Writeln('MasterSpace: ',MasterSpace);
 BlockRead(F,GlobalVol,1);   Writeln('GlobalVol  : ',GlobalVol);
 BlockRead(F,InitSpeed,1);   Writeln('InitSpeed  : ',InitSpeed);
 BlockRead(F,InitBPM  ,1);   Writeln('InitBPM    : ',InitBPM  );
 BlockRead(F,Channels ,1);   Writeln('Channels   : ',Channels );
 BlockRead(F,SongLen,1);     Writeln('SongLen    : ',SongLen);
 BlockRead(F,Order,SongLen);
 BlockRead(F,PatNum,1);    Writeln('Patterns  : ',PatNum);
 BlockRead(F,SmpNum,1);    Writeln('Samples   : ',SmpNum);
 Readln;
 ClrScr; Writeln;

 BlockRead(F,PPannVal,Channels);
 Writeln ('Chn  Direction  Panning  ');Writeln;
 For I:=1 to Channels do begin
  Writeln(I:2,'   ',D2H(Longint(PPannVal[I]),2));
 End;
 Readln;
 ClrScr; Writeln;

 Writeln('Smp  Length     LStart    C2SPD     Vol ');Writeln;
 For I:=1 to SmpNum do begin
   BlockRead(F,SmpLength[I],4); Write(I:2,'  ',D2H(SmpLength[I],8),'   ');
   BlockRead(F,D,4); Write(D2H(D,8),'  ');
   BlockRead(F,D,4); Writeln(D2H(D,8),'   ');
   If (I mod 32)=0 then c:=Readkey;
 End;
 Writeln('FilePos ',FilePos(F));
 Readln;

 BlockRead(f,SampleVols,SmpNum);
 For I:=1 to SmpNum do begin
   Writeln(I:2,'  ',D2H(SampleVols[i],2),'   ');
   If (I mod 32)=0 then c:=Readkey;
 End;
 Readln;

 ClrScr; Writeln;
 For I:=0 to PatNum-1 do Begin
 BlockRead(F,PatLen,2);
 BlockRead(F,PackedPat^,PatLen);
 Writeln(FilePos(F):8);
 FillChar (Pattern^,10240,0);
 CLine:=0;Point:=0;
 Repeat
  Work:=PackedPat^[Point];inc(Point);
  if Work=0 then begin
   inc(CLine);
  End Else begin
   CChn := Work and 31;
   if (Work and 32)>0 then begin
     Pattern^[CLine,CChn,1]:=PackedPat^[Point];inc(Point);
     Pattern^[CLine,CChn,2]:=PackedPat^[Point];inc(Point);
   end;
   if (Work and 64)>0 then begin
     Pattern^[CLine,CChn,3]:=PackedPat^[Point];inc(Point);
   end;
   if (Work and 128)>0 then begin
     Pattern^[CLine,CChn,4]:=PackedPat^[Point];inc(Point);
     Pattern^[CLine,CChn,5]:=PackedPat^[Point];inc(Point);
   end;
  End;
 Until CLine=64;
  For Line:=0 to 63 do begin
    For Ch:=4 to 7 do begin
      Write('Ý', D2H(Pattern^[Line,Ch,1],2)+' ');
      Write(D2H(Pattern^[Line,Ch,2],2)+' ');
      Write(D2H(Pattern^[Line,Ch,3],2)+' ');
      Write(D2H(Pattern^[Line,Ch,4],2)+' ');
      Write(D2H(Pattern^[Line,Ch,5],2)+' ');
    End;
    Writeln('Ý ',Line,' ',I);
     if Line=40 then begin C:=Readkey; if C=#27 then halt; end;
  End;
  C:=Readkey; if C=#27 then halt;clrscr; Writeln;
 End;

 BlockRead(f,PackedPat^,SmpLength[1]);
 For I:=0 to SmpLength[1] do PackedPat^[I]:=PackedPat^[I]-128;
 Close(f);
 Assign(f,'deepb.smp');Rewrite(f,1);BlockWrite(f,PackedPat^,SmpLength[1]);
 close(f);



End.