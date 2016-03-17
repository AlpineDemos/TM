Program ModPlayer;
Uses ModP,crt;
{ ModPlayer 1.o by Syrius }
var last:word;ldspints:byte;dflop:boolean;
    instvol0,instvol1,instvol2,instvol3:byte;
    ww:word;
    f:file;
    inst:byte;
    IS:Byte;
    s:string;b:byte;
    FlatStart:LongInt;
    FlatAvail:Word;
    FlatRequired:Word;
    Inited:Byte;
    ModLoaded:Longint;
    APat:^PatternType;
    lastpatnum:byte;
Const ST=18;
      Module='C:\Ft2\grell.mod';
{$F+}
Function  InitFlatMem:Byte;External;
Procedure CloseFlatMem;External;
Procedure ReadFlat(Memory:Pointer;FlatP:Longint;Laenge:Word);External;
Procedure WriteFlat(FlatP:Longint;Memory:Pointer;Laenge:Word);External;
{$L FlatPAS }
{$F-}

{$I STRTools}
{$I TXTools}

Function D2H(dez:longint;num:byte):String;
Var G1,M:LongInt;Hx:String;n2:byte;
const chars:array[0..15] of char='O123456789ABCDEF';
Begin  hx:='';G1:=0;
For G1:=1 to num do begin
 Hx:=Chars[dez and 15]+Hx;
 dez:=dez shr 4;
End;
D2H:=Hx;
End;

Procedure WritePattern;Var patline:integer;ypos,ins,WCol:byte;b,b2:word;
                           ch:char;
const cols:array[0..15] of byte=
        ($7,$A,$A,$A,$A,$A,$A,$B,$A,$C,$B,4,$B,$C,$C,$C);
      cols14:array[1..15] of byte=
        ($A,$A,$7,$7,$A,$C,$7,$7,$C,$B,$B,$A,$A,$C,$7);
      chars  :Array[0..15] of char='Û'#13'~'#13'~~ð! -"$';
      chars14:Array[1..15] of char='+-  f ?+-^dd ';

Begin YPos:=16;
For PatLine:=PatternLine-10 to PatternLine+10 do begin
 If (PatLine<0) or (PatLine>63) then
  WriteXY(ST+2,YPos,'              ³              ³              ³              ',7,q)
 Else begin
 For Ins:=0 to 3 do Begin WCol:=15;
    B:=APat^[PatLine,IS+Ins,1] and $F0+APat^[PatLine,IS+Ins,3] shr 4;
    if B>0 then WriteXY(St+3+Ins*15,YPos,strg(B,2)+' ',WCol,q)
           else WriteXY(St+3+Ins*15,YPos,'úú ',8,q);
    B:=(APat^[PatLine,IS+Ins,1] and $F)shl 8+APat^[PatLine,IS+Ins,2];

    if B>0 then WriteXY(St+6+Ins*15,YPos,strg(B,4)+' ',WCol,q)
           else WriteXY(St+6+Ins*15,YPos,'úúúú ',8,q);
    B:=APat^[PatLine,IS+Ins,3] and $F;
    B2:=APat^[PatLine,IS+Ins,4];
    if B=14 then begin B:=B2 shr 4;B2:=B2 and $F;
     if WCol=15 then WCol:=Cols14[B];
     Ch:=Chars14[b];
     if b in [$A,$B] then s:=' '+ch else s:=ch+' ';
     if (B>0) then WriteXY(St+11+Ins*15,YPos,s,WCol,q)
              else WriteXY(St+11+Ins*15,YPos,'úú',8,q);

     if (B>0) then WriteXY(St+13+Ins*15,YPos,D2H(B2,2),WCol,q)
              else WriteXY(St+13+Ins*15,YPos,'úú',8,q);

    end else begin
     if WCol=15 then WCol:=Cols[B];
     Ch:=Chars[b];
     if (B=$0A) and (B2>15) then Ch:='';
     if b in [7,$A,$C] then s:=' '+ch else s:=ch+' ';
     if (B>0) then WriteXY(St+11+Ins*15,YPos,s,WCol,q)
              else WriteXY(St+11+Ins*15,YPos,'úú',8,q);
     if (b=5) then begin
         if wcol<>8 then WCol:=$B;
         if b2>15 then Ch:='' else Ch:='';
         WriteXY(St+12+Ins*15,YPos,ch,WCol,q)
     end;

     if (b=6) then begin
         if wcol<>8 then WCol:=$B;
         if b2>15 then Ch:='' else Ch:='';
         WriteXY(St+12+Ins*15,YPos,ch,WCol,q)
     end;

     if (B>0) then WriteXY(St+13+Ins*15,YPos,D2H(B2,2),WCol,q)
              else WriteXY(St+13+Ins*15,YPos,'úú',8,q);
    end;

 End;
 End;
 Inc(YPos);
End;
End;

Procedure WMix(Reg,Val:Byte);
Begin Port[$224]:=Reg;Port[$225]:=Val; End;

Function RMix(Reg:Byte):Byte;
Begin Port[$224]:=Reg;RMix:=Port[$225]; End;

