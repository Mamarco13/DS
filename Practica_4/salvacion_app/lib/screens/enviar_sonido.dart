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
        title: const Text('Preparar audio para Rails'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textoController,
              decoration: const InputDecoration(
                labelText: 'Texto',
                hintText: 'Escribe aquí el string que quieres enviar',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TipoPalabra>(
              value: _tipoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de palabra',
                border: OutlineInputBorder(),
              ),
              items: TipoPalabra.values
                  .map(
                    (tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _tipoSeleccionado = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _toggleGrabacion,
              child: Text(_grabando ? 'Detener grabación' : 'Grabar audio'),
            ),
            const SizedBox(height: 8),
            Text(
              _espectrograma == null
                  ? 'Sin espectrograma generado'
                  : 'Espectrograma listo: ${_espectrograma!.numeroFrames} frames',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _preparando ? null : _prepararPayload,
              child: Text(_preparando ? 'Preparando...' : 'Preparar payload'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _enviarPlaceholder,
              child: const Text('Simular envío a Rails'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payload preparado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(payloadPreview),
          ],
        ),
      ),
    );
  }
}