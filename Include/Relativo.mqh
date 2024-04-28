enum TipoRelativo {
   MAXIMO,
   MINIMO,
   NONE,
};

enum TipoBusqueda {
   HIGHLOW,
   CLOSE
};

struct Relativo {
   double price;
   datetime time;
   TipoRelativo tipo;
};

#define VELAS_POR_RELATIVO 200

class ColaRelativos {
   public:
      Relativo relativos[];
      void add(Relativo &relativo);
      Relativo pop();
      void buscar_relativos(
         int profundidad,
         int _num_relativos,
         string _symbol,
         ENUM_TIMEFRAMES _periodo,
         TipoBusqueda tipoBusqueda
      );
      bool buscar_nuevos_relativos(
         int profundidad,
         string _symbol,
         ENUM_TIMEFRAMES _periodo,
         TipoBusqueda tipoBusqueda
      );
      void dibujar_lineas(
         string _symbol,
         ENUM_TIMEFRAMES _periodo
      );
      TipoRelativo get_last_tipo();
      Relativo get_last_relativo();
      void reset();
      vector toNNVector(int size, MqlRates &_velas[]);
      bool set_relativo(
         MqlRates &_velas[],
         int i,
         int profundidad,
         TipoBusqueda tipoBusqueda
      );
      string recoger_datos(int num_relativos_a_guardar, int num_decimales);
};

TipoRelativo ColaRelativos::get_last_tipo() {
   int num_relativos = ArraySize(this.relativos);
   return num_relativos <= 0 ? NONE : this.relativos[num_relativos-1].tipo;
}

Relativo ColaRelativos::get_last_relativo() {
   int num_relativos = ArraySize(this.relativos);
   Relativo relativo;
   relativo.time = -1;
   return num_relativos <= 0 ? relativo : this.relativos[num_relativos-1];
}

void ColaRelativos::add(Relativo &relativo) {
   int num_relativos = ArraySize(this.relativos);
   
   ArrayResize(this.relativos, num_relativos+1);
   
   this.relativos[num_relativos] = relativo;
}

Relativo ColaRelativos::pop() {
   Relativo result = this.relativos[0];
   int num_relativos = ArraySize(this.relativos);
   
   for (int i = 1; i < num_relativos; i++) {
      this.relativos[i-1] = this.relativos[i];
   }
   
   ArrayResize(this.relativos, num_relativos-1);
   
   return result;
}


vector ColaRelativos::toNNVector(int size, MqlRates &_velas[]) {
   vector result(size*2);
   
   if (ArraySize(this.relativos) < size) return result;
   
   for (int i = -1; i < size-1; i++) {
      double diff_precio = 0;
      long diff_time = 0;
      if (i == -1) {
         diff_precio = _velas[0].close-this.relativos[0].price;
         diff_time = _velas[0].time-this.relativos[0].time;
      } else {
         diff_precio = this.relativos[i].price-this.relativos[i+1].price;
         diff_time = this.relativos[i].time-this.relativos[i+1].time;
      }
      result.Set((i+1)*2, diff_precio);
      result.Set(((i+1)*2)+1, diff_time);
   }
   return result;
}


TipoRelativo es_relativo(
   MqlRates &_velas[],
   int indice,
   int profundidad,
   TipoBusqueda tipoBusqueda
) {
   bool es_maximo = true;
   bool es_minimo = true;
   
   for (int i = indice-profundidad; i < indice+profundidad; i++) {
      if (i == indice) continue;
   
      if (tipoBusqueda == CLOSE) {
         if (_velas[i].close < _velas[indice].close) es_minimo = false;
         if (_velas[i].close > _velas[indice].close) es_maximo = false;
      } else if (tipoBusqueda == HIGHLOW) {
         if (_velas[i].low < _velas[indice].low) es_minimo = false;
         if (_velas[i].high > _velas[indice].high) es_maximo = false;
      }
      
      if (!es_maximo && !es_minimo) break;
   }
   
   if (es_maximo) return MAXIMO;
   if (es_minimo) return MINIMO;
   
   return NONE;
}

void ColaRelativos::reset() {
   ArrayResize(this.relativos, 0);
}