Procedure WriteMixerDatas;
 Var DSPVol_L,DSPVol_R,
     MICVol_L,MICVol_R,
     MASVol_L,MASVol_R,
      FMVol_L, FMVol_R,
      CDVol_L, CDVol_R,
     LNEVol_L,LNEVol_R,iFilter,oFilter,OutPut,Input:Byte;

 Procedure ReadMixerDatas;Var B:Byte;
 Begin
   B:=RMix($02);DSPVol_L:=B shr 5;DSPVol_R:=(B shr 1) and 7;
   B:=RMix($0A);MICVol_L:=B shr 5;MICVol_R:=(B shr 1) and 7;
   B:=RMix($22);MASVol_L:=B shr 5;MASVol_R:=(B shr 1) and 7;
   B:=RMix($26); FMVol_L:=B shr 5; FMVol_R:=(B shr 1) and 7;
   B:=RMix($28); CDVol_L:=B shr 5; CDVol_R:=(B shr 1) and 7;
   B:=RMix($2E);LNEVol_L:=B shr 5;LNEVol_R:=(B shr 1) and 7;
   B:=RMix($0C);
   If (B and 32) <> 0 then iFilter:=0 else iFilter:=1+((B shr 3) and 1);
   Input:=(B shr 1) and 3;
   B:=RMix($0E);


   if (b and 32) <> 0 then oFilter:=0 else oFilter:=iFilter;
   OutPut:=(B shr 1) and 1;
 End;

Begin

 Border(11,03,71,07,15,00,08,False);WriteXY(24,05,'MiXeR - CHiP DeTeCTeD. SB Version 0.00',15,q);
 Border(11,10,47,45,15,00,08,False);WriteXY(24,11,'VùOùLùUùMùE',15,q);

 Border(13,13,45,17,15,00,08,True); WriteXY(24,15,'Master-Vol:',3,q);
 Border(13,19,45,23,15,00,08,True); WriteXY(24,21,'DSP-Volume:',3,q);
 Border(13,24,45,28,15,00,08,True); WriteXY(24,26,' FM-Volume:',3,q);
 Border(13,29,45,33,15,00,08,True); WriteXY(24,31,'MiC-Volume:',3,q);
 Border(13,34,45,38,15,00,08,True); WriteXY(24,36,' CD-Volume:',3,q);
 Border(13,39,45,43,15,00,08,True); WriteXY(24,41,'LNE-Volume:',3,q);

 Border(49,10,71,20,15,00,08,False);Border(51,13,69,18,15,00,08,True);
 Border(49,22,71,32,15,00,08,False);Border(51,25,69,30,15,00,08,True);
 Border(49,34,71,45,15,00,08,False);

 WriteXY(56,11,'IùNùPùUùT'  ,15,q);
 WriteXY(53,15,'Filter:',3,q);WriteXY(53,16,'Input :',3,q);
 WriteXY(55,23,'OùUùTùPùUùT',15,q);
 WriteXY(53,27,'Filter:',3,q);WriteXY(53,28,'Output:',3,q);
 ReadMixerDatas;
 { Master } WriteXY(16,15,FillL(STG(MASVol_L,'²'),7,'°'),4,q);
            WriteXY(36,15,Fill (STG(MASVol_L,'²'),7,'°'),4,q);
 { DSP    } WriteXY(16,21,FillL(STG(DSPVol_L,'²'),7,'°'),2,q);
            WriteXY(36,21,Fill (STG(DSPVol_L,'²'),7,'°'),2,q);
 { FM     } WriteXY(16,26,FillL(STG( FMVol_L,'²'),7,'°'),2,q);
            WriteXY(36,26,Fill (STG( FMVol_L,'²'),7,'°'),2,q);
 { MIC    } WriteXY(16,31,FillL(STG(MICVol_L,'²'),7,'°'),2,q);
            WriteXY(36,31,Fill (STG(MICVol_L,'²'),7,'°'),2,q);
 { CD     } WriteXY(16,36,FillL(STG( CDVol_L,'²'),7,'°'),2,q);
            WriteXY(36,36,Fill (STG( CDVol_L,'²'),7,'°'),2,q);
 { LNE    } WriteXY(16,41,FillL(STG(LNEVol_L,'²'),7,'°'),2,q);
            WriteXY(36,41,Fill (STG(LNEVol_L,'²'),7,'°'),2,q);

 case oFilter of
  0:WriteXY(61,27,'Off    ',15,q);
  1:WriteXY(61,27,'Treble ',15,q);
  2:WriteXY(61,27,'Bass   ',15,q);
 end;

 if output =0 then WriteXY(61,28,'Mono  ',15,q)
              else WriteXY(61,28,'Stereo',15,q);
 case input of
  0:WriteXY(61,15,'MiC    ',15,q);
  1:WriteXY(61,15,'CD-ROM ',15,q);
  3:WriteXY(61,15,'LiNE-in',15,q);
 end;

 case iFilter of
  0:WriteXY(61,16,'Off    ',15,q);
  1:WriteXY(61,16,'Treble ',15,q);
  2:WriteXY(61,16,'Bass   ',15,q);
 end;
 READLN;
