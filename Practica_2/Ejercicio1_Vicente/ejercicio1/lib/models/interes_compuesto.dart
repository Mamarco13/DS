import 'operacion_financiera.dart';
import 'dart:math';

class InteresCompuesto extends OperacionFinanciera {

  InteresCompuesto({required double C, required double i, required double t}) : super(C: C, i: i, t: t);

  @override
  double calcular() {
    return C * (pow(1 + i, t) - 1);
  }
}