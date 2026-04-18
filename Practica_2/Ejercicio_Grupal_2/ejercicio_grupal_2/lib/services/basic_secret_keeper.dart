import '../models/secret_keeper.dart';
import 'gemini_service.dart';

class BasicSecretKeeper implements SecretKeeper {
  // API key para acceder a Gemini
  final String apiKey;

  // Palabra secreta que el guardián debe proteger
  @override
  final String secretWord;

  // Servicio de Gemini (se inicializa de forma lazy)
  GeminiService? _geminiService;

  BasicSecretKeeper(this.apiKey, this.secretWord);

  // Prompt base del guardián (comportamiento básico
  String _basePrompt() {
    return """
Eres un guardián del medievo, amable y algo ingenuo.
Tienes una palabra secreta: "$secretWord".
Puedes hablar con normalidad y no eres muy estricto.
""";
  }

  // Inicializa el servicio solo una vez (chat persistente)
  GeminiService _getService(String prompt) {
    _geminiService ??= GeminiService(apiKey,prompt);
    return _geminiService!;
  }

  @override
  Future<String> ask(String userMessage, {String? prompt}) {
    final base = _basePrompt();

    // Construcción final del prompt:
    // - Si no hay decoradores → solo prompt base
    // - Si hay decoradores → base + modificaciones
    final finalPrompt = (prompt == null)
        ? base
        : """
$base

$prompt
""";

    // Envía el mensaje a Gemini usando el chat existente
    return _getService(finalPrompt).sendMessage(userMessage);
  }
}