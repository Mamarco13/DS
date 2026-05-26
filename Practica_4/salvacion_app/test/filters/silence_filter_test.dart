import 'package:flutter_test/flutter_test.dart';

import 'package:salvacion_app/src/interpreter/filter_message.dart';
import 'package:salvacion_app/src/interpreter/filters/silence_filter.dart';
import 'package:salvacion_app/src/interpreter/word_entry.dart';

void main() {
  test('elimina silencios cortos', () {
    final message = FilterMessage(entries: [
      WordEntry(
        palabra: '---',
        tipo: 'otro',
        duracion: 1.0,
      ),
    ]);

    final filter = SilenceFilter(tMinSilencio: 2.0);

    filter.execute(message);

    expect(message.tokens.length, 0);
  });

  test('convierte silencio largo en coma', () {
    final message = FilterMessage(entries: [
      WordEntry(
        palabra: '---',
        tipo: 'otro',
        duracion: 2.5,
      ),
    ]);

    final filter = SilenceFilter(tMinSilencio: 2.0);

    filter.execute(message);

    expect(message.tokens.first.palabra, ',');
  });
}