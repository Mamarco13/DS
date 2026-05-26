import 'api/api_client.dart';
import 'api/audio_parser.dart';
import 'api/espectrograma.dart';

class Coordinador {
  final RailsApiClient _apiClient = RailsApiClient();

  /// Dado un archivo de audio y el lenguaje, procesa la frase entera y
  /// devuelve una lista de mapas con las palabras traducidas literalmente.
  Future<List<Map<String, dynamic>>> traducirFrase(String rutaAudio, String nombreLenguaje, String estrategia) async {
    print('Coordinador: Iniciando traducción de frase...');
    // 1. Obtener ID del lenguaje
    final langId = await _apiClient.obtenerLenguajeId(nombreLenguaje);
    if (langId == null) {
      throw Exception('Lenguaje no encontrado: $nombreLenguaje');
    }
    print('Coordinador: Lenguaje $nombreLenguaje encontrado con ID $langId');

    // 2. Usar Audio Parser para dividir la frase
    final List<Espectrograma?> fragmentos = await AudioParser.procesarFrase(rutaAudio);
    print('Coordinador: Frase dividida en ${fragmentos.length} fragmentos.');

    // 3. Iterar sobre los fragmentos y consultar a la BD uno por uno
    final List<Map<String, dynamic>> traduccionLiteral = [];

    for (int i = 0; i < fragmentos.length; i++) {
      var espectrograma = fragmentos[i];
      if (espectrograma == null) {
        print('Coordinador: Fragmento $i es un silencio.');
        // Es un silencio prolongado
        traduccionLiteral.add({
          "palabra": "---",
          "tipo": "otro",
          "duracion": 0.0,
        });
      } else {
        print('Coordinador: Fragmento $i es una palabra. Consultando API (Estrategia: $estrategia)...');
        // Consultar BD
        final resultado = await _apiClient.buscarTraduccion(langId, espectrograma, estrategia);
        
        if (resultado != null) {
          print('Coordinador: Resultado de API: ${resultado["palabra"]}');
          traduccionLiteral.add({
            "palabra": resultado['palabra'] ?? 'unknown',
            "tipo": resultado['tipo'] ?? 'otro',
            "duracion": resultado['duracion'] ?? 0.0,
          });
        } else {
          // Si hubo error de red o de otro tipo
          traduccionLiteral.add({
            "palabra": "unknown",
            "tipo": "otro",
            "duracion": 0.0,
          });
        }
      }
    }

    print('Coordinador: Traducción completa. Palabras devueltas: ${traduccionLiteral.length}');
    return traduccionLiteral;
  }
}
