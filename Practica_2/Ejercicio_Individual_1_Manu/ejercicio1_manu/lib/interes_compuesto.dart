import 'dart:math';
import 'operacion_financiera.dart';

class InteresCompuesto extends OperacionFinanciera {
  InteresCompuesto({super.capital = 0.0, super.interes = 0.0, super.tiempo = 0.0});

  @override
  double operar() {
    return capital * pow(1 + interes, tiempo);
  }
}