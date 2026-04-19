import 'operacion_financiera.dart';
import 'dart:math';

class AmortizacionMensual extends OperacionFinanciera {
  AmortizacionMensual({super.capital = 0.0, super.interes = 0.0, super.tiempo = 0.0});

  @override
  double operar() {
    double numerador = interes * pow(1 + interes, tiempo);
    double denominador = (pow(1 + interes, tiempo))-1;
    return numerador/denominador;
  }
}