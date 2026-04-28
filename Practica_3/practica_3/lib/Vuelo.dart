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
  });

  @override
  double getPrecio() => politica.calcular(precioBase);
}