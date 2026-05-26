import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../src/api/espectrograma.dart';
import '../src/api/fft.dart';

enum TipoPalabra { verbo, sustantivo, adjetivo, pronombre, otro}

extension TipoPalabraX on TipoPalabra {
  String get label {
    switch (this) {
      case TipoPalabra.verbo:
        return 'Verbo';
      case TipoPalabra.sustantivo:
        return 'Sustantivo';
      case TipoPalabra.adjetivo:
        return 'Adjetivo';
      case TipoPalabra.pronombre:
        return 'Pronombre';
      case TipoPalabra.otro:
        return 'Otro';
    }
  }
}

class PrepararAudioRailsScreen extends StatefulWidget {
  const PrepararAudioRailsScreen({super.key});

  @override
  State<PrepararAudioRailsScreen> createState() =>
      _PrepararAudioRailsScreenState();
}

class _PrepararAudioRailsScreenState extends State<PrepararAudioRailsScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final TextEditingController _textoController = TextEditingController();

  TipoPalabra _tipoSeleccionado = TipoPalabra.verbo;
  Espectrograma? _espectrograma;
  bool _grabando = false;
  bool _preparando = false;

  Future<String> _rutaAudio() async {
    final dir = await getTemporaryDirectory();
    final time = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/audio_$time.wav';
  }

  Future<void> _toggleGrabacion() async {
    try {
      if (_grabando) {
        final path = await _recorder.stop();

        Espectrograma? espectrograma;
        if (path != null) {
          final frames = await buildSpectrogram(path);
          espectrograma = Espectrograma(frames: frames).normalizar();
        }

        setState(() {
          _espectrograma = espectrograma;
          _grabando = false;
        });

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
      });
    } catch (e) {
      debugPrint('Error grabando audio: $e');
    }
  }

  Map<String, dynamic> _serializarEspectrograma(Espectrograma espectrograma) {
    return espectrograma.toJson();
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'texto': _textoController.text.trim(),
      'tipo_palabra': _tipoSeleccionado.name,
      'espectrograma': _espectrograma == null
          ? null
          : _serializarEspectrograma(_espectrograma!),
    };
  }

  Future<void> _prepararPayload() async {
    final texto = _textoController.text.trim();

    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un texto antes de preparar')),
      );
      return;
    }

    if (_espectrograma == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero graba el audio para generar el espectrograma'),
        ),
      );
      return;
    }

    setState(() {
      _preparando = true;
    });

    try {
      final payload = _buildPayload();
      debugPrint(jsonEncode(payload));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payload preparado en consola')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _preparando = false;
        });
      }
    }
  }

  Future<void> _enviarPlaceholder() async {
    final payload = _buildPayload();

    if (_espectrograma == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero graba el audio para crear el espectrograma'),
        ),
      );
      return;
    }

    debugPrint('Aquí irá el POST a Rails:');
    debugPrint(jsonEncode(payload));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listo para conectar con Rails')),
    );
  }

  @override
  void dispose() {
    _textoController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payloadPreview = const JsonEncoder.withIndent('  ').convert(_buildPayload());

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.satellite_alt),
            SizedBox(width: 10),
            Text('TRANSMISIÓN DE AUDIO'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF1A1A3A), Color(0xFF050510)],
            radius: 1.5,
            center: Alignment.topLeft,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPanel(
                titulo: "PARÁMETROS DE SEÑAL",
                icono: Icons.settings_input_component,
                child: Column(
                  children: [
                    TextField(
                      controller: _textoController,
                      style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace'),
                      decoration: const InputDecoration(
                        labelText: 'Mensaje de Texto',
                        hintText: 'Ingresa los datos a transmitir...',
                        prefixIcon: Icon(Icons.text_fields, color: Colors.cyanAccent),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TipoPalabra>(
                      value: _tipoSeleccionado,
                      dropdownColor: const Color(0xFF1A1A2E),
                      style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace'),
                      decoration: const InputDecoration(
                        labelText: 'Clasificación',
                        prefixIcon: Icon(Icons.category, color: Colors.cyanAccent),
                      ),
                      items: TipoPalabra.values
                          .map((tipo) => DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo.label.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _tipoSeleccionado = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildPanel(
                titulo: "MÓDULO DE CAPTURA",
                icono: Icons.mic,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _toggleGrabacion,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _grabando ? Colors.redAccent.withOpacity(0.2) : Colors.cyanAccent.withOpacity(0.1),
                          border: Border.all(
                            color: _grabando ? Colors.redAccent : Colors.cyanAccent,
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
                                color: Colors.cyanAccent.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: Icon(
                          _grabando ? Icons.stop : Icons.mic_none,
                          size: 40,
                          color: _grabando ? Colors.redAccent : Colors.cyanAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _grabando ? "GRABANDO SEÑAL..." : "INICIAR CAPTURA",
                      style: TextStyle(
                        color: _grabando ? Colors.redAccent : Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _espectrograma == null ? Colors.black45 : Colors.greenAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _espectrograma == null ? Colors.white24 : Colors.greenAccent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _espectrograma == null ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                            color: _espectrograma == null ? Colors.orangeAccent : Colors.greenAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _espectrograma == null
                                ? 'Espectrograma: OFFLINE'
                                : 'Espectrograma: ONLINE (${_espectrograma!.numeroFrames} frames)',
                            style: TextStyle(
                              color: _espectrograma == null ? Colors.orangeAccent : Colors.greenAccent,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _preparando ? null : _prepararPayload,
                      icon: _preparando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
                            )
                          : const Icon(Icons.memory),
                      label: Text(_preparando ? 'PROCESANDO...' : 'ENCRIPTAR DATOS', style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _enviarPlaceholder,
                      icon: const Icon(Icons.send),
                      label: const Text('TRANSMITIR', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.2),
                        side: const BorderSide(color: Colors.deepPurpleAccent),
                        foregroundColor: Colors.deepPurpleAccent,
                        shadowColor: Colors.deepPurpleAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildPanel(
                titulo: "REGISTRO DE DATOS (PAYLOAD)",
                icono: Icons.code,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                  ),
                  child: SelectableText(
                    payloadPreview,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.greenAccent,
                      fontSize: 12,
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