import 'package:flutter_test/flutter_test.dart';

import 'package:salvacion_app/src/interpreter/filter_message.dart';
import 'package:salvacion_app/src/interpreter/filters/emphasis_filter.dart';
import 'package:salvacion_app/src/interpreter/word_entry.dart';

void main() {
  test('añade enfasis con asteriscos', () {
    final message = FilterMessage(entries: [
      WordEntry(
        palabra: 'hola',
        tipo: 'verbo',
        duracion: 3.0,
      ),
    ]);

    final filter = EmphasisFilter(tMinEnfasis: 2.0);

    filter.execute(message);

    expect(message.tokens.first.palabra, '*hola*');
  });
}