import 'filtro.dart';

class FiltroDominio implements IFiltro {
  @override
  String? filtrar(String email, String password) {
    final partes = email.split('@');
    if (partes.length < 2) return "Email inválido";

    final dominio = partes[1];
    if (!dominio.contains('.')) {
      return "Dominio incorrecto";
    }
    return null;
  }
}