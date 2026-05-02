import 'PoliticaHotel.dart';

class TodoIncluido implements PoliticaHotel {
  static const double _SUPLEMENTO = 50.0;

  @override
  double calcular(double precioNoche, int noches) =>
      (precioNoche + _SUPLEMENTO) * noches;
}
