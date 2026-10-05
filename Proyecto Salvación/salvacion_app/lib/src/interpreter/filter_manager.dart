import 'filter.dart';
import 'filter_chain.dart';
import 'filter_message.dart';
import 'word_entry.dart';
import 'filters/silence_filter.dart';
import 'filters/unknown_filter.dart';
import 'filters/emphasis_filter.dart';
import 'filters/repetition_filter.dart';
import 'filters/punctuation_filter.dart';

class FilterManager {
  final FilterChain _filterChain = FilterChain();

  FilterManager({
    double tMinSilencio = 2.0,
    double tMinEnfasis = 2.0,
  }) {
    // Orden: silencio → unknown → énfasis → repetición → puntuación
    _filterChain.addFilter(SilenceFilter(tMinSilencio: tMinSilencio));
    _filterChain.addFilter(UnknownFilter());
    _filterChain.addFilter(EmphasisFilter(tMinEnfasis: tMinEnfasis));
    _filterChain.addFilter(RepetitionFilter());
    _filterChain.addFilter(PunctuationFilter());
  }

  void addFilter(Filter filter) {
    _filterChain.addFilter(filter);
  }

  /// Procesa una lista de WordEntry y devuelve el string listo para el LLM.
  /// Si hay palabras desconocidas, las devuelve en [unknownWords].
  ({String result, List<String> unknownWords}) process(List<WordEntry> entries) {
    final message = FilterMessage(entries: entries);
    _filterChain.execute(message);
    return (result: message.result, unknownWords: message.unknownWords);
  }
}
