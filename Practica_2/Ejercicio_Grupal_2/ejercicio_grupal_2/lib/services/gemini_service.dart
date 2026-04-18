import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;   // modelo de gemini: gemini-2.5-flash
  late final ChatSession _chat;

  GeminiService(String apiKey, String systemPrompt){
    // Inicializa el modelo con la API key
    _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey
    );

    // Crea el chat con el prompt inicial (configuración del comportamiento)
    _chat = _model.startChat(
      history: [
        Content.text(systemPrompt),
      ],
    );
  }

  // Envía un mensaje al modelo y devuelve la respuesta
  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(
          Content.text(message),
      );

      // Devuelve el texto generador o un mensaje por defecto
      return response.text ?? "Sin respuesta";
    } catch (e) {
      // Manejo de errores: mensaje más amigable para el usuario
      return "⏳ Estoy un poco saturado ahora mismo...";
    }
  }
}