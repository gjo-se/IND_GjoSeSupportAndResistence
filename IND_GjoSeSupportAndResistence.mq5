/*

   IND_GjoSeSupportAndResistence.mq5
   Copyright 2021, Gregory Jo
   https://www.gjo-se.com

   Version History
   ===============

   1.0.0 Initial version

   ===============

//*/
#include "Basics\\Includes.mqh"

#property   copyright   "2021, GjoSe"
#property   link        "http://www.gjo-se.com"
#property   description "GjoSe SupportAndResistence"
#define     VERSION "1.0"
#property   version VERSION
#property   strict

//#property indicator_chart_window
//#property indicator_buffers 2
//#property indicator_plots   2
////--- FractalUp bauen
//#property indicator_label1  "FractalUp"
//#property indicator_type1   DRAW_ARROW
//#property indicator_color1  clrBlue
////--- FractalDown bauen
//#property indicator_label2  "FractalDown"
//#property indicator_type2   DRAW_ARROW
//#property indicator_color2  clrRed

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_color1  Gray
#property indicator_color2  Gray
#property indicator_label1  "Fractal Up"
#property indicator_label2  "Fractal Down"

int    ExtArrowShift=-10;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit() {

   SetIndexBuffer(0,iFractalsLowerLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,iFractalsUpperLineBuffer,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_ARROW,217); // Pfeil nach oben
   PlotIndexSetInteger(1,PLOT_ARROW,218); // Pfeil nach unten
   
//--- arrow shifts when drawing
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,ExtArrowShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-ExtArrowShift);
//--- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int pRatesTotal,
                const int pPrevCalculated,
                const datetime &pTime[],
                const double &pOpen[],
                const double &pHigh[],
                const double &pLow[],
                const double &pClose[],
                const long &pTickVolume[],
                const long &pVolume[],
                const int &pSpread[]         ) {
                
                   getSupportAndResistance();

   return(pRatesTotal);
}
//+------------------------------------------------------------------+

void OnDeinit(const int reason) {

   //for(int i = 0; i < ArraySize(name); i++) {
   //   ObjectDelete(0, name[i]);
   //}

   deleteObjects();

}
//+------------------------------------------------------------------+

void deleteObjects() {

   string objname;
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--) {
      objname = ObjectName(0, i);
      if(StringFind(objname, LEVEL_LINE_NAME) == -1) {
         continue;
      } else {
         ObjectDelete(0, objname);
      }
   }

}
//+------------------------------------------------------------------+
