// =============================================================================
// TESTS DE INTEGRACIÓN
// =============================================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:salvacion_app/src/api/api_client.dart';
import 'package:salvacion_app/src/api/espectrograma.dart';

// ---------------------------------------------------------------------------
// HELPERS
// ---------------------------------------------------------------------------

/// Espectrograma mínimo sintético con energía suficiente para no ser silencio.
/// 4 frames × 8 bins, valores > 0.01 para pasar los filtros del servidor.
Espectrograma _makeEspectrograma() {
  final frames = List.generate(
    4,
    (i) => Float64List.fromList(
      List.generate(8, (j) => 0.5 + j * 0.05 + i * 0.02),
    ),
  );
  return Espectrograma(frames: frames);
}

/// Nombre de lenguaje único para evitar colisiones entre tests.
String _uniqueName(String base) =>
    '${base}_${DateTime.now().microsecondsSinceEpoch}';

/// Elimina un lenguaje por nombre buscándolo en la lista.
Future<void> _eliminarLenguajePorNombre(
    RailsApiClient client, String nombre) async {
  final id = await client.obtenerLenguajeId(nombre);
  if (id != null) {
    await client.eliminarLenguaje(id);
  }
}

/// POST a la API para crear un lenguaje y devolver su id.
Future<int?> _crearLenguajeDirecto(String nombre) async {
  final response = await http.post(
    Uri.parse('${RailsApiClient.baseUrl}/lenguajes'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'lenguaje': {'nombre': nombre}}),
  );
  if (response.statusCode == 201) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['id'] as int?;
  }
  return null;
}

// ===========================================================================
// PRINCIPAL
// ===========================================================================

