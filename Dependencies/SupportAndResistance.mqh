//+------------------------------------------------------------------+
//|                                         SupportAndResistance.mqh |
//|                                       Copyright 2020, Gregory Jo |
//|                                           https://www.gjo-se.com |
//+------------------------------------------------------------------+





// 5 Jahre für D1

// Fibonacci
//int MAX_DAYS_FIBO = 3;
//int MAX_ZIGZAGS_FIBO = 5;

//+------------------------------------------------------------------+
//| Globale Variablen                                                |
//+------------------------------------------------------------------+
double SandR[][2];
int SandRCount;
double weightedLevels[][3];
//int weightedLevelsCount = 1;
int Matchcountup;
int Matchcountdown;
double fibonacciRetracements[7] = {0.236, 0.382, 0.5, 0.618, 0.886, 1.618, 2.618};


//+------------------------------------------------------------------+

bool getSupportAndResistance() {

   SandRCount = 0;

   getWeightedLevels();

   return (true);

}


void getWeightedLevels() {

   ArrayInitialize(SandR, EMPTY_VALUE);
   ArrayInitialize(weightedLevels, EMPTY_VALUE);
   ArrayResize(SandR, InpMaxDays * 2);
   ArrayResize(weightedLevels, InpMaxDays * 3);

   int lineWidth;

   //getDailyHighLow();
   getFractals();
//   getZigZag();

   //getFibonacciDaily();
   //getFibonacciZigZag();
   //getVolumeProfil();

   double range = NormalizeDouble(InpMaxTolerancePoints * Point(), Digits());
   int index = 1;

   double bid = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());

   double minRange = bid - NormalizeDouble(InpMaxChannelPoints * Point(), Digits());
   double maxRange = bid + NormalizeDouble(InpMaxChannelPoints * Point(), Digits());

   while(index < (ArraySize(SandR) / 2)) {

      double level = NormalizeDouble(SandR[index][0], Digits());
      double minLevel = level - range;
      double maxLevel = level + range;
      double value = SandR[index][1];

      ArraySort(SandR);

      weightedLevels[index][0] = level;
      weightedLevels[index][1] = value;
      weightedLevels[index][2] = value;

      int minIndex = ArrayBsearch(SandR, minLevel);
      if(SandR[minIndex][0] == minLevel) {
         weightedLevels[index][2] += SandR[minIndex][1];
      }
      int maxIndex = ArrayBsearch(SandR, maxLevel);
      if(SandR[maxIndex][0] == maxLevel) {
         weightedLevels[index][2] += SandR[maxIndex][1];
      }

      int weightedValue = weightedLevels[index][2];


      if(InpDrawLevelLines == true && minRange <= level && level <= maxRange && weightedValue >= InpMinValueLineWidth1) {

         if(weightedValue >= InpMinValueLineWidth1) lineWidth = 1;
         if(weightedValue >= InpMinValueLineWidth2) lineWidth = 2;
         if(weightedValue >= InpMinValueLineWidth3) lineWidth = 3;
         if(weightedValue >= InpMinValueLineWidth4) lineWidth = 4;
         if(weightedValue >= InpMinValueLineWidth5) lineWidth = 5;

         string lineText = "Level: " + DoubleToString(level, Digits() - 1) + " (" + IntegerToString(weightedValue) + ")";

         createHLine(LEVEL_LINE_NAME + DoubleToString(level, Digits() - 1), level, lineText, clrPaleGoldenrod, lineWidth);
      }

      index++;

   }
}
//+------------------------------------------------------------------+

void getDailyHighLow() {

   int foundDailyHigh = 0;
   int shiftDailyHigh = 1;
   while(foundDailyHigh < InpMaxDays) {
      double dailyHigh = iHigh(Symbol(), PERIOD_D1, shiftDailyHigh);
      if(dailyHigh != 0) {
         setLevelToSandRArray(dailyHigh, InpValueDailyHighLow);
         foundDailyHigh++;
      }

      shiftDailyHigh++;
   }

   int foundDailyLow = 0;
   int shiftDailyLow = 1;
   while(foundDailyLow < InpMaxDays) {
      double dailyLow = iLow(Symbol(), PERIOD_D1, shiftDailyLow);
      if(dailyLow != 0) {
         setLevelToSandRArray(dailyLow, InpValueDailyHighLow);
         foundDailyLow++;
      }

      shiftDailyLow++;
   }

}
//+------------------------------------------------------------------+

