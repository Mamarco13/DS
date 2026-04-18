import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService(String apiKey, String systemPrompt){
    _model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: apiKey
    );

    _chat = _model.startChat(
      history: [
        Content.text(systemPrompt),
      ],
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(
          Content.text(message),
      );

      return response.text ?? "Sin respuesta";
    } catch (e) {
      //return "Error: $e";
      return "⏳ Estoy un poco saturado ahora mismo...";
    }
  }
}