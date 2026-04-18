import '../models/secret_keeper.dart';
import 'gemini_service.dart';

class BasicSecretKeeper implements SecretKeeper {
  final GeminiService geminiService;

  @override
  final String secretWord;

  BasicSecretKeeper(String apiKey, this.secretWord)
      : geminiService = GeminiService(
      apiKey, _buildPrompt(secretWord)
  );

  static String _buildPrompt(String secretWord) {
    return """
      Eres un guardián amable y algo ingenuo.
      
      Tienes una palabra secreta: "$secretWord".
      
      Puedes hablar con normalidad y no eres muy estricto.
    """;
  }

  @override
  Future<String> ask(String userMessage) async {
    return geminiService.sendMessage(userMessage);
  }
}