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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate),
            SizedBox(width: 10),
            Text('TRADUCTOR UNIVERSAL'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF1A1A3A), Color(0xFF050510)],
            radius: 1.5,
            center: Alignment.topRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPanel(
                titulo: "CONFIGURACIÓN DEL INTÉRPRETE",
                icono: Icons.settings_voice,
                child: Column(
                  children: [
                    LanguageSelector(controller: _lenguajeController),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _estrategia,
                      dropdownColor: const Color(0xFF1A1A2E),
                      style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace'),
                      decoration: const InputDecoration(
                        labelText: 'Algoritmo de Correlación',
                        prefixIcon: Icon(Icons.memory, color: Colors.cyanAccent),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'coseno', child: Text('DISTANCIA COSENO')),
                        DropdownMenuItem(value: 'mcff', child: Text('COEFICIENTES MFCC')),
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
              ),
              const SizedBox(height: 16),
              _buildPanel(
                titulo: "RECEPCIÓN DE MENSAJE",
                icono: Icons.mic,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _traduciendo ? null : _toggleGrabacion,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _grabando ? Colors.redAccent.withOpacity(0.2) : Colors.greenAccent.withOpacity(0.1),
                          border: Border.all(
                            color: _grabando ? Colors.redAccent : Colors.greenAccent,
                            width: _grabando ? 4 : 2,
                          ),
                          boxShadow: [
                            if (_grabando)
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.6),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            else
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: Icon(
                          _grabando ? Icons.stop : Icons.mic_none,
                          size: 40,
                          color: _grabando ? Colors.redAccent : Colors.greenAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _grabando ? "INTERCEPTANDO..." : "INICIAR INTERCEPCIÓN",
                      style: TextStyle(
                        color: _grabando ? Colors.redAccent : Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_traduciendo)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.cyanAccent),
                        const SizedBox(height: 16),
                        Text(
                          'DECODIFICANDO SEÑAL...',
                          style: TextStyle(
                            color: Colors.cyanAccent.withOpacity(0.8),
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_traduccionLiteral != null)
                Expanded(
                  child: _buildPanel(
                    titulo: "RESULTADO (JSON)",
                    icono: Icons.code,
                    child: Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            const JsonEncoder.withIndent('  ').convert(_traduccionLiteral),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.greenAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanel({required String titulo, required IconData icono, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111122).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          child,
        ],
      ),
    );
  }
}
