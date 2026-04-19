import '../filtros/filtro.dart';
import 'resultado_filtro.dart';

class CadenaFiltros {
  final List<IFiltro> filtros = [];

  void agregarFiltro(IFiltro filtro) {
    filtros.add(filtro);
  }

  ResultadoFiltro ejecutar(String email, String password) {
    for (var filtro in filtros) {
      final error = filtro.filtrar(email, password);
      if (error != null) {
        return ResultadoFiltro.rechazado(
          filtro: filtro.runtimeType.toString(),
          mensaje: error,
        );
      }
    }
    return const ResultadoFiltro.ok();
  }
}