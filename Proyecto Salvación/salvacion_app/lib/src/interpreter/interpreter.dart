import 'package:flutter/services.dart';
import 'word_entry.dart';
import 'filter_manager.dart';
import '../services/ollama_service.dart';

class Interpreter {
  final FilterManager _filterManager;
  final OllamaService _ollamaService;

  static const double tMinSilencio = 2.0;
  static const double tMinEnfasis  = 1.5;

  Interpreter()
      : _filterManager = FilterManager(
    tMinSilencio: tMinSilencio,
    tMinEnfasis: tMinEnfasis,
  ),
        _ollamaService = OllamaService();

  /// Punto de entrada principal.
  /// Recibe el JSON del Coordinador y devuelve la frase naturalizada.
  Future<InterpreterResult> traducir(List<dynamic> json) async {
    // 1. JSON → WordEntry
    final entries = WordEntry.fromJsonList(json);

    // 2. Aplicar filtros → string con etiquetas
    final (:result, :unknownWords) = _filterManager.process(entries);

    // 3. Cargar system prompt (sin {{FRASE}}, ya va separado como rol user)
    final systemPrompt = await _loadSystemPrompt();

    // 4. Enviar al LLM → frase naturalizada
    final fraseNaturalizada = await _ollamaService.naturalizar(
      systemPrompt: systemPrompt,
      frase: result,
    );

    return InterpreterResult(
      fraseFiltrada: result,
      fraseNaturalizada: fraseNaturalizada.trim(),
      unknownWords: unknownWords,
    );
  }

  Future<String> _loadSystemPrompt() async {
    // prompt.txt ya NO debe contener "Entrada: {{FRASE}}" al final.
    // La frase se envía como mensaje de rol "user" directamente.
    return await rootBundle.loadString('assets/prompt.txt');
  }
}

/// Resultado que el Intérprete devuelve al Coordinador.
class InterpreterResult {
  /// Frase final en español natural, lista para mostrar al cliente.
  final String fraseNaturalizada;
  /// Frase filtrada
  final String fraseFiltrada;

  /// Palabras sin traducción en la BD.
  /// El Coordinador decide cómo notificarlo al cliente.
  final List<String> unknownWords;

  InterpreterResult({
    required this.fraseFiltrada,
    required this.fraseNaturalizada,
    required this.unknownWords,
  });
}