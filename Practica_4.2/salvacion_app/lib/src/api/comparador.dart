import 'espectrograma.dart';

abstract class Comparador{
  double get umbral;
  double similitud(Espectrograma e1, Espectrograma e2);
  bool comparar(Espectrograma e1, Espectrograma e2);
}

class ComparadorCoseno extends Comparador{
  @override
  double umbral =0.6;
  @override
  double similitud(Espectrograma e1, Espectrograma e2){
    return e1.similitudCoseno(e2);
  }
  @override
  bool comparar(Espectrograma e1, Espectrograma e2){
    double similitud = this.similitud(e1, e2);
    return similitud > umbral;
  }
}
class ComparadorMFCC extends Comparador{
  @override
  double umbral =0.7;
  @override
  double similitud(Espectrograma e1, Espectrograma e2){
    return e1.similitudMfcc(e2);
  }
  @override
  bool comparar(Espectrograma e1, Espectrograma e2){
    double similitud = this.similitud(e1, e2);
    return similitud > umbral;
  }
}