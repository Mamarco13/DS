import 'espectrograma.dart';

abstract class Comparador{
  double get umbral;
  bool comparar(Espectrograma e1, Espectrograma e2);
}

class ComparadorCoseno extends Comparador{
  @override
  double umbral =0.5;
  @override
  bool comparar(Espectrograma e1, Espectrograma e2){
    double similitud = e1.similitudCoseno(e2);
    print("Similitud: $similitud");
    return similitud > umbral;
  }
}