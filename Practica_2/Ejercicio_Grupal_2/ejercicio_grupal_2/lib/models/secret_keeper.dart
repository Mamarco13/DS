abstract class SecretKeeper {
  String get secretWord;

  Future<String> ask(String userMessage);
}