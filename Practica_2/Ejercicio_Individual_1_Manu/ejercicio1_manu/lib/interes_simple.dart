import 'operacion_financiera.dart';

class InteresSimple extends OperacionFinanciera {
  InteresSimple({super.capital = 0.0, super.interes = 0.0, super.tiempo = 0.0});

  @override
  double operar() {
    return capital * interes * tiempo;
  }
}