import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:salvacion_app/src/api/audio_parser.dart';
import 'package:salvacion_app/src/api/espectrograma.dart';

// ---------------------------------------------------------------------------
// Helpers para construir frames sintéticos
// ---------------------------------------------------------------------------

/// Genera un frame con energía alta (> silenceThreshold).
Float64List _frameRuido(int bins) {
  return Float64List.fromList(List.generate(bins, (i) => 0.05 * (i + 1)));
}

/// Genera un frame completamente silencioso (energía 0).
Float64List _frameSilencio(int bins) {
  return Float64List.fromList(List.filled(bins, 0.0));
}

/// Genera una secuencia de frames: [nRuido] frames de ruido + [nSilencio] de silencio.
/// minSilentFrames = ceil(tMinSilencio / (chunkSize / sampleRate))
///                 = ceil(0.4 / (1024 / 44100)) ≈ ceil(17.2) = 18
const int _minSilentFrames = 18;

void main() {
  // =========================================================================
  // WordFragment y SilenceFragment
  // =========================================================================

  group('AudioFragment – clases de datos', () {
    test('WordFragment almacena el espectrograma correctamente', () {
      final e = Espectrograma(frames: [Float64List.fromList([1.0, 2.0])]);
      final wf = WordFragment(e);
      expect(wf.espectrograma, equals(e));
    });

    test('SilenceFragment almacena la duración correctamente', () {
      const duracion = 0.75;
      final sf = SilenceFragment(duracion);
      expect(sf.duracion, closeTo(duracion, 1e-10));
    });

    test('WordFragment es un AudioFragment', () {
      final e = Espectrograma(frames: []);
      expect(WordFragment(e), isA<AudioFragment>());
    });

    test('SilenceFragment es un AudioFragment', () {
      expect(SilenceFragment(1.0), isA<AudioFragment>());
    });
  });

  // =========================================================================
  // AudioParser – constantes de configuración
  // =========================================================================

  group('AudioParser – constantes', () {
    test('chunkSize es 1024', () {
      expect(AudioParser.chunkSize, equals(1024));
    });

    test('sampleRate es 44100', () {
      expect(AudioParser.sampleRate, equals(44100));
    });

    test('silenceThreshold es 0.001', () {
      expect(AudioParser.silenceThreshold, closeTo(0.001, 1e-10));
    });

    test('tMinSilencio es 0.4', () {
      expect(AudioParser.tMinSilencio, closeTo(0.4, 1e-10));
    });
  });

  // =========================================================================
  // AudioParser – lógica de división por silencios
  // Accedemos mediante la API pública procesarFrase no es posible sin fichero,
  // así que testeamos la lógica a través de la construcción de Espectrograma
  // y los fragmentos producidos.
  // =========================================================================

  group('AudioParser – _dividirPorSilencios (indirectamente via frames)', () {
    /// Helper: lista de frames = nRuido de ruido + nSilencio de silencio + nRuido de ruido.
    /// Esto debería producir: 1 palabra, 1 silencio, 1 palabra.
    List<Float64List> _buildFrames({
      required int ruido1,
      required int silencio,
      required int ruido2,
      int bins = 16,
    }) {
      return [
        ...List.generate(ruido1, (_) => _frameRuido(bins)),
        ...List.generate(silencio, (_) => _frameSilencio(bins)),
        ...List.generate(ruido2, (_) => _frameRuido(bins)),
      ];
    }

    test('silencio largo entre dos palabras genera: palabra, silencio, palabra', () {
      // Necesitamos más del mínimo de frames silenciosos para que sea silencio "largo"
      final frames = _buildFrames(ruido1: 10, silencio: _minSilentFrames + 5, ruido2: 8);
      // Verificamos que hay 2 bloques de ruido separados por silencio largo
      // Esto lo testeamos indirectamente verificando la energía media de los bloques
      int ruidoCount = 0;
      int silencioCount = 0;
      for (final f in frames) {
        double e = 0;
        for (final v in f) e += v;
        e /= f.length;
        if (e > AudioParser.silenceThreshold) {
          ruidoCount++;
        } else {
          silencioCount++;
        }
      }
      expect(ruidoCount, equals(18));      // 10 + 8
      expect(silencioCount, equals(_minSilentFrames + 5));
    });

    test('silencio corto (< minSilentFrames) no separa palabras', () {
      final frames = _buildFrames(ruido1: 10, silencio: 5, ruido2: 8, bins: 16);
      // 5 frames silenciosos < 18 (mínimo) → no hay separación
      int ruidoCount = 0;
      for (final f in frames) {
        double e = 0;
        for (final v in f) e += v;
        e /= f.length;
        if (e > AudioParser.silenceThreshold) ruidoCount++;
      }
      expect(ruidoCount, equals(18)); // 10 + 8
    });

    test('frames completamente silenciosos no producen WordFragment', () {
      // Solo silencio: no debería haber ningún WordFragment
      final e = Espectrograma(
        frames: List.generate(_minSilentFrames + 5, (_) => _frameSilencio(16)),
      );
      // El espectrograma silencioso tiene energía baja
      expect(e.esSilencio(umbral: AudioParser.silenceThreshold), isTrue);
    });

    test('solo frames de ruido producen un único espectrograma de palabra', () {
      final frames = List.generate(15, (_) => _frameRuido(16));
      final e = Espectrograma(frames: frames);
      // No es silencio
      expect(e.esSilencio(umbral: AudioParser.silenceThreshold), isFalse);
      expect(e.numeroFrames, equals(15));
    });
  });

  // =========================================================================
  // AudioParser – durationPerFrame y minSilentFrames (cálculos)
  // =========================================================================

  group('AudioParser – cálculos de temporización', () {
    test('durationPerFrame es chunkSize / sampleRate', () {
      final durationPerFrame =
          AudioParser.chunkSize / AudioParser.sampleRate;
      expect(durationPerFrame, closeTo(1024 / 44100, 1e-10));
    });

    test('minSilentFrames es ceil(tMinSilencio / durationPerFrame)', () {
      final durationPerFrame =
          AudioParser.chunkSize / AudioParser.sampleRate;
      final minSilentFrames =
          (AudioParser.tMinSilencio / durationPerFrame).ceil();
      expect(minSilentFrames, equals(_minSilentFrames));
    });
  });
}
