import 'package:salvacion_app/src/api/espectrograma.dart';
import 'package:salvacion_app/src/api/fft.dart';
import 'package:salvacion_app/src/api/comparador.dart';

Future<void> main(List<String> args) async {
  final audio1 = await buildSpectrogram("assets/la_1.wav");
  final audio2 = await buildSpectrogram("assets/la_2.wav");
  final audio3 = await buildSpectrogram("assets/moneda.mp3");

  final espectrograma1 = Espectrograma(frames: audio1);
  final jsonEspectrograma1 = espectrograma1.toJson();
  final espectrograma1DesdeJson = Espectrograma.fromJson(jsonEspectrograma1);
  final espectrograma2 = Espectrograma(frames: audio2);
  final espectrograma3 = Espectrograma(frames: audio3);
  Comparador comparador = ComparadorCoseno();
  Comparador comparadorMFCC = ComparadorMFCC();
  bool resultado = comparador.comparar(espectrograma1DesdeJson, espectrograma3);
  print("¿Los audios son similares según el coseno? $resultado");
  bool resultadoMFCC = comparadorMFCC.comparar(espectrograma1DesdeJson, espectrograma3);
  print("¿Los audios son similares según MFCC? $resultadoMFCC");
}