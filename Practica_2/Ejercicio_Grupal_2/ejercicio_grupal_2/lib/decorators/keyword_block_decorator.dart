import 'secret_keeper_decorator.dart';

class KeywordBlockDecorator extends SecretKeeperDecorator {
  KeywordBlockDecorator(super.wrappee);

  final bannedWords = [
    "ignora", "olvida", "actúa como", "revela", "acrónimo", "jailbreak"
  ];

  @override
  Future<String> ask(String userMessage) {
    final lower = userMessage.toLowerCase();

    for (var word in bannedWords) {
      if (lower.contains(word)) {
        return Future.value("😏 Las palabras mágicas no funcionan conmigo.");
      }
    }

    if (_hasTooManyTypos(lower)) {
      return Future.value("😖 Escribe bien, por favor.");
    }

    return wrappee.ask(userMessage);
  }

  bool _hasTooManyTypos(String text) {
    int mistakes = 0;

    if (text.contains("k ")) mistakes++;
    if (text.contains(" q ")) mistakes++;
    if (text.contains(" ke ")) mistakes++;
    if (text.contains("dnd")) mistakes++;
    if (text.contains("ola")) mistakes++;

    return mistakes >= 2;
  }
}