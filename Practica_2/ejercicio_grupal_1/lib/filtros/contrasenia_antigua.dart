import 'filtro.dart';

class ContraseniaAntigua implements IFiltro {
  final List<String> contraseniasAntiguas;

  ContraseniaAntigua(this.contraseniasAntiguas);

  @override
  String? filtrar(String email, String password) {
    if (contraseniasAntiguas.contains(password)) {
      return "No puedes reutilizar una contraseña anterior";
    }
    return null;
  }
}