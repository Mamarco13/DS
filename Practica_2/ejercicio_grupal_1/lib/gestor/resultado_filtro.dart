class ResultadoFiltro {
  final bool esValido;
  final String? filtroRechazado;
  final String? error;

  const ResultadoFiltro.ok()
      : esValido = true,
        filtroRechazado = null,
        error = null;

  const ResultadoFiltro.rechazado({
    required String filtro,
    required String mensaje,
  })  : esValido = false,
        filtroRechazado = filtro,
        error = mensaje;
}
