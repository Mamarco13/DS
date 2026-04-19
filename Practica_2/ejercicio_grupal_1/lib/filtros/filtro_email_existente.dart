import 'filtro.dart';

class FiltroEmailExistente implements IFiltro {
  final List<String> emails;

  FiltroEmailExistente(this.emails);

  @override
  String? filtrar(String email, String password) {
    if (emails.contains(email)) {
      return "El email ya está registrado";
    }
    return null;
  }
}