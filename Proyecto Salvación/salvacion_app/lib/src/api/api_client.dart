import 'dart:convert';
import 'package:http/http.dart' as http;
import 'espectrograma.dart';

class RailsApiClient {
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

  Future<List<Map<String, dynamic>>> obtenerLenguajes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lenguajes'));
      if (response.statusCode == 200) {
        final List<dynamic> lenguajes = jsonDecode(response.body);
        return lenguajes.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error en obtenerLenguajes: $e');
      return [];
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

  Future<List<Map<String, dynamic>>> obtenerPalabras(int lenguajeId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lenguajes/$lenguajeId/palabras'));
      if (response.statusCode == 200) {
        final List<dynamic> palabras = jsonDecode(response.body);
        return palabras.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error en obtenerPalabras: $e');
      return [];
    }
  }

  Future<bool> eliminarPalabra(int palabraId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/palabras/$palabraId'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error en eliminarPalabra: $e');
      return false;
    }
  }

  Future<bool> actualizarPalabra(
    int palabraId,
    String texto,
    String tipo,
    double? duracion,
    Espectrograma? espectrograma,
  ) async {
    try {
      final Map<String, dynamic> palabraData = {
        'texto': texto,
        'tipo': tipo,
      };
      if (duracion != null) palabraData['duracion'] = duracion;
      if (espectrograma != null) palabraData['espectrograma'] = espectrograma.toJson();

      final payload = {
        'palabra': palabraData
      };

      final response = await http.put(
        Uri.parse('$baseUrl/palabras/$palabraId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Error en actualizarPalabra: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción en actualizarPalabra: $e');
      return false;
    }
  }

  Future<bool> eliminarLenguaje(int lenguajeId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/lenguajes/$lenguajeId'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error en eliminarLenguaje: $e');
      return false;
    }
  }
}

