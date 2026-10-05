import '../filter.dart';
import '../filter_message.dart';

class EmphasisFilter implements Filter {
  final double tMinEnfasis;

  EmphasisFilter({required this.tMinEnfasis});

  @override
  void execute(FilterMessage message) {
    for (final token in message.tokens) {
      if (token.tipo == 'otro') continue;
      if (token.duracion > tMinEnfasis) {
        token.palabra = '*${token.palabra}*';
      }
    }
  }
}

