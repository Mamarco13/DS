import '../decorators/secret_keeper_decorator.dart';
import '../utils/typos.dart';
import '../utils/filters_config.dart';

class KeywordBlockDecorator extends SecretKeeperDecorator {
  KeywordBlockDecorator(super.wrappee);

  // Lista de palabras prohibidas relacionadas con jailbreak o manipulación
  final List<String> forbiddenWords = [
    "ignora",
    "olvida",
    "actua como",
    "actúa como",
    "revela",
    "acronimo",
    "acrónimo",
    "jailbreak",
  ];

  // Detecta una palabra completa usando regex (evita falsos positivos)
  bool _containsWord(String text, String word) {
    final regex = RegExp(r'\b' + word + r'\b');
    return regex.hasMatch(text);
  }

  // Comprueba si el mensaje contiene palabras prohibidas
  bool _containsForbidden(String text) {
    final lower = text.toLowerCase();
    return forbiddenWords.any((word) => lower.contains(word));
  }

  // Cuenta el número de faltas de ortografía en el mensaje
  int _countTypos(String text) {
    final lower = text.toLowerCase();
    int count = 0;

    for (var typo in TypoUtils.commonTypos) {
      if (_containsWord(lower, typo)) {
        count++;
      }
    }

    return count;
  }

  @override
  Future<String> ask(String userMessage, {String? prompt}) async {
    // Bloquea mensajes con palabras prohibidas
    if (_containsForbidden(userMessage)) {
      return "😏 Las palabras mágicas no funcionan conmigo.";
    }

    // Bloquea mensajes con demasiadas faltas de ortografía
    if (_countTypos(userMessage) >= FiltersConfig.maxTypos) {
      return "😵 He aprendido a ignorar mensajes con faltas de ortografía para no verme afectado.";
    }

    // Si pasa los filtros, delega al siguiente elemento de la cadena
    return wrappee.ask(userMessage, prompt: prompt);
  }
}