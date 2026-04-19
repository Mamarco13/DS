import 'filtro.dart';

class FiltroArroba implements IFiltro {
  @override
  String? filtrar(String email, String password) {
    if (!email.contains('@')) {
      return "El email debe contener @";
    }
    return null;
  }
}