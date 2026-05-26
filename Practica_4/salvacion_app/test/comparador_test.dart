import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:salvacion_app/src/api/comparador.dart';
import 'package:salvacion_app/src/api/espectrograma.dart';

Espectrograma _makeConst(int nFrames, int bins, double value) {
  final frames = List.generate(
    nFrames,
    (_) => Float64List.fromList(List.filled(bins, value)),
  );
  return Espectrograma(frames: frames);
}

/// Espectrograma con señal tipo "tono bajo" 
Espectrograma _makeTonoA(int nFrames, int bins) {
  final frames = List.generate(
    nFrames,
    (_) {
      final f = Float64List(bins);
      for (int i = 0; i < bins ~/ 4; i++) {
        f[i] = 1.0;
      }
      return f;
    },
  );
  return Espectrograma(frames: frames);
}

/// Espectrograma con señal tipo "tono alto"
Espectrograma _makeTonoB(int nFrames, int bins) {
  final frames = List.generate(
    nFrames,
    (_) {
      final f = Float64List(bins);
      for (int i = 3 * bins ~/ 4; i < bins; i++) {
        f[i] = 1.0;
      }
      return f;
    },
  );
  return Espectrograma(frames: frames);
}

void main() {
  // COMPARADOR COSENO
  
  group('ComparadorCoseno', () {
    late ComparadorCoseno comparador;

    setUp(() {
      comparador = ComparadorCoseno();
    });

    //Test de la clase ComparadorCoseno (umbral, similitud, comparar)
    test('umbral por defecto es 0.6', () {
      expect(comparador.umbral, closeTo(0.6, 1e-10));
    });

    test('similitud de un espectrograma consigo mismo es ~1.0', () {
      final e = _makeConst(10, 64, 1.0);
      final sim = comparador.similitud(e, e);
      expect(sim, closeTo(1.0, 0.05));
    });

    test('comparar devuelve true cuando similitud supera el umbral', () {
      final e1 = _makeConst(10, 64, 0.8);
      final e2 = _makeConst(10, 64, 0.8);
      expect(comparador.comparar(e1, e2), isTrue);
    });

    test('similitud de espectrogramas vacíos es 0.0', () {
      final empty = Espectrograma(frames: []);
      expect(comparador.similitud(empty, empty), closeTo(0.0, 1e-10));
    });

    test('comparar devuelve false para espectrogramas vacíos', () {
      final empty = Espectrograma(frames: []);
      expect(comparador.comparar(empty, empty), isFalse);
    });

    test('espectrogramas espectralmente distintos tienen similitud < umbral', () {
      final tonoA = _makeTonoA(10, 64);
      final tonoB = _makeTonoB(10, 64);
      final sim = comparador.similitud(tonoA, tonoB);
      // Los tonos son muy distintos, similitud debería ser baja
      expect(sim, lessThan(comparador.umbral));
    });

    test('el umbral es modificable en tiempo de ejecución', () {
      comparador.umbral = 0.9;
      expect(comparador.umbral, closeTo(0.9, 1e-10));
    });
  });

  // COMPARADOR MFCC

  group('ComparadorMFCC', () {
    late ComparadorMFCC comparador;

    setUp(() {
      comparador = ComparadorMFCC();
    });

    test('umbral por defecto es 0.7', () {
      expect(comparador.umbral, closeTo(0.7, 1e-10));
    });

    test('similitud de un espectrograma consigo mismo es > 0.9', () {
      
      final frames = List.generate(
        10,
        (i) => Float64List.fromList(List.generate(513, (j) => (j + 1) * 0.001 * (i + 1))),
      );
      final e = Espectrograma(frames: frames);
      final sim = comparador.similitud(e, e);
      expect(sim, greaterThan(0.9));
    });

    test('similitud de espectrogramas vacíos es 0.0', () {
      final empty = Espectrograma(frames: []);
      expect(comparador.similitud(empty, empty), closeTo(0.0, 1e-10));
    });

    test('comparar devuelve false para espectrogramas vacíos', () {
      final empty = Espectrograma(frames: []);
      expect(comparador.comparar(empty, empty), isFalse);
    });

    test('el umbral es modificable en tiempo de ejecución', () {
      comparador.umbral = 0.5;
      expect(comparador.umbral, closeTo(0.5, 1e-10));
    });
  });

  // INTERFAZ POLIMÓRFICA (Comparador abstracto)

  group('Comparador (polimorfismo)', () {
    test('ComparadorCoseno implementa la interfaz Comparador', () {
      final Comparador c = ComparadorCoseno();
      expect(c, isA<Comparador>());
    });

    test('ComparadorMFCC implementa la interfaz Comparador', () {
      final Comparador c = ComparadorMFCC();
      expect(c, isA<Comparador>());
    });

    test('ambos comparadores tienen umbral > 0', () {
      final comparadores = [ComparadorCoseno(), ComparadorMFCC()];
      for (final c in comparadores) {
        expect(c.umbral, greaterThan(0.0));
      }
    });

    test('similitud retorna un double entre -1.0 y 1.0', () {
      final e1 = _makeConst(5, 64, 0.5);
      final e2 = _makeConst(5, 64, 0.3);
      for (final c in [ComparadorCoseno(), ComparadorMFCC()]) {
        final sim = c.similitud(e1, e2);
        expect(sim, greaterThanOrEqualTo(-1.0));
        expect(sim, lessThanOrEqualTo(1.0 + 1e-6));
      }
    });
  });
}
