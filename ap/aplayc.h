#include <i86.h>
#include <string.h>
// Types / Structures ----------------------------------------------------//

typedef unsigned long int dword;
typedef unsigned short int word;
typedef unsigned char byte;
typedef short int integer;

_Packed struct PatternData {
 byte volume;
 byte sample;
 byte index;
 byte fx;
 byte fxbyte;
};

_Packed struct SampleStruc {
 void *start;      // 0
 dword len;        // 4
 dword lStart;     // 8
 dword c2spd;      // 12
};

_Packed struct CurrentSampleStruc { //  64 Byte pro Channel = 256 Bytes
 dword start;      // 0  <-
 dword length;     // 4    |
 dword lStart;     // 8    |
 dword c2spd;      // 12   |
 byte  volume;     // 16 <-  17 Byte Loaded from SampleStruc!

 byte  monoVol;    // 17
 byte  volLeft;    // 18
 byte  volRight;   // 19
 byte  panning;    // 20
 byte  status;     // 21  Bit 0:  1-> Playing, 0-> Stopped.
                   //     Bit 7:  1-> Left Orientated, 0-> Right orientated
 word  period;     // 22   Porta 2 note
 dword countI;     // 24
 word  countF;     // 28
 word  incF;       // 30   Intel-Format!!! Lo-Hi
 dword incI;       // 32
 word  dstPeriod;  // 36   Destination Period for Tone Porta / Source for Vibrato
 byte  smpIndex;   // 38 ¿
 byte  noteIndex;  // 39 ³    Save it for e.g.
 byte  volumeCol;  // 40 ³
 byte  effect;     // 41 ³ this @$%#() NOTE-DELAY
 byte  fxByte;     // 42 Ù          !!!

 byte  tickCmd;    // 43   Command-Byte as Index to JmpTable2
 byte  tickCmd2;   // 44   Command-Byte as Index to JmpTable2
 byte  wByte;      // 45
 byte  wByte2;     // 46
 byte  wByte3;     // 47
 byte  lastVSld;   // 48
 byte  lastPSldD;  // 49
 byte  lastPSldU;  // 50
 byte  lastPorta;  // 51
 byte  lastVib;    // 52
 byte  lastVibPos; // 53
 byte  lastRetrig; // 54
 byte  loopStart;  // 55
 byte  loopCount;  // 56
 byte  db57;       // 57
 byte  db58;       // 58
 byte  db59;       // 59
 byte  db60;       // 60
 byte  db61;       // 61
 byte  db62;       // 62
 byte  db63;       // 63
};

// EXTERN Variables / Arrays of AP_C.ASM!---------------------------------//

 extern dword startPattern;
 extern dword TM3SyncCount;
 extern byte  songLoop;
 extern dword patternLen;

 extern word  soundCard;
 extern byte  stereo;
 extern word  ADR;
 extern byte  IRQ;
 extern byte  DMA;
 extern word  samplingRate;
 extern byte  loopIt;

 extern byte  DMAFlipFlop;
 extern dword DIVConst;

 extern byte  ordNum;
 extern byte  patternLine;

 extern byte  IRQ_Stop;
 extern byte  IRQ_Finished;


 extern word  masterSpace;
 extern byte  globalVol;
 extern byte  speed;
 extern byte  bpm;
 extern byte  tempo;
 extern byte  channels;
 extern byte  songLen;
 extern byte  patNum;
 extern byte  smpNum;

 extern dword lineAdd;
 extern word  packedLen;

 extern byte  *DMABuf;
 extern byte  *volTableP;
 extern byte  *orderP;
 extern byte  *panningP;
 extern byte  *sampleVolP;

 extern byte  *TM3BufferP;
 extern byte  *mixBufP;
 extern byte  *postProcP;

 extern struct PatternData **PTRPatternP;
 extern struct SampleStruc *sampleP;
 extern struct CurrentSampleStruc *csampleP;

