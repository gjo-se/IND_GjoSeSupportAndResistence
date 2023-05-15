//+------------------------------------------------------------------+
//|                                                       Inputs.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// Inputs
sinput string  SupportAndResistence;    // ---------- Support & Resistence ---------
input bool InpDrawLevelLines = true;
input int InpMaxDays = 100;
input int InpMaxChannelPoints = 2000;
input int InpMaxTolerancePoints = 40;
input int   InpMinValueLineWidth1 = 3;
input int   InpMinValueLineWidth2 = 5;
input int   InpMinValueLineWidth3 = 7;
input int   InpMinValueLineWidth4 = 9;
input int   InpMinValueLineWidth5 = 11;

// Lines for
input int InpValueDailyHighLow = 1;
input int InpValueFractal = 2;
input int InpValueZigZig = 3;

////+------------------------------------------------------------------+
//
//void convertInpStringsToArray(){
//       StringSplit(InpKLMFiboLevels, StringGetCharacter(",", 0), klmFiboLevelsArray);
//       StringSplit(InpGWLFiboLevels, StringGetCharacter(",", 0), gwlFiboLevelsArray);
//       StringSplit(InpSGLFiboLevels, StringGetCharacter(",", 0), sglFiboLevelsArray);
//}
