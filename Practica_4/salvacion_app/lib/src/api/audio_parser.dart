import 'dart:typed_data';
import 'package:fftea/fftea.dart';
import 'conversor_audio.dart';
import 'espectrograma.dart';

class AudioParser {
  // Configuración de silencios
  static const int chunkSize = 1024;
  static const int sampleRate = 44100;
  static const double silenceThreshold = 0.001; // Ajustado empíricamente a la energía promedio
  static const double tMinSilencio = 0.4; // 0.4 segundos

  static Future<List<Espectrograma?>> procesarFrase(String rutaAudio) async {
    print('AudioParser: Iniciando procesarFrase. Leyendo WAV desde $rutaAudio');
    final List<double> audio = await wavADoubles(rutaAudio);
    print('AudioParser: WAV leído. Total muestras: ${audio.length}');
    
    final STFT stft = STFT(chunkSize, Window.hanning(chunkSize));

    final List<Float64List> allFrames = [];
    print('AudioParser: Ejecutando STFT...');
    stft.run(audio, (freq) {
      allFrames.add(freq.discardConjugates().magnitudes());
    });
    print('AudioParser: STFT completado. Total frames generados: ${allFrames.length}');

    return _dividirPorSilencios(allFrames);
  }

  static List<Espectrograma?> _dividirPorSilencios(List<Float64List> frames) {
    final List<Espectrograma?> result = [];
    List<Float64List> currentWordFrames = [];
    int silentFramesCount = 0;
    
    // Cuántos frames equivalen a tMinSilencio
    final double durationPerFrame = chunkSize / sampleRate;
    final int minSilentFrames = (tMinSilencio / durationPerFrame).ceil();

    print('AudioParser: Iniciando división por silencios...');
    for (var frame in frames) {
      double energy = 0;
      for (var mag in frame) {
        energy += mag;
      }
      energy /= frame.length; // Calcular la energía promedio del frame

      // Si la energía del frame es muy baja, es silencio
      if (energy < silenceThreshold) {
        silentFramesCount++;
        
        // Si teníamos una palabra en progreso y entramos en un silencio largo
        if (silentFramesCount == minSilentFrames && currentWordFrames.isNotEmpty) {
          result.add(Espectrograma(frames: currentWordFrames).normalizar());
          result.add(null); // Añadimos el separador de silencio
          currentWordFrames = [];
        }
      } else {
        // Si hay sonido
        silentFramesCount = 0;
        currentWordFrames.add(frame);
      }
    }

    // Al terminar, si quedó una palabra pendiente, la añadimos
    if (currentWordFrames.isNotEmpty) {
      result.add(Espectrograma(frames: currentWordFrames).normalizar());
    }

    print('AudioParser: División terminada. Total fragmentos (palabras y silencios): ${result.length}');
    return result;
  }
}
