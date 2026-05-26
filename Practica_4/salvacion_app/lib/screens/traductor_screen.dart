import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../src/coordinador.dart';
import '../src/widgets/language_selector.dart';

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
          //JSON con frase pocha cobrando sentido aqui!!!
          _traduccionLiteral = traduccion.where((item) => (item['duracion'] as num).toDouble() > 0.0).toList();
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
            LanguageSelector(controller: _lenguajeController),
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
                'Salida (JSON):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey[200],
                  child: SingleChildScrollView(
                    child: SelectableText(
                      const JsonEncoder.withIndent('  ').convert(_traduccionLiteral),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                    ),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
