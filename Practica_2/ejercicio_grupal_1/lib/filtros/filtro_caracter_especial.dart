import 'filtro.dart';

class FiltroCaracterEspecial implements IFiltro {
  @override
  String? filtrar(String email, String password) {
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return "Debe incluir un carácter especial";
    }
    return null;
  }
}