End;


var c:char;
Begin
New(APat);
if paramcount=5 then begin
 Writeln(' THE MODULE I V1.o, (C) by Syrius ');Writeln;
 Writeln('  Usage: MODPLAYER <MODFILE>.MOD ');
 Halt(0);
End;
{ÄIniT FlaTModE......ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
Writeln;WriteLn(' FlatMode Manager (C) ''96 by Syrius');Writeln;
FlatRequired:=200;
Inited:=InitFlatMem;
If Inited>0 then Begin
 Case Inited of
 1:WriteLn(' [FLATM-ERROR 1] Multitasker active! Reboot without EMS-Manager and try again!');
 2:WriteLn(' [FLATM-ERROR 2] No XMS! Please Reboot with HIMEM.SYS');
 3:WriteLn(' [FLATM-ERROR 3] Not enough XMS available! '#13#10+
           '                 You need at least ',FlatRequired,' KBytes of Free XMS! ');
 End;
 Halt(0);
End;
WriteLn(' FlatMode Inited...');
InitFlatPlayer(FlatStart);
{ÄIniT FlaTModE......ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ}
{LoadMod('C:\FT2\Lizard.mod');
For B:=1 to 10 do begin
 Writeln('Loop1111 : ',b,'  ',d2h(InstLoopS[B],8));
 InstLoopS[B]:=0;
End;
InitFlatPlayer(FlatStart);}
Stereo:=1;
LoadMod('C:\FT2\STAT_ARK.MOD');
{For B:=1 to 10 do begin
 Writeln('Loop     : ',b,'  ',d2h(InstLoopS[B],8));
End;
readln;}

{If ModLoaded=0 then begin
 Writeln(' ModPlayer 1.0, Usage: MODPLAYER <MODFILE>.MOD ');
 Writeln;
 Halt(0);
End;}


Write('Mod  Loaded. ');

Write('Playing Mod...');delay(1000);
SBDetect;
textmode(259);
ASM mov ax,$1003;mov bl,0;INT $10;END;gotoxy(1,1,0);
{WriteMixerDatas;}
LoadGrf('Module3.grf',0);
s:=paramstr(1);
for b:=Length(s) downto 1 do begin
 if s[b]='\' then
   s:=copy(s,b+1,Length(s)-b);
end;
s:=UCase(s);
WriteXY(50-Length(s),40,s+':',7,q);

PlayMod;

{TestPatterns;}
lastpatnum:=255;IS:=0;

Repeat
if keypressed then begin
 c:=readkey;
 if upcase(c)='L' then ModLoop:=Not ModLoop;

 if c=#0 then begin c:=readkey;
   if (C='M') and (IS<4) then Inc(IS);
   if (C='K') and (IS>0) then Dec(IS);
   if (c='I') and (patnum>0) then begin dec(patnum,2);patternline:=63;end;
   if (c='Q') and (patnum<modlen) then patternline:=63;
   WritePattern;
 end;
End;

if PatternLine<>last then begin
 last:=PatternLine;

 if patnum<>lastpatnum then begin
   WriteFlat(Pattern[Arrangement[patnum]],APat,PatBytes);
   lastpatnum:=patnum;
 end;

 WritePattern;
 WriteXY(11,17,D2H(PatNum,2)+'/'+D2H(ModLen,2),7,q);
 WriteXY(11,19,strg(PatternLine,2),7,q);
 WriteXY(11,21,strg0(Speed,2),7,q);
 if ModLoop then WriteXY(11,25,'ON ',7,q) else WriteXY(11,25,'OFF',7,q);
End;

{ writexy(14,21,strg0(ticks,2),7,q);}
 writexy(11,23,strg0(TBufPos,5),7,q);




 For inst:=0 to 3 do begin
  Writexy(18+inst*15+7,42,D2H(longint(MInstSmp[IS+inst]),8),15,q);
  Writexy(18+inst*15+7,43,D2H(longint(MInstPos[IS+inst]),8),15,q);
  Writexy(18+inst*15+7,44,D2H(longint(MInstInc[IS+inst]),8),15,q);
  Writexy(17+inst*15+7,45,D2H(longint(MInstLen[IS+inst] shr 16),4),15,q);
  Writexy(24+inst*15+7,45,D2H(longint(MInstVol[IS+inst]),2),15,q);
  Writexy(17+inst*15+7,46,D2H(longint(MInstLoopS[IS+inst] shr 16),4),15,q);

{ Writexy(17+inst*15+7,45,D2H(longint(MInstVol [IS+inst]),8),5,q);
  Writexy(17+inst*15+7,46,D2H(longint(MInstEff1[IS+inst]),8),5,q);
  Writexy(17+inst*15+7,47,D2H(longint(MInstEff2[IS+inst]),8),5,q);
  Writexy(17+inst*15+7,48,D2H(longint(MInstEff3[IS+inst]),8),5,q);}

 End;
until (C=#27) or endemod;

StopMod;
CloseFlatMem;

LoadGrf('Module4.grf',0);
Writeln;
End.
