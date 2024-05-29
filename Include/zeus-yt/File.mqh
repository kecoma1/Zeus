int numero_lineas_csv(string filename) {
   int lineas = 0;
   int fh = FileOpen(filename, FILE_ANSI|FILE_COMMON|FILE_CSV|FILE_READ, "\n");
   
   while(!FileIsEnding(fh)) {
      FileReadString(fh);
      lineas++;
   }
   
   FileClose(fh);
   
   return lineas;
}

int numero_columnas_csv(string filename) {
   int fh = FileOpen(filename, FILE_ANSI|FILE_COMMON|FILE_CSV|FILE_READ, "\n");
   
   string linea = FileReadString(fh);
   
   string columnas[];
   StringSplit(linea, ',', columnas);
   
   FileClose(fh);
   
   return ArraySize(columnas);
}

matrix cargar_atributos_csv(string filename, int num_clases=1) {
   int num_columnas = numero_columnas_csv(filename);
   int num_lineas = numero_lineas_csv(filename);
   
   matrix atributos(num_lineas-1, num_columnas-num_clases);
   
   int fh = FileOpen(filename, FILE_ANSI|FILE_COMMON|FILE_CSV|FILE_READ, "\n");
   
   FileReadString(fh);
   
   int index = 0;
   while(!FileIsEnding(fh)) {
      vector atributos_linea(num_columnas-num_clases);
      
      string linea = FileReadString(fh);
      
      string datos[];
      StringSplit(linea, ',', datos);
      
      for (int i = 0; i < num_columnas-num_clases; i++)
         atributos_linea.Set(i, StringToDouble(datos[i]));
      
      atributos.Row(atributos_linea, index);
      index++;
   }
   FileClose(fh);
   
   return atributos;
}

matrix cargar_clases_csv(string filename, int num_clases=1) {
   int num_columnas = numero_columnas_csv(filename);
   int num_lineas = numero_lineas_csv(filename);
   
   matrix clases(num_lineas-1, num_clases);
   
   int fh = FileOpen(filename, FILE_ANSI|FILE_COMMON|FILE_CSV|FILE_READ, "\n");
   
   FileReadString(fh);
   
   int index = 0;
   while(!FileIsEnding(fh)) {
      vector clases_linea(num_clases);

      string linea = FileReadString(fh);

      string datos[];
      StringSplit(linea, ',', datos);

      for (int i = 0; i < num_clases; i++)
         clases_linea.Set(i, StringToDouble(datos[num_columnas-num_clases+i]));
      
      clases.Row(clases_linea, index);
      index++;
   }
   FileClose(fh);
   
   return clases;
}