void main() {
  final client = RailsApiClient();

  // =========================================================================
  // LENGUAJES – CRUD
  // =========================================================================

  group('Lenguajes – CRUD', () {
    late String nombre;

    setUp(() {
      nombre = _uniqueName('LangTest');
    });

    tearDown(() async {
      await _eliminarLenguajePorNombre(client, nombre);
    });

    // -----------------------------------------------------------------------
    test('crearLenguaje persiste el lenguaje en la BD y devuelve true',
        () async {
      final ok = await client.crearLenguaje(nombre);
      expect(ok, isTrue, reason: 'crearLenguaje debe devolver true con 201');

      //Si sale en la lista, es persistente
      final lista = await client.obtenerLenguajes();
      final nombres = lista.map((l) => l['nombre']).toList();
      expect(nombres, contains(nombre));
    });

    // -----------------------------------------------------------------------
    test('obtenerLenguajes devuelve una lista no vacía con el lenguaje creado',
        () async {
      await client.crearLenguaje(nombre);

      final lista = await client.obtenerLenguajes();
      expect(lista, isNotEmpty);
      expect(lista.any((l) => l['nombre'] == nombre), isTrue);
    });

    // -----------------------------------------------------------------------
    test('obtenerLenguajeId retorna el id correcto tras crear', () async {
      await client.crearLenguaje(nombre);
      final id = await client.obtenerLenguajeId(nombre);
      expect(id, isNotNull);
      expect(id, isA<int>());
    });

    // -----------------------------------------------------------------------
    test('obtenerLenguajeId retorna null para un nombre inexistente', () async {
      final id = await client.obtenerLenguajeId('nombre_que_no_existe_jamas');
      expect(id, isNull);
    });

    // -----------------------------------------------------------------------
    test('eliminarLenguaje borra el lenguaje y devuelve true', () async {
      await client.crearLenguaje(nombre);
      final id = await client.obtenerLenguajeId(nombre);
      expect(id, isNotNull);

      final ok = await client.eliminarLenguaje(id!);
      expect(ok, isTrue);

      // Ya no debe aparecer en la lista
      final lista = await client.obtenerLenguajes();
      expect(lista.any((l) => l['nombre'] == nombre), isFalse);
    });

    // -----------------------------------------------------------------------
    test(
        'crearLenguaje con nombre duplicado devuelve false (validación unicidad)',
        () async {
      await client.crearLenguaje(nombre);

      // Segundo intento con el mismo nombre
      final ok2 = await client.crearLenguaje(nombre);
      expect(ok2, isFalse,
          reason: 'El servidor debe rechazar nombres duplicados (422)');
    });
  });

  // =========================================================================
  // PALABRAS – CRUD
  // =========================================================================

  group('Palabras – CRUD', () {
    late int lenguajeId;
    late String lenguajeNombre;

    setUp(() async {
      lenguajeNombre = _uniqueName('LangPalabra');
      await client.crearLenguaje(lenguajeNombre);
      lenguajeId = (await client.obtenerLenguajeId(lenguajeNombre))!;
    });

    tearDown(() async {
      await client.eliminarLenguaje(lenguajeId);
    });

    // -----------------------------------------------------------------------
    test('anadirPalabra crea una palabra y persiste en la BD', () async {
      final esp = _makeEspectrograma();
      final ok = await client.anadirPalabra(
          lenguajeId, 'hola', 'verbo', 1.5, esp);
      expect(ok, isTrue);

      final palabras = await client.obtenerPalabras(lenguajeId);
      expect(palabras.any((p) => p['texto'] == 'hola'), isTrue);
    });

    // -----------------------------------------------------------------------
    test('obtenerPalabras devuelve todas las palabras del lenguaje', () async {
      final esp = _makeEspectrograma();
      await client.anadirPalabra(lenguajeId, 'hola', 'verbo', 0.8, esp);
      await client.anadirPalabra(lenguajeId, 'mundo', 'sustantivo', 0.9, esp);

      final palabras = await client.obtenerPalabras(lenguajeId);
      expect(palabras.length, greaterThanOrEqualTo(2));

      final textos = palabras.map((p) => p['texto']).toSet();
      expect(textos, containsAll(['hola', 'mundo']));
    });

    // -----------------------------------------------------------------------
    test('obtenerPalabras devuelve lista vacía para lenguaje sin palabras',
        () async {
      final palabras = await client.obtenerPalabras(lenguajeId);
      expect(palabras, isEmpty);
    });

    // -----------------------------------------------------------------------
    test('eliminarPalabra borra la palabra y devuelve true', () async {
      final esp = _makeEspectrograma();
      await client.anadirPalabra(lenguajeId, 'borrar', 'verbo', 0.5, esp);

      final palabras = await client.obtenerPalabras(lenguajeId);
      final palabra = palabras.firstWhere((p) => p['texto'] == 'borrar');
      final palabraId = palabra['id'] as int;

      final ok = await client.eliminarPalabra(palabraId);
      expect(ok, isTrue);

      final palabrasRestantes = await client.obtenerPalabras(lenguajeId);
      expect(palabrasRestantes.any((p) => p['id'] == palabraId), isFalse);
    });

    // -----------------------------------------------------------------------
    test('actualizarPalabra cambia el texto y devuelve true', () async {
      final esp = _makeEspectrograma();
      await client.anadirPalabra(lenguajeId, 'original', 'verbo', 0.7, esp);

      final palabras = await client.obtenerPalabras(lenguajeId);
      final palabra = palabras.firstWhere((p) => p['texto'] == 'original');
      final palabraId = palabra['id'] as int;

      final ok = await client.actualizarPalabra(
          palabraId, 'modificada', 'sustantivo', 0.7, null);
      expect(ok, isTrue);

      // Verificar que el cambio persiste
      final actualizadas = await client.obtenerPalabras(lenguajeId);
      final actualizada =
          actualizadas.firstWhere((p) => p['id'] == palabraId);
      expect(actualizada['texto'], equals('modificada'));
      expect(actualizada['tipo'], equals('sustantivo'));
    });

    // -----------------------------------------------------------------------
    test(
        'actualizarPalabra con nuevo espectrograma actualiza también la señal',
        () async {
      final esp1 = _makeEspectrograma();
      await client.anadirPalabra(lenguajeId, 'audio', 'verbo', 0.6, esp1);

      final palabras = await client.obtenerPalabras(lenguajeId);
      final palabraId =
          palabras.firstWhere((p) => p['texto'] == 'audio')['id'] as int;

      final esp2 = Espectrograma(
        frames: List.generate(
          3,
          (_) => Float64List.fromList([0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2]),
        ),
      );

      final ok = await client.actualizarPalabra(
          palabraId, 'audio', 'verbo', 0.5, esp2);
      expect(ok, isTrue);
    });

    // -----------------------------------------------------------------------
    test('eliminarLenguaje elimina también sus palabras (cascade)', () async {
      final esp = _makeEspectrograma();
      await client.anadirPalabra(lenguajeId, 'cascada', 'sustantivo', 0.4, esp);

      // Crear un lenguaje extra para no romper el tearDown
      final tempNombre = _uniqueName('TempCascade');
      await client.crearLenguaje(tempNombre);
      final tempId = (await client.obtenerLenguajeId(tempNombre))!;
      await client.anadirPalabra(tempId, 'palabra', 'verbo', 0.3, esp);

      final okElim = await client.eliminarLenguaje(tempId);
      expect(okElim, isTrue);

      // Las palabras del lenguaje eliminado ya no son accesibles
      final response = await http.get(
        Uri.parse('${RailsApiClient.baseUrl}/lenguajes/$tempId/palabras'),
      );
      expect(response.statusCode, isNot(200),
          reason: 'El lenguaje fue borrado, no debe responder 200');
    });
  });

  // =========================================================================
  // BUSCAR – Endpoint de traducción
  // =========================================================================

  group('Buscar – endpoint de traducción', () {
    late int lenguajeId;
    late String lenguajeNombre;

    setUp(() async {
      lenguajeNombre = _uniqueName('LangBuscar');
      await client.crearLenguaje(lenguajeNombre);
      lenguajeId = (await client.obtenerLenguajeId(lenguajeNombre))!;
    });

    tearDown(() async {
      await client.eliminarLenguaje(lenguajeId);
    });

    // -----------------------------------------------------------------------
    test(
        'buscarTraduccion en lenguaje vacío devuelve resultado con palabra unknown',
        () async {
      final esp = _makeEspectrograma();
      final resultado =
          await client.buscarTraduccion(lenguajeId, esp, 'coseno');

      // El servidor responde 200 con { palabra: 'unknown', tipo: 'otro', duracion: 0 }
      expect(resultado, isNotNull);
      expect(resultado!['palabra'], equals('unknown'));
    });

    // -----------------------------------------------------------------------
    test(
        'buscarTraduccion con una palabra en BD devuelve resultado no vacío',
        () async {
      final esp = _makeEspectrograma();
      await client.anadirPalabra(lenguajeId, 'hola', 'verbo', 1.0, esp);

      final resultado =
          await client.buscarTraduccion(lenguajeId, esp, 'coseno');

      expect(resultado, isNotNull);
      expect(resultado!.containsKey('palabra'), isTrue);
      expect(resultado.containsKey('tipo'), isTrue);
      expect(resultado.containsKey('duracion'), isTrue);
    });

    // -----------------------------------------------------------------------
    test(
        'buscarTraduccion con el mismo espectrograma devuelve la palabra añadida',
        () async {
      // Espectrograma con energía alta y bien definido para maximizar similitud
      final frames = List.generate(
        6,
        (i) => Float64List.fromList(
          List.generate(8, (j) => 1.0 - j * 0.05 - i * 0.01),
        ),
      );
      final esp = Espectrograma(frames: frames);

      await client.anadirPalabra(lenguajeId, 'salut', 'verbo', 1.2, esp);

      final resultado =
          await client.buscarTraduccion(lenguajeId, esp, 'coseno');

      expect(resultado, isNotNull);
      // Al buscar con el mismo espectrograma la similitud debe superar el umbral
      expect(resultado!['palabra'], equals('salut'));
    });

    // -----------------------------------------------------------------------
    test('buscarTraduccion con estrategia mcff devuelve resultado válido',
        () async {
      final esp = _makeEspectrograma();
      await client.anadirPalabra(lenguajeId, 'hey', 'verbo', 0.8, esp);

      final resultado =
          await client.buscarTraduccion(lenguajeId, esp, 'mcff');

      expect(resultado, isNotNull);
      expect(resultado!.containsKey('palabra'), isTrue);
    });
  });

  // =========================================================================
  // FLUJO COMPLETO END-TO-END
  // =========================================================================

  group('Flujo completo end-to-end', () {
    test(
        'Ciclo completo: crear lenguaje → añadir palabras → buscar → actualizar → eliminar',
        () async {
      final nombre = _uniqueName('E2E');

      // Crear lenguaje
      final creado = await client.crearLenguaje(nombre);
      expect(creado, isTrue);

      final langId = await client.obtenerLenguajeId(nombre);
      expect(langId, isNotNull);

      // Añadir palabra
      final esp = _makeEspectrograma();
      final aniadida =
          await client.anadirPalabra(langId!, 'test', 'verbo', 0.9, esp);
      expect(aniadida, isTrue);

      // Listar palabras
      final palabras = await client.obtenerPalabras(langId);
      expect(palabras, isNotEmpty);
      final palabraId = palabras.first['id'] as int;

      // Buscar traducción
      final resultado = await client.buscarTraduccion(langId, esp, 'coseno');
      expect(resultado, isNotNull);

      // Actualizar palabra
      final actualizado = await client.actualizarPalabra(
          palabraId, 'test_v2', 'sustantivo', 1.0, null);
      expect(actualizado, isTrue);

      // Verificar actualización
      final palabrasActualizadas = await client.obtenerPalabras(langId);
      final p = palabrasActualizadas.firstWhere((x) => x['id'] == palabraId);
      expect(p['texto'], equals('test_v2'));

      // Eliminar palabra
      final eliminadaPalabra = await client.eliminarPalabra(palabraId);
      expect(eliminadaPalabra, isTrue);

      // Eliminar lenguaje
      final eliminadoLang = await client.eliminarLenguaje(langId);
      expect(eliminadoLang, isTrue);

      // Verificar que ya no existe
      final idPostElim = await client.obtenerLenguajeId(nombre);
      expect(idPostElim, isNull);
    });
  });
}