bool getFractals() {

   ResetLastError();
   int iFractalesHandle = iFractals(Symbol(), PERIOD_D1);

   if(iFractalesHandle == INVALID_HANDLE) {
      PrintFormat("Failed to create iFractalsHandlesymbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());

      return (false);

   }

   Print("iFractalesHandle: " + iFractalesHandle);
   //CopyBuffer(ind_handle,0,0,amount,up_arrows)<0
   if(
      CopyBuffer(iFractalesHandle, LOWER_LINE, 0, InpMaxDays, iFractalsLowerLineBuffer) < 0 ||
      CopyBuffer(iFractalesHandle, UPPER_LINE, 0, InpMaxDays, iFractalsUpperLineBuffer) < 0) {
      PrintFormat("Failed to copy data from the iFractals indicator, error code %d", GetLastError());
      return(false);
   }

   int shiftUpFractal = 0;
   while(shiftUpFractal < InpMaxDays) {
      if(iFractalsUpperLineBuffer[shiftUpFractal] != EMPTY_VALUE) {
         setLevelToSandRArray(iFractalsUpperLineBuffer[shiftUpFractal], InpValueFractal);
      }
      shiftUpFractal++;
   }

   int shiftDownFractal = 0;
   while(shiftDownFractal < InpMaxDays) {
      if(iFractalsLowerLineBuffer[shiftDownFractal] != EMPTY_VALUE) {
         setLevelToSandRArray(iFractalsLowerLineBuffer[shiftDownFractal], InpValueFractal);
      }
      shiftDownFractal++;
   }

   return(true);

}

bool getZigZag() {

   int depth = 12;  // kleinste Zahl an Bars zwischen zwei Extrema
   int deviation = 5;  // Preisabstand größer ist als das Point-Minimum
   int backstep = 3;  // Minimmum an Bars zwischen zwei Extrema

   double iCustomZigZagArray[];

   ResetLastError();
   int iCustomZigZagHandle = iCustom(Symbol(), PERIOD_D1, "Examples\\ZigZag", depth, deviation, backstep);

   if(iCustomZigZagHandle == INVALID_HANDLE) {
      PrintFormat("Failed to create iCustomZigZagHandle %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());

      return (false);

   }

   if(CopyBuffer(iCustomZigZagHandle, 0, 0, InpMaxDays, iCustomZigZagArray) < 0) {
      PrintFormat("Failed to copy data from the iCustomZigZag indicator, error code %d", GetLastError());
      return(false);
   }

   int shiftZigZag = 0;
   while(shiftZigZag < InpMaxDays) {
      if(iCustomZigZagArray[shiftZigZag] != EMPTY_VALUE) {
         setLevelToSandRArray(iCustomZigZagArray[shiftZigZag], InpValueZigZig);
      }
      shiftZigZag++;
   }

   return(true);

}
//+------------------------------------------------------------------+



//void getFibonacciDaily() {
//
//   int firstDay = 0;
//   int shiftDay = 0;
//   int fiboDailyValue = 1;
//   while(firstDay < MAX_DAYS_FIBO) {
//      double dailyLow = iLow(Symbol(), PERIOD_D1, shiftDay);
//      double dailyHigh = iHigh(Symbol(), PERIOD_D1, shiftDay);
//
//      if(dailyLow != 0 && dailyHigh != 0) {
//         int fibonacciRetracementIndex = 0;
//         while(fibonacciRetracementIndex < ArraySize(fibonacciRetracements) - 1) {
//            double fibonacciRetracement = dailyHigh - ((dailyHigh - dailyLow) * fibonacciRetracements[fibonacciRetracementIndex]);
//            setLevelToSandRArray(fibonacciRetracement, fiboDailyValue);
//            fibonacciRetracementIndex++;
//         }
//      }
//
//      firstDay++;
//      shiftDay++;
//   }
//
//}
////+------------------------------------------------------------------+
//
//void getFibonacciZigZag() {
//
//   int depth = 12;  // kleinste Zahl an Bars zwischen zwei Extrema
//   int deviation = 5;  // Preisabstand größer ist als das Point-Minimum
//   int backstep = 3;  // Minimmum an Bars zwischen zwei Extrema
//   int fibonacciZigZagValue = 1;
//
//   int foundZigZags = 0;
//   int shiftCandle = 0;
//   double zigZags[5];
//
//   while(foundZigZags < MAX_ZIGZAGS_FIBO) {
//      double zigZag = iCustom(Symbol(), PERIOD_FOR_SUPPORT_AND_RESISTANCE, "ZigZag", depth, deviation, backstep, MODE_MAIN, shiftCandle);
//      if(zigZag != 0) {
//         zigZags[foundZigZags] = zigZag;
//         foundZigZags++;
//      }
//      shiftCandle++;
//   }
//
//   int fibonacciZigZagIndex = 0;
//
//   while(fibonacciZigZagIndex < ArraySize(zigZags) - 1) {
//      int fibonacciRetracementIndexOne = 0;
//      int fibonacciRetracementIndexTwo = 0;
//      if(zigZags[fibonacciZigZagIndex] > zigZags[fibonacciZigZagIndex + 1]) {
//         while(fibonacciRetracementIndexOne < ArraySize(fibonacciRetracements) - 1) {
//            double fibonacciRetracement = zigZags[fibonacciZigZagIndex] - ((zigZags[fibonacciZigZagIndex] - zigZags[fibonacciZigZagIndex + 1]) * fibonacciRetracements[fibonacciRetracementIndexOne]);
//            setLevelToSandRArray(fibonacciRetracement, fibonacciZigZagValue);
//            fibonacciRetracementIndexOne++;
//         }
//      } else {
//         while(fibonacciRetracementIndexTwo < ArraySize(fibonacciRetracements) - 1) {
//            double fibonacciRetracement = zigZags[fibonacciZigZagIndex + 1] - ((zigZags[fibonacciZigZagIndex + 1] - zigZags[fibonacciZigZagIndex]) * fibonacciRetracements[fibonacciRetracementIndexTwo]);
//            setLevelToSandRArray(fibonacciRetracement, fibonacciZigZagValue);
//            fibonacciRetracementIndexTwo++;
//         }
//      }
//
//      fibonacciZigZagIndex++;
//   }
//}
//
//bool getVolumeProfil() {
//
//   ResetLastError();
//
//   int volumeProfilValue = 1;
//
//   string fileName = Symbol() + ".csv";
//   int filehandle = FileOpen(fileName, FILE_READ | FILE_CSV, ";");
//
//   if(filehandle != INVALID_HANDLE) {
//
//      while(!FileIsEnding(filehandle)) {
//         string level = FileReadString(filehandle);
//         setLevelToSandRArray(NormalizeDouble(StringToDouble(level) * Point, Digits), volumeProfilValue);
//      }
//
//      FileClose(filehandle);
//      return(true);
//
//   } else {
//
//      PrintFormat("File open failed: %s\\Files\\%s", TerminalInfoString(TERMINAL_DATA_PATH), fileName);
//      Print("File open failed, error ", GetLastError());
//      return(false);
//   }
//}

//+------------------------------------------------------------------+

void setLevelToSandRArray(double level, int value) {

   double roundedLevel = NormalizeDouble(level, Digits() - 1);
   ArraySort(SandR);

   int foundIndex = ArrayBsearch(SandR, roundedLevel);
   if(SandR[foundIndex][0] != roundedLevel) {
      SandR[SandRCount][0] = roundedLevel;
      SandR[SandRCount][1] = value;
      SandRCount++;
   } else {
      SandR[foundIndex][1] = SandR[foundIndex][1] + value;
   }

}
//+------------------------------------------------------------------+


void deleteLevelLines() {

   string objectName;
   int objsTotal = ObjectsTotal(0, 0, OBJ_HLINE);
   while (objsTotal > 0) {
      objsTotal--;
      objectName = ObjectName(0, objsTotal, 0, OBJ_HLINE);
      if ( StringFind( objectName, LEVEL_LINE_NAME ) != -1 ) {
         ObjectDelete(0, objectName);
      }
   }
}
//+------------------------------------------------------------------+
