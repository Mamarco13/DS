class WordEntry {
  final String palabra;
  final String tipo;
  final double duracion;

  WordEntry({
    required this.palabra,
    required this.tipo,
    required this.duracion,
  });

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      palabra: json['palabra'] as String,
      tipo: json['tipo'] as String,
      duracion: (json['duracion'] as num).toDouble(),
    );
  }

  static List<WordEntry> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => WordEntry.fromJson(e)).toList();
  }
}
