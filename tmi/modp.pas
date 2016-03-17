
{ Mod - Player in Pascal nach eigenen Vorstellungen           DeCITE       }

unit ModP;
Interface
uses dos;

Procedure InitFlatPlayer(Start:Longint);
Procedure LoadMod(ModF:String);
Procedure PlayMod;
Procedure StopMod;
Procedure ALoadMod;
Function  SBDetect:Boolean;

Var
 Patternline:Word;
 ModLoop    :Boolean;
 PatNum     :Byte;
 ModLen     :Byte;                              { Songl„nge in Patterns }
 Pattern    :Array[0..63] of LongInt;
 Arrangement:Array[0..128] of Byte;
 Speed      :Byte;                              { Ticks pro Patternline }
 TBufPos    :Longint;                         { Position in Mischpuffer }
 MInstSmp   :Array[0..7] of LongInt;
 MInstPos   :Array[0..7] of Longint;
 MInstInc   :Array[0..7] of LongInt;
 MInstLen   :Array[0..7] of Longint;
 MInstLoopS :Array[0..7] of Longint;
 MInstVol   :Array[0..7] of Longint;
 MInstEff1  :Array[0..7] of Longint;
 MInstEff2  :Array[0..7] of Longint;
 MInstEff3  :Array[0..7] of Longint;
 EndeMod    :Boolean;

Implementation

Type PatternType4=array[0..63,0..3,1..4] of byte;
Var Buffer0,
    Buffer1,
    Buffer2:LongInt;
    TBufStop:Longint;
    LoadBuffer:Pointer;
    mixbuff:array[0..880] of byte;
    Buffers:array[0..10] of Pointer;
    SBProDetected:Boolean;
    OldInt     :Pointer;                             { Alter SB-Interrupt }
    ModName    :Array[0..19] of Char;
    ModLoopStart:Byte;
    Samples    :Array[0..31] of LongInt;
    InstName   :Array[0..31,0..22] of Char;
    InstLen    :Array[0..31] of LongInt;
    InstVol    :Array[0..31] of LongInt;
    InstLoopS  :Array[0..31] of LongInt;
    InstLoopL  :Array[0..31] of LongInt;



    BufActive  :Byte;               { Welcher Buffer wird gerade gespielt? }

    Ticks      :Byte;
    OldTimerInc:Byte;                  { bei jedem 3.Mal Timer 0 aufrufen }
    APattern   :^PatternType4;

    LoadName:Array[1..50] of Char ;


Type
Pt=record
   Off:word;
   Seg:word;
End;

Var FMODStart:Longint;
    FlatPos  :LongInt;


{$F+}
Procedure PlayMOD;External;
Procedure StopMOD;External;
Procedure ALoadMod;External;
Function  SBDetect:Boolean;External;
{$L Sb1 }
{$F-}
Procedure InitFlatPlayer(Start:Longint);Begin FMODStart:=Start;FlatPos:=Start;End;

Procedure LoadMod(ModF:String);var b:byte;
Begin ModF:=ModF+#0;
For b:=1 to Length(ModF) do LoadName[B]:=Modf[B];
ALoadMod;
End;


Begin
 getmem(LoadBuffer,65535);
End.
