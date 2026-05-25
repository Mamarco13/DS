import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:salvacion_app/src/api/espectrograma.dart';
import 'package:salvacion_app/src/api/fft.dart';
import 'package:salvacion_app/src/api/comparador.dart';

void main() {
  // Necesario para cualquier test que use Flutter internamente
  TestWidgetsFlutterBinding.ensureInitialized();

  late Espectrograma espectrograma1;
  late Espectrograma espectrograma2;
  late Espectrograma espectrograma3;

  setUpAll(() async {
    // Leemos los WAV directamente, sin pasar por ffmpeg
    final bytes1 = await File('assets/la_1.wav').readAsBytes();
    final bytes2 = await File('assets/la_2.wav').readAsBytes();
    final bytes3 = await File('assets/moneda.wav').readAsBytes();

    espectrograma1 = Espectrograma(frames: await buildSpectrogramFromBytes(bytes1));
    espectrograma2 = Espectrograma(frames: await buildSpectrogramFromBytes(bytes2));
    espectrograma3 = Espectrograma(frames: await buildSpectrogramFromBytes(bytes3));
  });

  group('Serialización', () {
    test('toJson y fromJson reproducen el espectrograma', () {
      final reconstruido = Espectrograma.fromJson(espectrograma1.toJson());
      expect(reconstruido.numeroFrames,   equals(espectrograma1.numeroFrames));
      expect(reconstruido.binsFrecuencia, equals(espectrograma1.binsFrecuencia));
    });
  });

  group('ComparadorCoseno', () {
    late Comparador comparador;
    setUp(() => comparador = ComparadorCoseno());

    test('LA vs LA → similitud alta', () {
      final sim = comparador.similitud(espectrograma1, espectrograma2);
      printOnFailure('Similitud coseno LA-LA: $sim');
      expect(sim, greaterThan(comparador.umbral));
    });

    test('LA vs moneda → similitud baja', () {
      final sim = comparador.similitud(espectrograma1, espectrograma3);
      printOnFailure('Similitud coseno LA-moneda: $sim');
      expect(sim, lessThan(comparador.umbral));
    });
  });

  group('ComparadorMFCC', () {
    late Comparador comparador;
    setUp(() => comparador = ComparadorMFCC());

    test('LA vs LA → similitud alta', () {
      final sim = comparador.similitud(espectrograma1, espectrograma2);
      printOnFailure('Similitud MFCC LA-LA: $sim');
      expect(sim, greaterThan(comparador.umbral));
    });

    test('LA vs moneda → similitud baja', () {
      final sim = comparador.similitud(espectrograma1, espectrograma3);
      printOnFailure('Similitud MFCC LA-moneda: $sim');
      expect(sim, lessThan(comparador.umbral));
    });
  });
}