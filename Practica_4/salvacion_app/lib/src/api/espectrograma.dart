import 'dart:math';
import 'package:langchain/langchain.dart';
import 'dart:typed_data';

class Espectrograma {

  // =========================
  // ATRIBUTOS
  // =========================

  final List<Float64List> frames;

  final int chunkSize;

  final int sampleRate;

  final String windowType;

  final double overlap;

  // =========================
  // CONSTRUCTOR
  // =========================

  Espectrograma({
    required this.frames,
    this.chunkSize = 1024,
    this.sampleRate = 44100,
    this.windowType = "hanning",
    this.overlap = 0.5,
  });

  // =========================
  // GETTERS
  // =========================

  int get numeroFrames{
    return frames.length;
  } 

  int get binsFrecuencia{
    int devolver = 0;
    if (frames.isNotEmpty){
      devolver = frames.first.length;
    }
    return devolver;
    }

  bool get estaVacio{
    return frames.isEmpty;
  }

  double get duracionSegundos {
    return (numeroFrames * chunkSize * (1 - overlap)) / sampleRate;
  }

  // =========================
  // OPERACIONES
  // =========================

  Espectrograma concatenar (Espectrograma otro,)
  {
    return Espectrograma(
      //Concatenacion de listas. ... -> spread()
      frames: [...frames, ...otro.frames],
      chunkSize: chunkSize,
      sampleRate: sampleRate,
      windowType: windowType,
      overlap: overlap,
    );
  }

  Espectrograma copiar() {
    return Espectrograma(
      frames: frames.map((f) => Float64List.fromList(f)).toList(),
      chunkSize: chunkSize,
      sampleRate: sampleRate,
      windowType: windowType,
      overlap: overlap,
    );
  }

  Float64List obtenerFrame(int index) {
    return frames[index];
  }

  // =========================
  // NORMALIZACIÓN
  // =========================

  Espectrograma normalizar() {
    double maxValor = 0.0;

    for (final frame in frames) {
      for (final valor in frame) {
        if (valor > maxValor) {
          maxValor = valor;
        }
      }
    }

    if (maxValor == 0) {
      return copiar();
    }

    List<Float64List> nuevosFrames = frames.map((frame) {
      return Float64List.fromList(
        frame.map((v) => v / maxValor).toList(),
      );
    }).toList();

    return Espectrograma(
      frames: nuevosFrames,
      chunkSize: chunkSize,
      sampleRate: sampleRate,
      windowType: windowType,
      overlap: overlap,
    );
  }

  // =========================
  // SILENCIO
  // =========================

  double energiaPromedio() {
    double suma = 0.0;
    int total = 0;
    double devolver = 0.0;
    for (final frame in frames) {
      for (final valor in frame) {
        suma += valor.abs();
        total++;
      }
    }

    if (total == 0){
      devolver = 0.0;
    } else {
      devolver = suma / total;
    }
    return devolver;
  }

  bool esSilencio({double umbral = 0.01,}){
    return energiaPromedio() < umbral;
  }

  // =========================
  // COMPARACIÓN
  // =========================

  double similitudCoseno(Espectrograma otro) {
    return similitudCosenoVectores(_perfilEspectralPromedio(), otro._perfilEspectralPromedio(),
    );
  }

  List<double> _perfilEspectralPromedio() {
    if (frames.isEmpty) {
      return <double>[];
    }

    final int bins = frames.map((frame) => frame.length).reduce(min);
    if (bins <= 1) {
      return <double>[];
    }

    final List<double> perfil = List<double>.filled(bins - 1, 0.0);
    int framesValidos = 0;

    for (final frame in frames) {
      if (frame.length < bins) {
        continue;
      }

      double maxValor = 0.0;
      for (int i = 1; i < bins; i++) {
        if (frame[i] > maxValor) {
          maxValor = frame[i];
        }
      }

      if (maxValor <= 0.0) {
        continue;
      }

      for (int i = 1; i < bins; i++) {
        perfil[i - 1] += frame[i] / maxValor;
      }

      framesValidos++;
    }

    if (framesValidos == 0) {
      return <double>[];
    }

    for (int i = 0; i < perfil.length; i++) {
      perfil[i] /= framesValidos;
      perfil[i] = log(1.0 + perfil[i]);
    }

    final List<double> suavizado = List<double>.filled(perfil.length, 0.0);
    const int radio = 2;

    for (int i = 0; i < perfil.length; i++) {
      double suma = 0.0;
      int contador = 0;

      for (int j = max(0, i - radio); j <= min(perfil.length - 1, i + radio); j++) {
        suma += perfil[j];
        contador++;
      }

      suavizado[i] = suma / contador;
    }

    return suavizado;
  }

  double similitudCosenoVectores(List<double> a, List<double> b) {
    final int longitudComun = min(a.length, b.length);
    if (longitudComun == 0) {
      return 0.0;
    }

    return cosineSimilarity(
      a.sublist(0, longitudComun),
      b.sublist(0, longitudComun),
    );
  }

  // =========================
  // SERIALIZACIÓN
  // =========================

  Map<String, dynamic> toJson(){
    return {
      "frames": frames.map((f) => f.toList(),).toList(),
      "chunkSize": chunkSize,
      "sampleRate": sampleRate,
      "windowType": windowType,
      "overlap": overlap,
      "duracion": duracionSegundos,
    };
  }

  factory Espectrograma.fromJson(
    Map<String, dynamic> json,
  ) {

    return Espectrograma(
      frames:(json["frames"] as List).map(
            (frame) =>Float64List.fromList(List<double>.from(frame),),).toList(),
      chunkSize:json["chunkSize"],
      sampleRate:json["sampleRate"],
      windowType:json["windowType"],
      overlap:json["overlap"].toDouble(),
    );
  }
}