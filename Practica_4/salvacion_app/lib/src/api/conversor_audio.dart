import 'dart:io';
import 'dart:typed_data';

Future<List<double>> mp3AWavADoubles(String rutaArchivoWav) async {
  // Leer el archivo convertido
  File archivo = File(rutaArchivoWav);
  Uint8List bytes = await archivo.readAsBytes();

  // Saltarnos los 44 bytes de cabecera del WAV y leer como enteros de 16 bits.
  // En un entorno de producción, es mejor usar un "Wav parser" para 
  // leer exactamente dónde termina la cabecera, pero 44 es el estándar.
  Int16List datosPCM = bytes.buffer.asInt16List(44);

  // Crear la lista final y normalizar
  List<double> audioNormalizado = List.filled(datosPCM.length, 0.0);
  
  for (int i = 0; i < datosPCM.length; i++) {
    // Dividimos entre 32768.0 para convertir de rango Int16 al rango [-1.0, 1.0]
    audioNormalizado[i] = datosPCM[i] / 32768.0;
  }

  return audioNormalizado;
}

// Nuevo: parsear WAV desde bytes (útil para Flutter Web y rootBundle)
Future<List<double>> wavBytesToDoubles(Uint8List bytes) async {
  // Aseguramos que hay al menos 44 bytes de cabecera
  if (bytes.lengthInBytes <= 44) return <double>[];

  // Interpretar los bytes a partir del offset 44 como Int16 PCM
  final Int16List datosPCM = bytes.buffer.asInt16List(44);

  final List<double> audioNormalizado = List.filled(datosPCM.length, 0.0);
  for (int i = 0; i < datosPCM.length; i++) {
    audioNormalizado[i] = datosPCM[i] / 32768.0;
  }

  return audioNormalizado;
}