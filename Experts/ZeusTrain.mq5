#include <Athena/File.mqh>
#include <NN.mqh>


input string FILENAME_DATOS = "zeus-init-normalizado.csv";
input string FILENAME_MODELO = "zeus.txt";
input int EPOCAS = 100;
input int ENTRADAS = 9;


double sigmoide(double v) {
   return 1/(1+MathPow(2.71828, v*-1));
}

double derivada_sigmoide(double v) {
   return sigmoide(v)*(1-sigmoide(v));
}

int estructura[4] = {ENTRADAS, 64, 64, 2};

RedNeuronal rn(4, estructura, sigmoide, derivada_sigmoide, 1);

void OnInit() {
   
   matrix atributos = cargar_atributos_csv(FILENAME_DATOS, 2);
   matrix clases = cargar_clases_csv(FILENAME_DATOS, 2);
   Print("-------- Entrenando la red neuronal de compra -------- ");
   rn.entrenar(EPOCAS, atributos, clases, true);
   rn.guardar(FILENAME_MODELO, ENTRADAS+",64,64,2");
}