// EXTERN Functions ------------------------------------------------------//

 extern byte playTM3();
 extern stopTM3();
 extern AP_InitPointers();
 extern byte detectSB();
 extern byte checkSBSettings();
 extern setCursor();
 extern dword openFile(byte mode, const char *name);
 extern readFile(dword handle, void *adr, word num );
 extern closeFile(dword handle);

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
dword DPMIAlloc(int len) { union REGS r;
  r.w.cx=len & 0xffff;
  r.w.bx=len >> 16;
  r.w.ax=0x501;
  int386(0x31,&r,&r);
  return((r.w.bx << 16)+r.w.cx);
}

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
int LoadTM3(const char *filename) { integer i;
  dword AP_H;
  word count;
  byte work,ch;
  word line;
  struct PatternData *Pat;
  void *Pattern;
  dword empty;
  printf("\nLoading %s\n",filename);
  AP_H=openFile(0, filename);

  if (AP_H==0) { printf("\nError opening file %s\n",filename); return(0); }

  empty=DPMIAlloc(1);
  readFile(AP_H, &masterSpace,2);
  readFile(AP_H, &globalVol,1);
  readFile(AP_H, &speed,1);
  readFile(AP_H, &bpm,1); tempo=bpm*2/5;
  readFile(AP_H, &channels,1);
  readFile(AP_H, &songLen,1);
  readFile(AP_H, orderP,songLen);
  readFile(AP_H, &patNum,1);
  readFile(AP_H, &smpNum,1);
  readFile(AP_H, panningP, channels);


  for (i=0;i<smpNum;i++) {
    readFile(AP_H, &sampleP[i].len,12);
    if (sampleP[i].len==0) sampleP[i].start=(void *)empty;
                      else sampleP[i].start=(void *)DPMIAlloc(sampleP[i].len);
  }

  readFile(AP_H, sampleVolP, smpNum);

  for (i=0;i<patNum;i++) {
   line=channels*64*5;
   PTRPatternP[i] = Pat = (struct PatternData *)DPMIAlloc(channels*64*5);
   memset(Pat,0,channels*320);
   readFile(AP_H, &packedLen, 2);
   readFile(AP_H, DMABuf, packedLen);line=0;
   for (count=0;line<64*channels;) {
    work=DMABuf[count++];
    if (work==0) { line+=channels; }
    else { ch=work&31; if (ch<=channels) {
      if ((work &  32)>0) {  Pat[line+ch].sample=DMABuf[count++];
                             Pat[line+ch].index =DMABuf[count++]; }
      if ((work &  64)>0) {  Pat[line+ch].volume=DMABuf[count++]; }
      if ((work & 128)>0) {  Pat[line+ch].fx    =DMABuf[count++];
                             Pat[line+ch].fxbyte=DMABuf[count++]; }
    } else {
      if ((work &  32)>0) count+=2;
      if ((work &  64)>0) count++;
      if ((work & 128)>0) count+=2;
    } }
   }
  }

/*Pat = PTRPatternP[4];
   for (i=0;i<13*4;i+=4) {
     printf("|%2x %2x %2x %2x%2x", Pat[i+0].sample,Pat[i+0].index,
                                   Pat[i+0].volume,Pat[i+0].fx,Pat[i+0].fxbyte);
     printf("|%2x %2x %2x %2x%2x", Pat[i+1].sample,Pat[i+1].index,
                                   Pat[i+1].volume,Pat[i+1].fx,Pat[i+1].fxbyte);
     printf("|%2x %2x %2x %2x%2x", Pat[i+2].sample,Pat[i+2].index,
                                   Pat[i+2].volume,Pat[i+2].fx,Pat[i+2].fxbyte);
     printf("|%2x %2x %2x %2x%2x", Pat[i+3].sample,Pat[i+3].index,
                                   Pat[i+3].volume,Pat[i+3].fx,Pat[i+3].fxbyte);
     printf("\n");
  } */

  for (i=0;i<smpNum;i++) {
    readFile(AP_H, DMABuf,sampleP[i].len);
//  printf("SMP: %X of %X, start=%X, len=%X ?=%X \n",i,smpNum,sampleP[i].start, sampleP[i].len, &sampleP[0x24].len);
    if (sampleP[i].len>0) memcpy(sampleP[i].start, DMABuf, sampleP[i].len);
  }
  closeFile(AP_H);
  return(1);
}

