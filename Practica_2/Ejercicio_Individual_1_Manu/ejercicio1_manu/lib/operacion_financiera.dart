abstract class OperacionFinanciera{
  double capital;
  double interes;
  double tiempo;

  OperacionFinanciera({this.capital=0.0, this.interes=0.0, this.tiempo=0.0});
  double operar();
}