import 'ServicioTuristico.dart';
import 'PoliticaHotel/PoliticaHotel.dart';

class Hotel implements ServicioTuristico {
  final String nombre;
  final double precioNoche;
  final int noches;
  final PoliticaHotel politica;

  Hotel({
    required this.nombre,
    required this.precioNoche,
    required this.noches,
    required this.politica,
  });

  @override
  double getPrecio() {
    return politica.calcular(this.precioNoche, this.noches);
  }
}
