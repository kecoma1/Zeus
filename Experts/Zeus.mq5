#include <NN.mqh>
#include <Relativo.mqh>
ColaRelativos relativos;

input string NOMBRE_MODELO = "";
input int PROFUNDIDAD = 10;
input int NUM_RELATIVOS = 10;
input TipoBusqueda TIPO_BUSQUEDA = HIGHLOW;
input double MAX_CD;
input double MAX_CT;
input double MIN_CD;
input double MIN_CT;

RedNeuronal *rn;

double sigmoide(double v) {
   return 1/(1+MathPow(2.71828, v*-1));
}

double derivada_sigmoide(double v) {
   return sigmoide(v)*(1-sigmoide(v));
}

void dibujar_prediccion(vector &atributos) {
   string name = "prediccion";
   
   vector resultado = rn.predecir(atributos);
   Print("RESULTADO: ", resultado);
   
   Relativo rel = relativos.get_last_relativo();
   double price = ((resultado[0]*(MAX_CD-MIN_CD))+MIN_CD)*rel.price;
   int tiempo = (int)((resultado[1]*(MAX_CT-MIN_CT))+MIN_CT);
   
   Print(price);
   Print(tiempo);
   
   ObjectCreate(0, name, OBJ_TREND, 0, rel.time, rel.price, rel.time+tiempo, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrGreenYellow);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 6);
}


void OnInit() {
   rn = new RedNeuronal(NOMBRE_MODELO, sigmoide, derivada_sigmoide, 1);
   
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
   MqlRates velas[];
   CopyRates(_Symbol, _Period, 0, NUM_RELATIVOS*200, velas);
   vector atributos = relativos.toNNVector(NUM_RELATIVOS, velas);
   if (resultado) dibujar_prediccion(atributos);
}
