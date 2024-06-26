#include <zeus-yt/Relativo.mqh>
ColaRelativos relativos;

input int PROFUNDIDAD = 10;
input int NUM_RELATIVOS = 10;
input TipoBusqueda TIPO_BUSQUEDA = HIGHLOW;
input int NUM_DECIMALES = 3;

input string filename = "datos_compra.csv";

int fh;

void OnInit() {
   string cabecera = "";   
   for (int i = 0; i < NUM_RELATIVOS-1; i++)
      cabecera += "D"+IntegerToString(i)+IntegerToString(i+1)+","
      "T"+IntegerToString(i)+IntegerToString(i+1)+",";
   cabecera += "CD,CT";
   
   fh = FileOpen(filename, FILE_WRITE|FILE_COMMON|FILE_ANSI, 0);
   FileWrite(fh, cabecera);

   relativos.buscar_relativos(PROFUNDIDAD, NUM_RELATIVOS+1, _Symbol, _Period, TIPO_BUSQUEDA);
   relativos.dibujar_lineas(_Symbol, _Period);
   EventSetTimer(PeriodSeconds());
}

void OnDeinit(const int reason) {
   FileClose(fh);
}

void OnTimer() {
   bool resultado = relativos.buscar_nuevos_relativos(PROFUNDIDAD, _Symbol, _Period, TIPO_BUSQUEDA);
   relativos.dibujar_lineas(_Symbol, _Period);
   if (resultado) FileWrite(fh, relativos.recoger_datos(NUM_RELATIVOS, NUM_DECIMALES));
}