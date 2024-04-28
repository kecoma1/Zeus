#include <Athena/File.mqh>
#include <NN.mqh>

input string FILENAME_DATOS = "zeus-init-normalizado.csv";
input string FILENAME_MODELO = "zeus.txt";
input int EPOCAS = 500;
input double UMBRAL = 0.9;

double sigmoide(double v) {
   return 1/(1+MathPow(2.71828, v*-1));
}

double derivada_sigmoide(double v) {
   return sigmoide(v)*(1-sigmoide(v));
}

int estructura[4] = {8, 64, 64, 2};

RedNeuronal rn(4, estructura, sigmoide, derivada_sigmoide, 1);

void OnInit() {
   matrix atributos = cargar_atributos_csv(FILENAME_DATOS, 2);
   matrix clases = cargar_clases_csv(FILENAME_DATOS, 2);
   Print(atributos);
   Print("-------- Entrenando la red neuronal -------- ");
   rn.entrenar(EPOCAS, atributos, clases);
   rn.guardar(FILENAME_MODELO, "8,64,64,2");
}