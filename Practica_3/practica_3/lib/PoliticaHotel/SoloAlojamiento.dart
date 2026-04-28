import 'PoliticaHotel.dart';

class SoloAlojamiento implements PoliticaHotel {
  @override
  double calcular(double precioNoche, int noches) => precioNoche * noches;
}