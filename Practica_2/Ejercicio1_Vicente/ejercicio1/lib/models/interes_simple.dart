import 'operacion_financiera.dart';
class InteresSimple extends OperacionFinanciera {

  InteresSimple({required double C, required double i, required double t}) : super(C: C, i: i, t: t);


  @override
  double calcular() {
    return C * i * t;
  }
}
