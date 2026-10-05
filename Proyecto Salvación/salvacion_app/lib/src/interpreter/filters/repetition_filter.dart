import '../filter.dart';
import '../filter_message.dart';
import '../interpreter_token.dart';

class RepetitionFilter implements Filter {
  @override
  void execute(FilterMessage message) {
    final List<InterpreterToken> input = message.tokens;
    final List<InterpreterToken> result = [];

    int i = 0;
    while (i < input.length) {
      final InterpreterToken current = input[i];

      // Silencios y otros: pasar directamente
      if (current.tipo == 'otro') {
        result.add(current);
        i++;
        continue;
      }

      // Contar repeticiones inmediatas: misma palabraBase y mismo tipo
      final String baseWord = current.palabraBase;
      int count = 1;
      while (
      i + count < input.length &&
          input[i + count].palabraBase == baseWord &&
          input[i + count].tipo == current.tipo
      ) {
        count++;
      }

      // Si se repite más de 3 veces, dejar todo tal como está
      if (count > 3) {
        for (int j = i; j < i + count; j++) {
          result.add(input[j]);
        }
        i += count;
        continue;
      }

      // El token que usamos es el primero (puede tener * de énfasis)
      final InterpreterToken first = input[i];

      switch (current.tipo) {
        case 'verbo':
          if (count == 1) {
            first.palabra = '${first.palabra} [base]';
          } else if (count == 2) {
            first.palabra = '${first.palabra} [past]';
          } else if (count == 3) {
            first.palabra = '${first.palabra} [future]';
          }
          result.add(first);
          break;

        case 'adjetivo':
        case 'adverbio':
          if (count == 1) {
            // sin etiqueta
          } else if (count == 2) {
            first.palabra = '${first.palabra} [intensity 1]';
          } else if (count == 3) {
            first.palabra = '${first.palabra} [intensity 2]';
          }
          result.add(first);
          break;

        case 'sustantivo':
          if (count >= 2) {
            first.palabra = '${first.palabra} [many]';
          }
          result.add(first);
          break;

        case 'pronombre':
          if (count == 1) {
            result.add(first);
          } else {
            // Sustituir por token posesivo usando palabraBase original
            first.palabra = '[posesivo:$baseWord]';
            result.add(first);
          }
          break;

        default:
          result.add(first);
          break;
      }

      i += count;
    }

    message.tokens = result;
  }
}
