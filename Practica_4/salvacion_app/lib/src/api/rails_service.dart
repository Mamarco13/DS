import 'dart:convert';
import 'package:http/http.dart' as http;
import 'espectrograma.dart';

class RailsService {
  static const String _base = 'http://localhost:3000';

  ///////////////////////////////
  // LENGUAJES
  

  static Future<List<Map<String, dynamic>>> getLenguajes() async {
    final res = await http.get(Uri.parse('$_base/lenguajes'));
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  static Future<Map<String, dynamic>> crearLenguaje(String nombre) async {
    final res = await http.post(
      Uri.parse('$_base/lenguajes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'lenguaje': {'nombre': nombre}}),
    );
    return jsonDecode(res.body);
  }

  static Future<void> eliminarLenguaje(int id) async {
    await http.delete(Uri.parse('$_base/lenguajes/$id'));
  }

  ////////////////////////
  // PALABRAS
  

  static Future<List<Map<String, dynamic>>> getPalabras(int lenguajeId) async {
    final res = await http.get(Uri.parse('$_base/lenguajes/$lenguajeId/palabras'));
    return List<Map<String, dynamic>>.from(jsonDecode(res.body));
  }

  static Future<Map<String, dynamic>> crearPalabra({
    required int lenguajeId,
    required String texto,
    required String tipo,
    required double duracion,
    required Espectrograma espectrograma,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/lenguajes/$lenguajeId/palabras'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'palabra': {
          'texto': texto,
          'tipo': tipo,
          'duracion': duracion,
          'espectrograma': espectrograma.toJson(),
        }
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<void> eliminarPalabra(int id) async {
    await http.delete(Uri.parse('$_base/palabras/$id'));
  }

  //////////////////////////////////////////
  // BUSCAR
 

  static Future<Map<String, dynamic>> buscar({
    required int lenguajeId,
    required Espectrograma espectrograma,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/lenguajes/$lenguajeId/buscar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'espectrograma': espectrograma.toJson()}),
    );
    return jsonDecode(res.body);
  }
}