bool ColaRelativos::set_relativo(
   MqlRates &_velas[],
   int i,
   int profundidad,
   TipoBusqueda tipoBusqueda
) {
   TipoRelativo tipo = es_relativo(_velas, i, profundidad, tipoBusqueda);
   
   if (tipo != NONE && tipo != this.get_last_tipo()) {
      Relativo relativo;
      relativo.price = tipoBusqueda == CLOSE 
         ? _velas[i].close 
         : (
            tipo == MAXIMO ? _velas[i].high : _velas[i].low
         );
      relativo.time = _velas[i].time;
      relativo.tipo = tipo;
      this.add(relativo);
      return true;
   } else if (tipo == this.get_last_tipo()) {
      int num_relativos = ArraySize(this.relativos);
      Relativo last_relativo = this.get_last_relativo();
      
      bool es_mayor = (tipoBusqueda == HIGHLOW && _velas[i].high > last_relativo.price) ||
                      (tipoBusqueda == CLOSE && _velas[i].close > last_relativo.price);
      bool es_menor = (tipoBusqueda == HIGHLOW && _velas[i].low < last_relativo.price) ||
                      (tipoBusqueda == CLOSE && _velas[i].close < last_relativo.price);
      
      if (last_relativo.time != -1 && last_relativo.tipo == MAXIMO && es_mayor) {
         this.relativos[num_relativos-1].time = _velas[i].time;
         this.relativos[num_relativos-1].price = tipoBusqueda == CLOSE ? _velas[i].close : _velas[i].high;
      } else if (last_relativo.time != -1 && last_relativo.tipo == MINIMO && es_menor) {
         this.relativos[num_relativos-1].time = _velas[i].time;
         this.relativos[num_relativos-1].price = tipoBusqueda == CLOSE ? _velas[i].close : _velas[i].low;
      }
   }
   return false;
}


void ColaRelativos::buscar_relativos(
   int profundidad,
   int _num_relativos,
   string _symbol,
   ENUM_TIMEFRAMES _periodo,
   TipoBusqueda tipoBusqueda
) {
   int num_velas = VELAS_POR_RELATIVO*_num_relativos;
   MqlRates _velas[];
   CopyRates(_symbol, _periodo, 0, num_velas, _velas);
   
   for (int i = profundidad; i < num_velas-profundidad && ArraySize(this.relativos) < _num_relativos; i++) {
      this.set_relativo(_velas, i, profundidad, tipoBusqueda);
   }
}

void ColaRelativos::dibujar_lineas(
   string _symbol,
   ENUM_TIMEFRAMES _periodo
) {
   MqlRates _velas[];
   ArraySetAsSeries(_velas, true);
   CopyRates(_symbol, _periodo, 0, VELAS_POR_RELATIVO, _velas);
   
   int num_relativos = ArraySize(this.relativos);
   
   for (int i = 0; i < num_relativos-1; i++) {
      string name = IntegerToString(i)+"-"+IntegerToString(i+1)+"-Linea";
      ObjectCreate(
         0,
         name,
         OBJ_TREND,
         0,
         this.relativos[i].time,
         this.relativos[i].price,
         this.relativos[i+1].time,
         this.relativos[i+1].price
      );
      ObjectSetInteger(0, name, OBJPROP_COLOR, this.relativos[i+1].tipo == MINIMO ? clrGreen : clrRed);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 5);
   }
   string name = "Linea-precio";
   Relativo ultimo_relativo = this.get_last_relativo();
   double diff_precio = _velas[0].close-this.relativos[0].price;
   ObjectCreate(
      0,
      name,
      OBJ_TREND,
      0,
      ultimo_relativo.time,
      ultimo_relativo.price,
      _velas[0].time,
      _velas[0].close
   );
   ObjectSetInteger(0, name, OBJPROP_COLOR, diff_precio > 0 ? clrGreen : clrRed);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 5);
}

bool ColaRelativos::buscar_nuevos_relativos(
   int profundidad,
   string _symbol,
   ENUM_TIMEFRAMES _periodo,
   TipoBusqueda tipoBusqueda
) {
   Relativo ultimo_relativo = this.get_last_relativo();
   int _num_relativos = ArraySize(this.relativos);
   bool resultado = false;
   
   if (ultimo_relativo.time != -1) {
      MqlRates _velas[];
      CopyRates(_symbol, _periodo, ultimo_relativo.time-profundidad*PeriodSeconds(_periodo), TimeGMT(), _velas);
      int num_velas = ArraySize(_velas);
      
      if (num_velas >= profundidad*2+1) {
         for (int i = profundidad; i < num_velas-profundidad; i++) {
            if (this.set_relativo(_velas, i, profundidad, tipoBusqueda)) {
               resultado = true;
               this.pop();
            }
         }
      }
   }
   
   return resultado;
}

string ColaRelativos::recoger_datos(int num_relativos_a_guardar, int num_decimales) {
   string dato = "";
   int num_relativos = ArraySize(this.relativos);
   for (int i = num_relativos-1; i >= num_relativos-num_relativos_a_guardar; i--) {
      double diff_precio = 0;
      long diff_time = 0;
      diff_precio = this.relativos[i].price/this.relativos[i-1].price;
      diff_time = this.relativos[i].time-this.relativos[i-1].time;
      dato += DoubleToString(diff_precio, num_decimales)+
         ","+IntegerToString(diff_time)+
         (i == num_relativos-num_relativos_a_guardar ? "" : ",");
   }
   
   return dato;
}