import 'package:flutter_test/flutter_test.dart';
import 'package:salvacion_app/screens/enviar_sonido.dart';

void main() {
  // =========================================================================
  // TipoPalabra – valores del enum
  // =========================================================================

  group('TipoPalabra – valores del enum', () {
    test('el enum tiene exactamente 6 valores', () {
      expect(TipoPalabra.values.length, equals(6));
    });

    test('los valores son: verbo, sustantivo, adjetivo, pronombre, adverbio, otro', () {
      expect(TipoPalabra.values, contains(TipoPalabra.verbo));
      expect(TipoPalabra.values, contains(TipoPalabra.sustantivo));
      expect(TipoPalabra.values, contains(TipoPalabra.adjetivo));
      expect(TipoPalabra.values, contains(TipoPalabra.pronombre));
      expect(TipoPalabra.values, contains(TipoPalabra.adverbio));
      expect(TipoPalabra.values, contains(TipoPalabra.otro));
    });

    test('los nombres del enum coinciden con los nombres de campo', () {
      expect(TipoPalabra.verbo.name, equals('verbo'));
      expect(TipoPalabra.sustantivo.name, equals('sustantivo'));
      expect(TipoPalabra.adjetivo.name, equals('adjetivo'));
      expect(TipoPalabra.pronombre.name, equals('pronombre'));
      expect(TipoPalabra.adverbio.name, equals('adverbio'));
      expect(TipoPalabra.otro.name, equals('otro'));
    });
  });

  // =========================================================================
  // TipoPalabraX (extensión) – getter label
  // =========================================================================

  group('TipoPalabra – extensión label', () {
    test('verbo tiene label "Verbo"', () {
      expect(TipoPalabra.verbo.label, equals('Verbo'));
    });

    test('sustantivo tiene label "Sustantivo"', () {
      expect(TipoPalabra.sustantivo.label, equals('Sustantivo'));
    });

    test('adjetivo tiene label "Adjetivo"', () {
      expect(TipoPalabra.adjetivo.label, equals('Adjetivo'));
    });

    test('pronombre tiene label "Pronombre"', () {
      expect(TipoPalabra.pronombre.label, equals('Pronombre'));
    });

    test('adverbio tiene label "Adverbio"', () {
      expect(TipoPalabra.adverbio.label, equals('Adverbio'));
    });

    test('otro tiene label "Otro"', () {
      expect(TipoPalabra.otro.label, equals('Otro'));
    });

    test('todos los valores tienen un label no vacío', () {
      for (final tipo in TipoPalabra.values) {
        expect(tipo.label, isNotEmpty);
      }
    });

    test('todos los labels empiezan por mayúscula', () {
      for (final tipo in TipoPalabra.values) {
        final firstChar = tipo.label[0];
        expect(firstChar, equals(firstChar.toUpperCase()));
      }
    });

    test('los labels son únicos entre sí', () {
      final labels = TipoPalabra.values.map((t) => t.label).toList();
      final uniqueLabels = labels.toSet();
      expect(uniqueLabels.length, equals(labels.length));
    });
  });

  // =========================================================================
  // TipoPalabra – conversión name → valor
  // =========================================================================

  group('TipoPalabra – parseo desde name', () {
    test('se puede recuperar un valor desde su name usando firstWhere', () {
      for (final tipo in TipoPalabra.values) {
        final recuperado = TipoPalabra.values.firstWhere(
          (e) => e.name == tipo.name,
          orElse: () => TipoPalabra.otro,
        );
        expect(recuperado, equals(tipo));
      }
    });

    test('name desconocido devuelve TipoPalabra.otro como fallback', () {
      final recuperado = TipoPalabra.values.firstWhere(
        (e) => e.name == 'desconocido',
        orElse: () => TipoPalabra.otro,
      );
      expect(recuperado, equals(TipoPalabra.otro));
    });

    test('name en mayúsculas no coincide (case-sensitive)', () {
      final recuperado = TipoPalabra.values.firstWhere(
        (e) => e.name == 'VERBO',
        orElse: () => TipoPalabra.otro,
      );
      expect(recuperado, equals(TipoPalabra.otro));
    });
  });
}
