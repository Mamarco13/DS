import 'operacion_financiera.dart';
import 'interes_simple.dart';
import 'interes_compuesto.dart';
import 'amortizacion_mensual.dart';

class OperacionesFactory {
  OperacionFinanciera realizarOperacion(String tipoOperacion){
    switch(tipoOperacion){
      case 'interes_simple':
        return InteresSimple();
      case 'interes_compuesto':
        return InteresCompuesto();
      case 'amortizacion_mensual':
        return AmortizacionMensual();
      default:
        throw Exception('Tipo de operación no reconocido');
    }
  }
}