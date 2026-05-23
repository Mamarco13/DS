import 'package:salvacion_app/src/api/espectrograma.dart';
import 'package:salvacion_app/src/api/fft.dart';
import 'package:salvacion_app/src/api/comparador.dart';

Future<void> main(List<String> args) async {
  final audio1 = await buildSpectrogram("assets/la_1.wav");
  final audio2 = await buildSpectrogram("assets/la_2.wav");

  final espectrograma1 = Espectrograma(frames: audio1);
  //creo JSON
  final jsonEspectrograma1 = espectrograma1.toJson();
  final espectrograma1DesdeJson = Espectrograma.fromJson(jsonEspectrograma1);
  final espectrograma2 = Espectrograma(frames: audio2);

  Comparador comparador = ComparadorCoseno();
  bool resultado = comparador.comparar(espectrograma1DesdeJson, espectrograma2);
  print("¿Los audios son similares? $resultado");
}