abstract class OperacionFinanciera {

  double C, i, t;

  OperacionFinanciera({
    required this.C,
    required this.i,
    required this.t
  });
  double calcular();
}