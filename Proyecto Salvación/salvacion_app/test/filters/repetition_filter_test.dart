import 'package:flutter_test/flutter_test.dart';

import 'package:salvacion_app/src/interpreter/filter_message.dart';
import 'package:salvacion_app/src/interpreter/filters/repetition_filter.dart';
import 'package:salvacion_app/src/interpreter/word_entry.dart';

void main() {
  test('verbo repetido dos veces añade [past]', () {
    final message = FilterMessage(entries: [
      WordEntry(
        palabra: 'comer',
        tipo: 'verbo',
        duracion: 1,
      ),
      WordEntry(
        palabra: 'comer',
        tipo: 'verbo',
        duracion: 1,
      ),
    ]);

    final filter = RepetitionFilter();

    filter.execute(message);

    expect(message.tokens.first.palabra.contains('[past]'), true);
    expect(message.tokens.length, 1);
  });
}