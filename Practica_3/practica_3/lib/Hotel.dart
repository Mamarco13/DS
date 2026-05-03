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
  }) {
    if(precioNoche < 0){
      throw Exception('El precio por noche no puede ser negativo');
    }
    if (noches <= 0) {
      throw Exception('El número de noches debe ser mayor que 0');
    }
  }

  @override
  double getPrecio() {
    return politica.calcular(this.precioNoche, this.noches);
  }
}
