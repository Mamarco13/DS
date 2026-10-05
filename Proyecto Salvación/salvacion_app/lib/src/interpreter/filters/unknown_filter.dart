import '../filter.dart';
import '../filter_message.dart';

class UnknownFilter implements Filter {
  @override
  void execute(FilterMessage message) {
    for (final token in message.tokens) {
      if (token.palabra == 'unknown') {
        message.unknownWords.add(token.palabraBase);
        token.palabra = '[unknown]';
      }
    }
  }
}
