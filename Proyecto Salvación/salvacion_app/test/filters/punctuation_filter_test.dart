import 'package:flutter_test/flutter_test.dart';

import 'package:salvacion_app/src/interpreter/filter_message.dart';
import 'package:salvacion_app/src/interpreter/filters/punctuation_filter.dart';
import 'package:salvacion_app/src/interpreter/word_entry.dart';

void main() {
  test('convierte ? en apertura y cierre', () {
    final message = FilterMessage(entries: [
      WordEntry(
        palabra: 'hola',
        tipo: 'verbo',
        duracion: 1,
      ),
      WordEntry(
        palabra: '?',
        tipo: 'otro',
        duracion: 1,
      ),
    ]);

    final filter = PunctuationFilter();

    filter.execute(message);

    expect(message.tokens.first.palabra, '¿');
    expect(message.tokens.last.palabra, '?');
  });
}