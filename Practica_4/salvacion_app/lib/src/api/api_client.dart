import 'dart:convert';
import 'package:http/http.dart' as http;
import 'espectrograma.dart';

class RailsApiClient {
  // Ajusta la URL según corresponda (por defecto 10.0.2.2 en emulador Android o localhost en Windows/iOS)
  static const String baseUrl = 'http://127.0.0.1:3000';

  Future<int?> obtenerLenguajeId(String nombre) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lenguajes'));
      if (response.statusCode == 200) {
        final List<dynamic> lenguajes = jsonDecode(response.body);
        for (var l in lenguajes) {
          if (l['nombre'] == nombre) {
            return l['id'];
          }
        }
      }
      return null;
    } catch (e) {
      print('Error en obtenerLenguajeId: $e');
      return null;
    }
  }

  Future<bool> crearLenguaje(String nombre) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lenguajes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'lenguaje': {'nombre': nombre}}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error en crearLenguaje: $e');
      return false;
    }
  }

  Future<bool> anadirPalabra(
    int lenguajeId,
    String texto,
    String tipo,
    double duracion,
    Espectrograma espectrograma,
  ) async {
    try {
      final payload = {
        'palabra': {
          'texto': texto,
          'tipo': tipo,
          'duracion': duracion,
          'espectrograma': espectrograma.toJson(),
        }
      };

      final response = await http.post(
        Uri.parse('$baseUrl/lenguajes/$lenguajeId/palabras'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error en anadirPalabra: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción en anadirPalabra: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> buscarTraduccion(
    int lenguajeId,
    Espectrograma espectrograma,
    String estrategia,
  ) async {
    try {
      final payload = {
        'espectrograma': espectrograma.toJson(),
        'estrategia': estrategia,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/lenguajes/$lenguajeId/buscar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error en buscarTraduccion: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Excepción en buscarTraduccion: $e');
      return null;
    }
  }
}
