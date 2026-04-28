import 'PoliticaVuelo.dart';

class TarifaLowCost implements PoliticaVuelo {
  static const double _RECARGO = 20.0;

  @override
  double calcular(double base) => base + _RECARGO;
}