import 'ServicioTuristico.dart';
import 'PoliticaVuelo/PoliticaVuelo.dart';

class Vuelo implements ServicioTuristico {
  final String id;
  final double precioBase;
  final PoliticaVuelo politica;

  Vuelo({
    required this.id,
    required this.precioBase,
    required this.politica,
  }) {
    if (precioBase < 0) {
      throw Exception('El precio base no puede ser negativo');
    }
  }

  @override
  double getPrecio() => politica.calcular(precioBase);
}
