#include <NN.mqh>
#include <zeus-yt/Relativo.mqh>
#include <Trade/Trade.mqh>
CTrade trade;

input string FILENAME = "zeus.txt";
input int PROFUNDIDAD = 10;
input int NUM_RELATIVOS = 10;
input TipoBusqueda TIPO_BUSQUEDA = HIGHLOW;
input double MIN_CD;
input double MAX_CD;
input int MIN_CT;
input int MAX_CT;
input double RELACION = 2;

ColaRelativos relativos;
RedNeuronal *rn;

double sigmoide(double v) {
   return 1/(1+MathPow(2.71828, v*-1));
}

double derivada_sigmoide(double v) {
   return sigmoide(v)*(1-sigmoide(v));
}

void dibujar_prediccion(vector &atributos) {
   vector resultado = rn.predecir(atributos);
   
   Relativo ultimo_relativo = relativos.get_last_relativo();
   
   double precio = ((resultado[0] * (MAX_CD - MIN_CD)) + MIN_CD) * ultimo_relativo.price;
   int tiempo = (int)(resultado[1] * (MAX_CT - MIN_CT)) + MIN_CT;
   
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   
   if (precio > bid) {
      double diferencia = precio - ask;
      double sl = NormalizeDouble(ask - diferencia * RELACION, _Digits);
      trade.Buy(1, _Symbol, ask, sl, NormalizeDouble(precio, _Digits));
   } else if (precio < bid) {
      double diferencia = bid - precio;
      double sl = bid + diferencia * RELACION;
      trade.Sell(1, _Symbol, bid, sl, NormalizeDouble(precio, _Digits));
   }
   
   string name = "prediccion";
   ObjectCreate(
      0,
      name,
      OBJ_TREND,
      0,
      ultimo_relativo.time,
      ultimo_relativo.price,
      ultimo_relativo.time+tiempo,
      precio
   );
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrGreenYellow);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 3);
}

void OnInit() {
   rn = new RedNeuronal(FILENAME, sigmoide, derivada_sigmoide, 1);

   relativos.buscar_relativos(PROFUNDIDAD, NUM_RELATIVOS+1, _Symbol, _Period, TIPO_BUSQUEDA);
   relativos.dibujar_lineas(_Symbol, _Period);
   
   EventSetTimer(PeriodSeconds());
}

void OnDeinit(const int reason) {
   delete(rn);
}

void OnTimer() {
   bool resultado = relativos.buscar_nuevos_relativos(PROFUNDIDAD, _Symbol, _Period, TIPO_BUSQUEDA);
   relativos.dibujar_lineas(_Symbol, _Period);
   if (resultado) {
      vector atributos = relativos.get_zeus_atributos(NUM_RELATIVOS);
      dibujar_prediccion(atributos);
   }
}