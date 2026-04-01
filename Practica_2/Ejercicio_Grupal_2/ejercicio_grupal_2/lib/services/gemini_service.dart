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
      return "Error: $e";
    }
  }
}