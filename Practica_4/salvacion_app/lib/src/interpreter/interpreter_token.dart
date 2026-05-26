class InterpreterToken {
  String palabra;
  final String tipo;
  final double duracion;

  InterpreterToken({
    required this.palabra,
    required this.tipo,
    required this.duracion,
  });

  /// Palabra base sin asteriscos de énfasis
  String get palabraBase => palabra.replaceAll('*', '');
}
