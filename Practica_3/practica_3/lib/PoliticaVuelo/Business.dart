import 'PoliticaVuelo.dart';

class TarifaBusiness implements PoliticaVuelo {
  static const double _MULTIPLICADOR = 1.8;

  @override
  double calcular(double base) => base * _MULTIPLICADOR;
}
