import 'dart:typed_data';
import 'package:fftea/fftea.dart';
import 'conversor_audio.dart';

Future<List<Float64List>> buildSpectrogram(String rutaAudio) async {
  final int chunkSize = 1024;
  final STFT stft = STFT(chunkSize, Window.hanning(chunkSize));
  final List<Float64List> spectrogram = <Float64List>[];

  List<double> audio = await wavADoubles(rutaAudio); // ← solo este cambio

  stft.run(audio, (freq) {
    spectrogram.add(freq.discardConjugates().magnitudes());
  });

  return spectrogram;
}

Future<List<Float64List>> buildSpectrogramFromBytes(Uint8List bytes) async {
  final int chunkSize = 1024;
  final STFT stft = STFT(chunkSize, Window.hanning(chunkSize));
  final List<Float64List> spectrogram = <Float64List>[];

  final List<double> audio = await wavBytesToDoubles(bytes);

  stft.run(audio, (freq) {
    spectrogram.add(freq.discardConjugates().magnitudes());
  });

  return spectrogram;
}