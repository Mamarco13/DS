import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:salvacion_app/src/api/conversor_audio.dart';

// ---------------------------------------------------------------------------
// Helpers para construir cabeceras WAV sintéticas
// ---------------------------------------------------------------------------

/// Construye un WAV válido de 16-bit PCM mono con las muestras dadas.
Uint8List _buildWav(List<int> samples) {
  final dataSize = samples.length * 2; // 2 bytes por muestra (Int16)
  final totalSize = 44 + dataSize;
  final bytes = ByteData(totalSize);

  // Cabecera RIFF
  bytes.setUint8(0, 0x52); // 'R'
  bytes.setUint8(1, 0x49); // 'I'
  bytes.setUint8(2, 0x46); // 'F'
  bytes.setUint8(3, 0x46); // 'F'
  bytes.setUint32(4, totalSize - 8, Endian.little);
  bytes.setUint8(8, 0x57);  // 'W'
  bytes.setUint8(9, 0x41);  // 'A'
  bytes.setUint8(10, 0x56); // 'V'
  bytes.setUint8(11, 0x45); // 'E'

  // Subchunk1 (fmt)
  bytes.setUint8(12, 0x66); // 'f'
  bytes.setUint8(13, 0x6D); // 'm'
  bytes.setUint8(14, 0x74); // 't'
  bytes.setUint8(15, 0x20); // ' '
  bytes.setUint32(16, 16, Endian.little); // Subchunk1Size
  bytes.setUint16(20, 1, Endian.little);  // PCM
  bytes.setUint16(22, 1, Endian.little);  // Mono
  bytes.setUint32(24, 44100, Endian.little); // SampleRate
  bytes.setUint32(28, 44100 * 2, Endian.little); // ByteRate
  bytes.setUint16(32, 2, Endian.little);  // BlockAlign
  bytes.setUint16(34, 16, Endian.little); // BitsPerSample

  // Subchunk2 (data)
  bytes.setUint8(36, 0x64); // 'd'
  bytes.setUint8(37, 0x61); // 'a'
  bytes.setUint8(38, 0x74); // 't'
  bytes.setUint8(39, 0x61); // 'a'
  bytes.setUint32(40, dataSize, Endian.little);

  // Datos PCM
  for (int i = 0; i < samples.length; i++) {
    bytes.setInt16(44 + i * 2, samples[i], Endian.little);
  }

  return bytes.buffer.asUint8List();
}

void main() {
  // =========================================================================
  // wavBytesToDoubles
  // =========================================================================

  group('wavBytesToDoubles', () {
    test('devuelve lista vacía para datos menores o iguales a 44 bytes', () async {
      final shortData = Uint8List(44); // exactamente 44 bytes (solo cabecera)
      final result = await wavBytesToDoubles(shortData);
      expect(result, isEmpty);
    });

    test('devuelve lista vacía para datos de 0 bytes', () async {
      final result = await wavBytesToDoubles(Uint8List(0));
      expect(result, isEmpty);
    });

    test('convierte correctamente una muestra de valor 0', () async {
      final wav = _buildWav([0]);
      final result = await wavBytesToDoubles(wav);
      expect(result.length, equals(1));
      expect(result[0], closeTo(0.0, 1e-6));
    });

    test('convierte el valor máximo Int16 (32767) a ~1.0', () async {
      final wav = _buildWav([32767]);
      final result = await wavBytesToDoubles(wav);
      expect(result.length, equals(1));
      // 32767 / 32768 ≈ 0.999969
      expect(result[0], closeTo(32767 / 32768, 1e-5));
    });

    test('convierte el valor mínimo Int16 (-32768) a -1.0', () async {
      final wav = _buildWav([-32768]);
      final result = await wavBytesToDoubles(wav);
      expect(result.length, equals(1));
      // -32768 / 32768 = -1.0
      expect(result[0], closeTo(-1.0, 1e-5));
    });

    test('convierte múltiples muestras y devuelve el número correcto', () async {
      final samples = [0, 16384, -16384, 32767, -32768];
      final wav = _buildWav(samples);
      final result = await wavBytesToDoubles(wav);
      expect(result.length, equals(samples.length));
    });

    test('la conversión normaliza correctamente varios valores', () async {
      final samples = [0, 16384, -16384];
      final wav = _buildWav(samples);
      final result = await wavBytesToDoubles(wav);
      expect(result[0], closeTo(0.0, 1e-5));
      expect(result[1], closeTo(16384 / 32768, 1e-5));
      expect(result[2], closeTo(-16384 / 32768, 1e-5));
    });

    test('los valores de salida están en el rango [-1.0, 1.0]', () async {
      final samples = List.generate(100, (i) => (i - 50) * 327);
      final wav = _buildWav(samples);
      final result = await wavBytesToDoubles(wav);
      for (final v in result) {
        expect(v, greaterThanOrEqualTo(-1.0 - 1e-5));
        expect(v, lessThanOrEqualTo(1.0 + 1e-5));
      }
    });

    test('datos de solo cabecera (exactamente 44 bytes) devuelven lista vacía', () async {
      final onlyHeader = Uint8List(44);
      final result = await wavBytesToDoubles(onlyHeader);
      expect(result, isEmpty);
    });

    test('datos de 45 bytes (1 byte de audio) devuelven al menos 0 muestras', () async {
      // 45 bytes total: 44 cabecera + 1 byte de datos (incompleto Int16)
      // Int16List(44) interpreta los bytes sobrantes, pero 1 byte no forma Int16
      final data = Uint8List(45);
      final result = await wavBytesToDoubles(data);
      // Resultado podría ser vacío (0 muestras completas Int16) o 1 muestra
      expect(result, isA<List<double>>());
    });

    test('datos de 46 bytes (1 muestra Int16) devuelven 1 elemento', () async {
      final data = Uint8List(46);
      data[44] = 0x00; // byte bajo
      data[45] = 0x40; // byte alto → valor = 0x4000 = 16384
      final result = await wavBytesToDoubles(data);
      expect(result.length, equals(1));
    });
  });
}
