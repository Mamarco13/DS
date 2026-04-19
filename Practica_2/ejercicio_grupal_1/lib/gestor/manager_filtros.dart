
import '../filtros/filtro_arroba.dart';
import '../filtros/filtro_dominio.dart';
import '../filtros/filtro_longitud.dart';
import '../filtros/filtro_caracter_especial.dart';
import '../filtros/filtro_email_existente.dart';
import '../filtros/contrasenia_antigua.dart';
import 'cadena_filtros.dart';
import 'resultado_filtro.dart';
import 'target.dart';

class ManagerFiltros {
  final CadenaFiltros cadena = CadenaFiltros();
  final Target target = Target();

  void inicializar(List<String> emails, List<String> contrasenias) {
    cadena.agregarFiltro(FiltroArroba());
    cadena.agregarFiltro(FiltroDominio());
    cadena.agregarFiltro(FiltroEmailExistente(emails));

    cadena.agregarFiltro(FiltroLongitud());
    cadena.agregarFiltro(FiltroCaracterEspecial());
    cadena.agregarFiltro(ContraseniaAntigua(contrasenias));
  }

  ResultadoFiltro ejecutar(String email, String password) {
    final resultado = cadena.ejecutar(email, password);
    if (resultado.esValido) {
      target.ejecutar(email);
    }
    return resultado;
  }
}