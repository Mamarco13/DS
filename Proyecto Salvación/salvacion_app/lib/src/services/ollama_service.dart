import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  static const String _baseUrl = 'http://localhost:11434';
  static const String _model = 'qwen2.5:14b';

  /// Envía un system prompt y una frase al LLM y devuelve la respuesta naturalizada.
  Future<String> naturalizar({
    required String systemPrompt,
    required String frase,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user',   'content': frase},
        ],
        'stream': false,
        'options': {'temperature': 0.0},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error conectando con Ollama: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return data['message']['content'] as String;
  }
}
