class TypoUtils {
  // Lista de palabras comúnmente mal escritas que se usarán para detectar faltas de ortografía

  static const List<String> commonTypos = [
    // básicos
    "haver", "aver",

    // abreviaciones informales
    "k", "ke", "q", "xq", "pq",

    // errores ortográficos frecuentes
    "ola", "vien", "ez", "eske", "toy", "toi",
    "tamos", "taba", "abia", "avia",
    "bamo", "acer", "aser",
    "hechar",

    // ausencia de acentos
    "mas",

    // confusiones comunes
    "hayga", "dijistes", "fuistes", "vinistes", "haiga",

    // lenguaje de chat
    "plis", "porfa", "xfa", "dnd", "tb", "tmb", "bn", "weno",
  ];
}