import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../src/coordinador.dart';

class TraductorScreen extends StatefulWidget {
  const TraductorScreen({super.key});

  @override
  State<TraductorScreen> createState() => _TraductorScreenState();
}

class _TraductorScreenState extends State<TraductorScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final Coordinador _coordinador = Coordinador();
  final TextEditingController _lenguajeController = TextEditingController(text: "MiLenguaje");
  
  bool _grabando = false;
  bool _traduciendo = false;
  
  List<Map<String, dynamic>>? _traduccionLiteral;
  String _estrategia = 'coseno';

  Future<String> _rutaAudio() async {
    final dir = await getTemporaryDirectory();
    final time = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/frase_$time.wav';
  }

  Future<void> _toggleGrabacion() async {
    try {
      if (_grabando) {
        final path = await _recorder.stop();

        setState(() {
          _grabando = false;
        });

        if (path != null) {
          _procesarTraduccion(path);
        }
        return;
      }

      final permiso = await _recorder.hasPermission();
      if (!permiso) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sin permisos de micrófono')),
        );
        return;
      }

      final path = await _rutaAudio();

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );

      setState(() {
        _grabando = true;
        _traduccionLiteral = null;
      });
    } catch (e) {
      debugPrint('Error grabando audio: $e');
    }
  }

  Future<void> _procesarTraduccion(String path) async {
    setState(() {
      _traduciendo = true;
    });

    try {
      final nombreLenguaje = _lenguajeController.text.trim();
      if (nombreLenguaje.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, indica un nombre de lenguaje')),
          );
        }
        return;
      }
      final traduccion = await _coordinador.traducirFrase(path, nombreLenguaje, _estrategia);
      
      if (mounted) {
        setState(() {
          _traduccionLiteral = traduccion;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en traducción: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _traduciendo = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    _lenguajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traductor Universal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mantén pulsado o dale a grabar para decir la frase. La frase será dividida en palabras y enviada a la base de datos.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lenguajeController,
              decoration: const InputDecoration(
                labelText: 'Lenguaje origen',
                hintText: 'Ej: MiLenguaje',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _traduciendo ? null : _toggleGrabacion,
              style: ElevatedButton.styleFrom(
                backgroundColor: _grabando ? Colors.red : null,
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                _grabando ? 'Detener y Traducir' : 'Iniciar Frase',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Estrategia: ', style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  value: _estrategia,
                  items: const [
                    DropdownMenuItem(value: 'coseno', child: Text('Coseno (Perfil)')),
                    DropdownMenuItem(value: 'mcff', child: Text('MFCC')),
                  ],
                  onChanged: (String? val) {
                    if (val != null) {
                      setState(() {
                        _estrategia = val;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_traduciendo)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analizando audio y buscando en la BD...'),
                  ],
                ),
              ),
            if (_traduccionLiteral != null) ...[
              const Text(
                'Traducción Literal:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _traduccionLiteral!.length,
                  itemBuilder: (context, index) {
                    final item = _traduccionLiteral![index];
                    final String palabra = item['palabra'];
                    final String tipo = item['tipo'];
                    final double duracion = item['duracion'];
                    
                    IconData icon;
                    if (palabra == '---') {
                      icon = Icons.pause_circle_outline;
                    } else if (palabra == 'unknown') {
                      icon = Icons.help_outline;
                    } else {
                      icon = Icons.check_circle_outline;
                    }

                    return ListTile(
                      leading: Icon(icon),
                      title: Text(palabra, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Tipo: $tipo | Duración: ${duracion.toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey[200],
                child: Text(
                  _traduccionLiteral!.map((e) => e['palabra']).join(' '),
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
