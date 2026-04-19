import 'package:ejercicio1/models/amortizacion.dart';
import 'package:ejercicio1/models/interes_compuesto.dart';
import 'package:ejercicio1/models/interes_simple.dart';
import 'package:ejercicio1/models/operacion_financiera.dart';

class FactoriaOperacion {
  static OperacionFinanciera crearOperacion(String tipo, double C, double i, double t) {
    switch (tipo) {
      case 'interes simple':
        return InteresSimple(C: C, i: i, t: t);
      case 'interes compuesto':
        return InteresCompuesto(C: C, i: i, t: t);
      case 'amortizacion':
        return Amortizacion(C: C, i: i, t: t);
      default:
        throw ArgumentError('Te has equivocado de operacion jambo, parguelas: $tipo');
    }
  }
}