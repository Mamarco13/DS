import 'interpreter_token.dart';
import 'word_entry.dart';

class FilterMessage {
  List<InterpreterToken> tokens;
  List<String> unknownWords;

  FilterMessage({required List<WordEntry> entries})
      : tokens = entries
      .map((e) => InterpreterToken(
    palabra: e.palabra,
    tipo: e.tipo,
    duracion: e.duracion,
  ))
      .toList(),
        unknownWords = [];

  /// Resultado final como string
  String get result => tokens.map((t) => t.palabra).join(' ');
}
