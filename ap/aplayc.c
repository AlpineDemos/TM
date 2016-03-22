//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/
//ÜÛÛÛÛÛßßßßÛÛÛÛÛÛÜ  ÛÛÛÛÛÛÛßßßÛÛÛÛÛÛÜ  ßßßßßßßßßßÛÛÛÛÛÛÜ ALPINE PLAYER V3.00/
//ÛÛÛÛÛÛ    ÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ          ßßÛÛÛÛÛÛÛ  (C) 1997          /
//ÛÛÛÛÛÛ ßßßÛÛÛÛÛÛÛ  ÛÛÛÛÛÛÛßßßßßßßßß   ÜÜÜÜÜÜÜÜÜÜÛÛÛÛÛÛß by Syrius / Alpine /
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/
// AP 3.0 PMODE-ASM-Link-Version.                                            /
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/

#include "aplayc.h"
#include <stdlib.h>
#include <conio.h>

byte b; dword d; word w;


//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//

CheckVars() {
 setCursor(0x0100);
 printf("SmpRate: %2d \n",samplingRate);
 printf("Line   : %2X \n",patternLine);
 printf("Order  : %X  \n",ordNum );
 printf("Pattern: %X  \n",orderP[ordNum]);
 printf(" Offset: %X  \n",PTRPatternP[orderP[ordNum]]);
 printf(" Real  : %X  \n",startPattern);
 printf("FlipFlp: %2X \n",DMAFlipFlop);
 printf("Speed  : %2X \n",speed);
 printf("bpm    : %2X \n",bpm);
 printf("Start: %8x %8x %8x %8x\n", csampleP[0].start,
                                    csampleP[1].start,
                                    csampleP[2].start,
                                    csampleP[3].start);

 printf("Len  : %8x %8x %8x %8x\n", csampleP[0].length,
                                    csampleP[1].length,
                                    csampleP[2].length,
                                    csampleP[3].length);

 printf("Posit: %8x %8x %8x %8x\n", csampleP[0].countI,
                                    csampleP[1].countI,
                                    csampleP[2].countI,
                                    csampleP[3].countI);
 printf("DMABuf : %2X \n",DMABuf);
 printf("DMABufE: %2X \n",DMABuf+27564);
}
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
void main(int a,char *argc[]) {
  int test; word j;
  unsigned int test2;
  unsigned char test3;


  if (!AP_InitPointers()) { printf("Memory Error!"); }


  ADR=0x220;
  IRQ=5;
  DMA=1;
  stereo=1;
  soundCard=0x300;

  samplingRate=21000;

  loopIt=1;
  if (!(j=LoadTM3(argc[1]))) j=LoadTM3("ziron17a.tm3");
  if (j) {

  if (checkSBSettings()) { printf(" OK.");
  printf(" SB %x found at adr:%x irq:%d dma:%d...\n",soundCard,ADR,IRQ,DMA);
  playTM3();
  while (!kbhit()) CheckVars();
  printf("Key.\n");
  while (kbhit()) getch();
  stopTM3();

  } else printf("Initialisation failed!\n");
} }
