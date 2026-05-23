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


  double similitudMfcc(Espectrograma otro, {int nMfcc = 13}) {
    // Extraer los MFCC de ambos espectrogramas
    List<List<double>> mfccPropio = _extraerMfcc(nMfcc);
    List<List<double>> mfccOtro = otro._extraerMfcc(nMfcc);

    // Promedio temporal para aplanar los vectores
    List<double> mfccPropioPromedio = _promedioTemporalMfcc(mfccPropio);
    List<double> mfccOtroPromedio = _promedioTemporalMfcc(mfccOtro);

    // Calcular y devolver la similitud usando tu método existente
    return similitudCosenoVectores(mfccPropioPromedio, mfccOtroPromedio);
  }

  /// Extrae los coeficientes MFCC a partir de los frames del espectrograma
  List<List<double>> _extraerMfcc(int nMfcc) {
    if (frames.isEmpty || binsFrecuencia == 0) {
      return [];
    }

    // CONFIGURACIÓN DEL BANCO DE FILTROS MEL
    const int numMelBands = 40; 
    final double maxFreq = sampleRate / 2.0;
    
    // Fórmulas de conversión Hz <-> Mel
    double hzToMel(double hz) => 2595.0 * (log(1.0 + hz / 700.0) / ln10);
    double melToHz(double mel) => 700.0 * (pow(10.0, mel / 2595.0) - 1.0);

    final double maxMel = hzToMel(maxFreq);
    
    // Crear puntos espaciados uniformemente en la escala Mel
    List<double> melPoints = List.generate(numMelBands + 2, (i) => i * maxMel / (numMelBands + 1));
    List<double> hzPoints = melPoints.map((m) => melToHz(m)).toList();
    
    // Mapear esos puntos de Hz a los índices de nuestros bins del espectrograma
    List<int> binPoints = hzPoints.map((hz) => ((binsFrecuencia - 1) * hz / maxFreq).floor()).toList();

    // Construir la matriz de filtros triangulares [numMelBands][binsFrecuencia]
    List<List<double>> fbank = List.generate(numMelBands, (_) => List.filled(binsFrecuencia, 0.0));
    for (int i = 0; i < numMelBands; i++) {
      int left = binPoints[i];
      int center = binPoints[i + 1];
      int right = binPoints[i + 2];

      for (int j = left; j < center; j++) {
        fbank[i][j] = (center == left) ? 0.0 : (j - left) / (center - left);
      }
      for (int j = center; j < right; j++) {
        fbank[i][j] = (right == center) ? 0.0 : (right - j) / (right - center);
      }
    }

    // APLICAR FILTROS MEL Y CALCULAR LOGARITMO
    List<List<double>> logMelSpectrogram = []; // Formato temporal: [frame][bandaMel]
    
    for (final frame in frames) {
      List<double> melEnergies = List.filled(numMelBands, 0.0);
      for (int i = 0; i < numMelBands; i++) {
        double energy = 0.0;
        for (int j = 0; j < binsFrecuencia; j++) {
          // Multiplicamos la magnitud del frame por el filtro triangular
          energy += frame[j] * fbank[i][j];
        }
        melEnergies[i] = log(max(energy, 1e-10)); 
      }
      logMelSpectrogram.add(melEnergies);
    }

    //  APLICAR DCT-II (Transformada Discreta del Coseno)
    // El resultado final lo queremos transpuesto [coeficiente][frame] para la similitud
    List<List<double>> mfcc = List.generate(nMfcc, (_) => List.filled(numeroFrames, 0.0));

    for (int f = 0; f < numeroFrames; f++) {
      for (int k = 0; k < nMfcc; k++) {
        double suma = 0.0;
        for (int n = 0; n < numMelBands; n++) {
          suma += logMelSpectrogram[f][n] * cos(pi * k * (n + 0.5) / numMelBands);
        }
        
        // Normalización ortogonal (estándar en audio)
        double factorNormalizacion = (k == 0) ? sqrt(1.0 / numMelBands) : sqrt(2.0 / numMelBands);
        mfcc[k][f] = suma * factorNormalizacion;
      }
    }

    return mfcc;
  }

  List<double> _promedioTemporalMfcc(List<List<double>> mfccMatrix) {
    if (mfccMatrix.isEmpty) return <double>[];

    int numCoeffs = mfccMatrix.length;
    int numFrames = mfccMatrix[0].length;
    
    List<double> meanVector = List.filled(numCoeffs, 0.0);

    for (int i = 0; i < numCoeffs; i++) {
      double suma = 0.0;
      for (int j = 0; j < numFrames; j++) {
        suma += mfccMatrix[i][j];
      }
      meanVector[i] = suma / numFrames;
    }

    return meanVector;
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