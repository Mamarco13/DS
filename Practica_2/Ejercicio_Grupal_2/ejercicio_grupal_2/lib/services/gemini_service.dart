import 'package:flutter_gemini/flutter_gemini.dart';

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
      return "⏳ Estoy un poco saturado ahora mismo... inténtalo en unos segundos.";
    }
  }
}



/*

import 'package:flutter_gemini/flutter_gemini.dart';

// PROPUESTA DE ANA: la IA mantiene un historial con el usuario
class GeminiService {
  final Gemini _gemini;

  final List<Part> _history = [];

  GeminiService(String apiKey)
      : _gemini = Gemini.init(apiKey: apiKey);

  Future<String> sendMessage(String message) async {
    try {
      _history.add(Part.text(message));

      final response = await _gemini.prompt(
        parts: _history,
      );

      if (response?.output != null) {
        _history.add(Part.text(response!.output!));
        return response.output!;
      } else {
        return "No response from Gemini.";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<void> setSystemPrompt(String prompt) async {
    _history.add(Part.text(prompt));
  }
}

*/