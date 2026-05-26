import '../filter.dart';
import '../filter_message.dart';
import '../interpreter_token.dart';

class PunctuationFilter implements Filter {
  @override
  void execute(FilterMessage message) {
    // SilenceFilter ya ha convertido "---" en "," o "."
    // Aquí solo manejamos interrogación y exclamación
    message.tokens = _handleSentenceMarkers(message.tokens);
  }

  List<InterpreterToken> _handleSentenceMarkers(List<InterpreterToken> tokens) {
    final List<InterpreterToken> result = [];
    final List<InterpreterToken> current = [];

    for (final token in tokens) {
      if (token.palabra == '.') {
        result.addAll(_processSubphrase(current));
        result.add(token);
        current.clear();
      } else {
        current.add(token);
      }
    }

    if (current.isNotEmpty) {
      result.addAll(_processSubphrase(current));
    }

    return result;
  }

  List<InterpreterToken> _processSubphrase(List<InterpreterToken> tokens) {
    if (tokens.isEmpty) return [];

    InterpreterToken _make(String palabra) =>
        InterpreterToken(palabra: palabra, tipo: 'otro', duracion: 0);

    // Detectar ?? (dos tokens consecutivos)
    if (
    tokens.length >= 2 &&
        tokens[tokens.length - 1].palabra == '?' &&
        tokens[tokens.length - 2].palabra == '?'
    ) {
      final body = tokens.sublist(0, tokens.length - 2);

      return [
        _make('¿'),
        ...body,
        _make('?'),
        _make('[doubt]')
      ];
    }

    final last = tokens.last.palabra;

    if (last == '?') {
      final body = tokens.sublist(0, tokens.length - 1);

      return [
        _make('¿'),
        ...body,
        _make('?')
      ];
    } else if (last == '!') {
      final body = tokens.sublist(0, tokens.length - 1);

      return [
        _make('¡'),
        ...body,
        _make('!')
      ];
    }

    return tokens;
  }
}
