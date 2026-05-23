import 'dart:typed_data';
import 'package:fftea/fftea.dart';
import 'conversor_audio.dart';

Future<List<Float64List>> buildSpectrogram(String rutaAudio) async {
  final int chunkSize = 1024; // Potencia de 2
  final STFT stft = STFT(chunkSize, Window.hanning(chunkSize));
  final List<Float64List> spectrogram = <Float64List>[];
  
  // Usamos await para esperar a que la lista de doubles esté lista
  List<double> audio = await mp3AWavADoubles(rutaAudio);
  
  stft.run(audio, (freq) {
    spectrogram.add(freq.discardConjugates().magnitudes());
  });

  return spectrogram;
}