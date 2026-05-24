import 'dart:math';
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
    final perfil1 = _perfilEspectralPromedio();
    final perfil2 = otro._perfilEspectralPromedio();

    if (perfil1.isEmpty || perfil2.isEmpty) return 0.0;

    return similitudCosenoVectores(perfil1, perfil2);
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

      // =========================
      // ELIMINAR SILENCIO
      // =========================

      double energia = 0.0;

      for (final v in frame) {
        energia += v.abs();
      }

      energia /= frame.length;

      // Ignorar frames silenciosos
      if (energia < 0.00001) {
        continue;
      }

      // =========================
      // NORMALIZACIÓN FRAME
      // =========================

      double maxValor = 0.0;

      for (int i = 1; i < bins; i++) {

        if (frame[i] > maxValor) {
          maxValor = frame[i];
        }

      }

      // Ignorar frames planos
      if (maxValor <= 0.0001) {
        continue;
      }

      for (int i = 1; i < bins; i++) {

        perfil[i - 1] += log(1.0 + frame[i]);

      }

      framesValidos++;
    }

    print(
      "Frames validos coseno: $framesValidos",
    );

    if (framesValidos == 0) {
      return <double>[];
    }

    for (int i = 0; i < perfil.length; i++) {
      perfil[i] /= framesValidos;
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
    final int n = min(a.length, b.length);
    if (n == 0) return 0.0;

    double dot = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < n; i++) {
      dot  += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    final double denom = sqrt(normA) * sqrt(normB);
    return denom < 1e-10 ? 0.0 : dot / denom;
  }
  double similitudMfcc(Espectrograma otro) {
    final mfcc1 = _extraerMfcc(13);
    final mfcc2 = otro._extraerMfcc(13);

    if (mfcc1.isEmpty || mfcc2.isEmpty) return 0.0;

    final nCoef = mfcc1.length;
    final nFrames1 = mfcc1[0].length;
    final nFrames2 = mfcc2[0].length;
    final minFrames = min(nFrames1, nFrames2);

    double suma = 0.0;
    int validos = 0;

    for (int f = 0; f < minFrames; f++) {
      // Construir el vector MFCC del frame f para cada espectrograma
      final vec1 = List.generate(nCoef, (k) => mfcc1[k][f]);
      final vec2 = List.generate(nCoef, (k) => mfcc2[k][f]);

      final s = similitudCosenoVectores(vec1, vec2);
      if (!s.isNaN) {
        suma += s;
        validos++;
      }
    }

    return validos > 0 ? suma / validos : 0.0;
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
      double energia = 0.0;
      for (final v in frame) {
        energia += v.abs();
      }

      energia /= frame.length;

      if (energia < 0.00001) {
        continue;
      }
      print(
        "Energia frame MFCC: $energia",
      );
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
    final totalFrames = logMelSpectrogram.length;

List<List<double>> mfcc =
    List.generate(
      nMfcc,
      (_) => List.filled(totalFrames, 0.0),
    );

    for (int f = 0; f < totalFrames; f++) {

    for (int k = 0; k < nMfcc; k++) {

      double suma = 0.0;

      for (int n = 0; n < numMelBands; n++) {

        suma += logMelSpectrogram[f][n] *
            cos(pi * k * (n + 0.5) / numMelBands);

      }

      double factorNormalizacion =
          (k == 0)
              ? sqrt(1.0 / numMelBands)
              : sqrt(2.0 / numMelBands);

      mfcc[k][f] = suma * factorNormalizacion;
    }

    // =========================
    // DEBUG MFCC
    // =========================

    if (f < 5) {

      List<double> debug = [];

      for (int k = 0; k < min(5, nMfcc); k++) {

        debug.add(mfcc[k][f]);

      }

      print("MFCC FRAME $f:");
      print(debug);

    }
  }
    print(
      "Frames MFCC validos: ${logMelSpectrogram.length}",
    );
    return mfcc;
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

  void debugResumen(String nombre) {

    print("========== $nombre ==========");

    print("Frames: $numeroFrames");

    print("Bins: $binsFrecuencia");

    print("Duracion: $duracionSegundos");

    if (frames.isEmpty) {

      print("SIN FRAMES");

      return;
    }

    int mostrar = min(5, frames.length);

    for (int i = 0; i < mostrar; i++) {

      final frame = frames[i];

      double energia = 0.0;

      double maximo = 0.0;

      for (final v in frame) {

        energia += v.abs();

        if (v > maximo) {
          maximo = v;
        }
      }

      energia /= frame.length;

      print(
        "Frame $i -> energia=$energia max=$maximo",
      );
    }

    print("============================");
  }
}