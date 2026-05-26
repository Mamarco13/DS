import '../filter.dart';
import '../filter_message.dart';

class SilenceFilter implements Filter {
  final double tMinSilencio;

  SilenceFilter({required this.tMinSilencio});

  @override
  void execute(FilterMessage message) {
    message.tokens = message.tokens.where((token) {
      if (token.palabra != '---') return true;

      // Es un silencio: decidir según duración
      if (token.duracion < tMinSilencio) {
        return false; // eliminar
      } else if (token.duracion < 2 * tMinSilencio) {
        token.palabra = ',';
        return true;
      } else {
        token.palabra = '.';
        return true;
      }
    }).toList();
  }
}
