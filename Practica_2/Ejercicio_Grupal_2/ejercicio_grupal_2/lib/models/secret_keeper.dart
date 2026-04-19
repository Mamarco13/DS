abstract class SecretKeeper {
  // Palabra secreta que el guardián debe proteger
  String get secretWord;

  // Método principal de interacción con el guardián
  // - userMessage: mensaje del usuario
  // - prompt: se utiliza internamente para construir el comportamiento mediante decoradores
  Future<String> ask(String userMessage, {String? prompt});
}