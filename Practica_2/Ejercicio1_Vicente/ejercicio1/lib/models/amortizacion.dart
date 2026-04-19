import 'dart:math';
import 'operacion_financiera.dart';

class Amortizacion extends OperacionFinanciera {

  Amortizacion({required double C, required double i, required double t}) : super(C: C, i: i, t: t);

  @override
  double calcular() {
    
    //Evitamos division por 0, si i = 0, el denominador se vuelve 0, da infinito compae
    return C * (i * pow(1 + i, t)) / (pow(1 + i, t) - 1);
  }
}