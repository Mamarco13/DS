import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:salvacion_app/src/api/espectrograma.dart';

/// Genera un espectrograma sintético con [nFrames] frames de [bins] bins.
Espectrograma _makeConst(int nFrames, int bins, double value) {
  final frames = List.generate(
    nFrames,
    (_) => Float64List.fromList(List.filled(bins, value)),
  );
  return Espectrograma(frames: frames);
}

/// Genera un espectrograma con frames de energía alta (valor = 1.0).
Espectrograma _makeLoud(int nFrames, int bins) => _makeConst(nFrames, bins, 1.0);

/// Genera un espectrograma silencioso (valor = 0.0).
Espectrograma _makeSilent(int nFrames, int bins) => _makeConst(nFrames, bins, 0.0);

/// Espectrograma con valores aleatorios reproducibles.
Espectrograma _makeRandom(int nFrames, int bins, {int seed = 42}) {
  final rng = Random(seed);
  final frames = List.generate(
    nFrames,
    (_) => Float64List.fromList(
      List.generate(bins, (_) => rng.nextDouble()),
    ),
  );
  return Espectrograma(frames: frames);
}

void main() {
  // GETTERS

  group('Espectrograma – getters', () {
    test('numeroFrames devuelve la cantidad correcta de frames', () {
      final e = _makeLoud(10, 513);
      expect(e.numeroFrames, equals(10));
    });

    test('numeroFrames es 0 para frames vacíos', () {
      final e = Espectrograma(frames: []);
      expect(e.numeroFrames, equals(0));
    });

    test('binsFrecuencia devuelve la longitud del primer frame', () {
      final e = _makeLoud(5, 513);
      expect(e.binsFrecuencia, equals(513));
    });

    test('binsFrecuencia es 0 para frames vacíos', () {
      final e = Espectrograma(frames: []);
      expect(e.binsFrecuencia, equals(0));
    });

    test('estaVacio es true si no hay frames', () {
      final e = Espectrograma(frames: []);
      expect(e.estaVacio, isTrue);
    });

    test('estaVacio es false si hay frames', () {
      final e = _makeLoud(1, 4);
      expect(e.estaVacio, isFalse);
    });

    test('duracionSegundos se calcula correctamente con valores por defecto', () {
      // duracion = (numeroFrames * chunkSize * (1 - overlap)) / sampleRate
      // = (10 * 1024 * 0.5) / 44100
      final e = _makeLoud(10, 513);
      final expected = (10 * 1024 * (1 - 0.5)) / 44100;
      expect(e.duracionSegundos, closeTo(expected, 1e-10));
    });

    test('duracionSegundos con parámetros personalizados', () {
      final e = Espectrograma(
        frames: [Float64List.fromList([1.0, 2.0])],
        chunkSize: 512,
        sampleRate: 22050,
        overlap: 0.25,
      );
      final expected = (1 * 512 * (1 - 0.25)) / 22050;
      expect(e.duracionSegundos, closeTo(expected, 1e-10));
    });
  });

  // CONSTRUCTOR Y VALORES POR DEFECTO

  group('Espectrograma – constructor', () {
    test('valores por defecto son los correctos', () {
      final e = Espectrograma(frames: []);
      expect(e.chunkSize, equals(1024));
      expect(e.sampleRate, equals(44100));
      expect(e.windowType, equals('hanning'));
      expect(e.overlap, closeTo(0.5, 1e-10));
    });

    test('se pueden establecer valores personalizados', () {
      final e = Espectrograma(
        frames: [],
        chunkSize: 512,
        sampleRate: 22050,
        windowType: 'hamming',
        overlap: 0.25,
      );
      expect(e.chunkSize, equals(512));
      expect(e.sampleRate, equals(22050));
      expect(e.windowType, equals('hamming'));
      expect(e.overlap, closeTo(0.25, 1e-10));
    });
  });

  // OPERACIONES

  group('Espectrograma – concatenar', () {
    test('concatenar une los frames de ambos espectrogramas', () {
      final e1 = _makeLoud(3, 4);
      final e2 = _makeLoud(5, 4);
      final concat = e1.concatenar(e2);
      expect(concat.numeroFrames, equals(8));
    });

    test('concatenar preserva la configuración del primero', () {
      final e1 = Espectrograma(
        frames: [Float64List.fromList([1.0])],
        chunkSize: 512,
        sampleRate: 22050,
        windowType: 'hamming',
        overlap: 0.25,
      );
      final e2 = Espectrograma(
        frames: [Float64List.fromList([2.0])],
      );
      final concat = e1.concatenar(e2);
      expect(concat.chunkSize, equals(512));
      expect(concat.sampleRate, equals(22050));
      expect(concat.windowType, equals('hamming'));
      expect(concat.overlap, closeTo(0.25, 1e-10));
    });

    test('concatenar con espectrograma vacío devuelve los frames del primero', () {
      final e1 = _makeLoud(3, 4);
      final empty = Espectrograma(frames: []);
      final concat = e1.concatenar(empty);
      expect(concat.numeroFrames, equals(3));
    });
  });

  group('Espectrograma – copiar', () {
    test('copiar produce un espectrograma con los mismos frames', () {
      final e = _makeRandom(4, 8);
      final copia = e.copiar();
      expect(copia.numeroFrames, equals(e.numeroFrames));
      expect(copia.binsFrecuencia, equals(e.binsFrecuencia));
      for (int i = 0; i < e.numeroFrames; i++) {
        for (int j = 0; j < e.binsFrecuencia; j++) {
          expect(copia.frames[i][j], closeTo(e.frames[i][j], 1e-10));
        }
      }
    });

    test('copiar produce una copia profunda (modificar copia no afecta original)', () {
      final e = _makeLoud(2, 4);
      final copia = e.copiar();
      copia.frames[0][0] = 999.0;
      expect(e.frames[0][0], isNot(equals(999.0)));
    });
  });

  group('Espectrograma – obtenerFrame', () {
    test('obtenerFrame devuelve el frame correcto', () {
      final frames = [
        Float64List.fromList([1.0, 2.0]),
        Float64List.fromList([3.0, 4.0]),
      ];
      final e = Espectrograma(frames: frames);
      expect(e.obtenerFrame(1)[0], closeTo(3.0, 1e-10));
      expect(e.obtenerFrame(1)[1], closeTo(4.0, 1e-10));
    });
  });

  // NORMALIZACIÓN

  group('Espectrograma – normalizar', () {
    test('los valores del espectrograma normalizado están entre 0 y 1', () {
      final e = _makeRandom(5, 10, seed: 7);
      final norm = e.normalizar();
      for (final frame in norm.frames) {
        for (final v in frame) {
          expect(v, greaterThanOrEqualTo(0.0));
          expect(v, lessThanOrEqualTo(1.0 + 1e-10));
        }
      }
    });

    test('el máximo valor tras normalizar es 1.0', () {
      final frames = [
        Float64List.fromList([0.5, 0.2, 0.8]),
        Float64List.fromList([0.1, 0.4, 0.3]),
      ];
      final e = Espectrograma(frames: frames);
      final norm = e.normalizar();
      double max = 0;
      for (final f in norm.frames) {
        for (final v in f) {
          if (v > max) max = v;
        }
      }
      expect(max, closeTo(1.0, 1e-10));
    });

    test('normalizar espectrograma todo-ceros devuelve una copia sin modificar', () {
      final e = _makeSilent(3, 4);
      final norm = e.normalizar();
      for (final frame in norm.frames) {
        for (final v in frame) {
          expect(v, closeTo(0.0, 1e-10));
        }
      }
    });

    test('normalizar frames vacíos devuelve espectrograma vacío', () {
      final e = Espectrograma(frames: []);
      final norm = e.normalizar();
      expect(norm.estaVacio, isTrue);
    });
  });
  // ENERGÍA Y SILENCIO

  group('Espectrograma – energiaPromedio', () {
    test('energiaPromedio de espectrograma vacío es 0.0', () {
      final e = Espectrograma(frames: []);
      expect(e.energiaPromedio(), closeTo(0.0, 1e-10));
    });

    test('energiaPromedio de valores constantes iguales al valor', () {
      final e = _makeConst(2, 4, 0.5);
      expect(e.energiaPromedio(), closeTo(0.5, 1e-10));
    });

    test('energiaPromedio de valores mixtos calcula correctamente', () {
      final frames = [
        Float64List.fromList([1.0, 0.0]),
        Float64List.fromList([0.0, 1.0]),
      ];
      final e = Espectrograma(frames: frames);
      // suma = 2, total = 4 → promedio = 0.5
      expect(e.energiaPromedio(), closeTo(0.5, 1e-10));
    });
  });

  group('Espectrograma – esSilencio', () {
    test('espectrograma silencioso es silencio con umbral por defecto', () {
      final e = _makeSilent(3, 4);
      expect(e.esSilencio(), isTrue);
    });

    test('espectrograma con energia alta no es silencio', () {
      final e = _makeLoud(3, 4);
      expect(e.esSilencio(), isFalse);
    });

    test('esSilencio respeta el umbral personalizado', () {
      final e = _makeConst(2, 4, 0.005); // energia = 0.005
      expect(e.esSilencio(umbral: 0.001), isFalse); // 0.005 > 0.001
      expect(e.esSilencio(umbral: 0.01), isTrue);   // 0.005 < 0.01
    });
  });

  // SIMILITUD COSENO (vectores)

  group('Espectrograma – similitudCosenoVectores', () {
    test('vector idéntico tiene similitud 1.0', () {
      final e = _makeLoud(1, 4);
      final v = [1.0, 2.0, 3.0, 4.0];
      final sim = e.similitudCosenoVectores(v, v);
      expect(sim, closeTo(1.0, 1e-6));
    });

    test('vectores ortogonales tienen similitud 0.0', () {
      final e = _makeLoud(1, 2);
      final v1 = [1.0, 0.0];
      final v2 = [0.0, 1.0];
      final sim = e.similitudCosenoVectores(v1, v2);
      expect(sim, closeTo(0.0, 1e-6));
    });

    test('vectores opuestos tienen similitud -1.0', () {
      final e = _makeLoud(1, 2);
      final v1 = [1.0, 2.0];
      final v2 = [-1.0, -2.0];
      final sim = e.similitudCosenoVectores(v1, v2);
      expect(sim, closeTo(-1.0, 1e-6));
    });

    test('vectores de longitud cero devuelven 0.0', () {
      final e = _makeLoud(1, 2);
      expect(e.similitudCosenoVectores([], []), closeTo(0.0, 1e-6));
    });
  });

  // SIMILITUD COSENO (espectrogramas)

  group('Espectrograma – similitudCoseno entre espectrogramas', () {
    test('espectrograma idéntico con sí mismo tiene similitud 1.0', () {
      final e = _makeRandom(10, 64, seed: 1);
      final norm = e.normalizar();
      // Un espectrograma con sigo mismo debe ser ~1
      final sim = norm.similitudCoseno(norm);
      expect(sim, closeTo(1.0, 1e-5));
    });

    test('espectrograma vacío vs otro devuelve 0.0', () {
      final empty = Espectrograma(frames: []);
      final e = _makeLoud(5, 64);
      expect(empty.similitudCoseno(e), closeTo(0.0, 1e-10));
    });
  });

  // PERFIL ESPECTRAL PROMEDIO

  group('Espectrograma – perfilEspectralPromedio', () {
    test('devuelve lista vacía para espectrograma vacío', () {
      final e = Espectrograma(frames: []);
      expect(e.perfilEspectralPromedio(), isEmpty);
    });

    test('devuelve lista vacía si todos los frames son silencio', () {
      // Valores muy bajos (energía < 0.00001)
      final e = _makeConst(3, 8, 0.000001);
      expect(e.perfilEspectralPromedio(), isEmpty);
    });

    test('devuelve longitud correcta para frames con señal', () {
      final e = _makeConst(3, 64, 1.0);
      final perfil = e.perfilEspectralPromedio();
      // binsFrecuencia - 1 = 63
      expect(perfil.length, equals(63));
    });
  });

  // MFCC

  group('Espectrograma – extraerMfcc', () {
    test('devuelve lista vacía para espectrograma vacío', () {
      final e = Espectrograma(frames: []);
      expect(e.extraerMfcc(13), isEmpty);
    });

    test('devuelve nMfcc coeficientes', () {
      final e = _makeRandom(10, 513, seed: 3);
      final mfcc = e.extraerMfcc(13);
      expect(mfcc.length, equals(13));
    });
  });

  group('Espectrograma – similitudMfcc', () {
    test('espectrograma consigo mismo tiene similitud MFCC alta', () {
      final e = _makeRandom(10, 513, seed: 5);
      final sim = e.similitudMfcc(e);
      // Consigo mismo la similitud coseno de cada frame debería ser ~1
      expect(sim, greaterThan(0.9));
    });

    test('espectrogramas vacíos devuelven 0.0', () {
      final empty = Espectrograma(frames: []);
      expect(empty.similitudMfcc(empty), closeTo(0.0, 1e-10));
    });
  });

  // SERIALIZACIÓN

  group('Espectrograma – toJson / fromJson', () {
    test('toJson incluye todas las claves esperadas', () {
      final e = _makeRandom(3, 8, seed: 9);
      final json = e.toJson();
      expect(json.containsKey('frames'), isTrue);
      expect(json.containsKey('perfil'), isTrue);
      expect(json.containsKey('mfcc'), isTrue);
      expect(json.containsKey('chunkSize'), isTrue);
      expect(json.containsKey('sampleRate'), isTrue);
      expect(json.containsKey('windowType'), isTrue);
      expect(json.containsKey('overlap'), isTrue);
      expect(json.containsKey('duracion'), isTrue);
    });

    test('fromJson reconstruye correctamente chunkSize, sampleRate, windowType y overlap', () {
      final e = Espectrograma(
        frames: [Float64List.fromList([0.5, 0.3])],
        chunkSize: 512,
        sampleRate: 22050,
        windowType: 'hamming',
        overlap: 0.25,
      );
      final json = e.toJson();
      final reconstruido = Espectrograma.fromJson(json);
      expect(reconstruido.chunkSize, equals(512));
      expect(reconstruido.sampleRate, equals(22050));
      expect(reconstruido.windowType, equals('hamming'));
      expect(reconstruido.overlap, closeTo(0.25, 1e-10));
    });

    test('fromJson reconstruye el número de frames correcto', () {
      final e = _makeRandom(5, 8, seed: 11);
      final reconstruido = Espectrograma.fromJson(e.toJson());
      expect(reconstruido.numeroFrames, equals(e.numeroFrames));
    });

    test('fromJson reconstruye los bins de frecuencia correctamente', () {
      final e = _makeRandom(5, 8, seed: 13);
      final reconstruido = Espectrograma.fromJson(e.toJson());
      expect(reconstruido.binsFrecuencia, equals(e.binsFrecuencia));
    });

    test('toJson y fromJson son inversos (valores con truncado de 4 decimales)', () {
      final original = _makeConst(2, 4, 0.12345678);
      final reconstruido = Espectrograma.fromJson(original.toJson());
      // Los valores se truncan a 4 decimales en toJson
      for (int i = 0; i < original.numeroFrames; i++) {
        for (int j = 0; j < original.binsFrecuencia; j++) {
          expect(
            reconstruido.frames[i][j],
            closeTo((original.frames[i][j] * 10000).roundToDouble() / 10000, 1e-10),
          );
        }
      }
    });
  });
}
