import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiService {
  final Gemini _gemini;

  // 🔹 Separación entre el prompt y el historial
  final List<Part> _system = [];
  final List<Part> _history = [];

  GeminiService(String apiKey)
      : _gemini = Gemini.init(apiKey: apiKey);

  Future<String> sendMessage(String message) async {
    try {
      // Añadir mensaje del usuario
      _history.add(Part.text("Usuario: $message"));

      // Limitar historial (solo la conversación)
      if (_history.length > 10) {
        _history.removeRange(0, 2);
      }

      final response = await _gemini.prompt(
        parts: [..._system, ..._history],
      );

      if (response?.output != null) {
        final output = response!.output!;

        // Guardar respuesta del bot
        _history.add(Part.text("Guardián: $output"));

        return output;

      } else {
        return "No response from Gemini.";
      }

    } catch (e) {
      return "⏳ Estoy un poco saturado ahora mismo... inténtalo en unos segundos.";
    }
  }

  // 🔹 Prompt del sistema separado
  Future<void> setSystemPrompt(String prompt) async {
    _system.clear();
    _system.add(Part.text(prompt));
  }
}



//*/

/* PROPUESTA DE MANU
class GeminiService {
  final Gemini _gemini;

  GeminiService(String apiKey)
      : _gemini = Gemini.init(apiKey: apiKey);

  Future<String> sendMessage(String message) async {
    try {
      final response = await _gemini.prompt(
        parts: [Part.text(message)],
      );

      if (response?.output != null) {
        return response!.output!;
      } else {
        return "No response from Gemini.";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
// */