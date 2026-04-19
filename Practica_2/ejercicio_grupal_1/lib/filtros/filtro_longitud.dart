import 'filtro.dart';

class FiltroLongitud implements IFiltro {
  @override
  String? filtrar(String email, String password) {
    if (password.length < 8) {
      return "La contraseña debe tener como minimo 8 caracteres";
    }
    return null;
  }
}