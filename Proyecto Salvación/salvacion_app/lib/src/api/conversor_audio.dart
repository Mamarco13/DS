import 'dart:io';
import 'dart:typed_data';

// Esta función ya la tienes, no cambia nada
Future<List<double>> wavBytesToDoubles(Uint8List bytes) async {
  if (bytes.lengthInBytes <= 44) return <double>[];
  final Int16List datosPCM = bytes.buffer.asInt16List(44);
  return List.generate(datosPCM.length, (i) => datosPCM[i] / 32768.0);
}

// Para leer desde ruta (solo WAV)
Future<List<double>> wavADoubles(String rutaWav) async {
  final Uint8List bytes = await File(rutaWav).readAsBytes();
  return wavBytesToDoubles(bytes);
}