import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../src/api/espectrograma.dart';
import '../src/api/fft.dart';
import '../src/api/rails_service.dart';

enum TipoPalabra { verbo, sustantivo, adjetivo, pronombre, otro }

extension TipoPalabraX on TipoPalabra {
  String get label {
    switch (this) {
      case TipoPalabra.verbo:      return 'Verbo';
      case TipoPalabra.sustantivo: return 'Sustantivo';
      case TipoPalabra.adjetivo:   return 'Adjetivo';
      case TipoPalabra.pronombre:  return 'Pronombre';
      case TipoPalabra.otro:       return 'Otro';
    }
  }
}

class PrepararAudioRailsScreen extends StatefulWidget {
  final int lenguajeId;

  const PrepararAudioRailsScreen({super.key, required this.lenguajeId});

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
  bool _enviando = false;

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

      setState(() => _grabando = true);
    } catch (e) {
      debugPrint('Error grabando audio: $e');
    }
  }

  Future<void> _enviarARails() async {
    final texto = _textoController.text.trim();

    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un texto')),
      );
      return;
    }

    if (_espectrograma == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero graba el audio')),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      final resultado = await RailsService.crearPalabra(
        lenguajeId: widget.lenguajeId,
        texto: texto,
        tipo: _tipoSeleccionado.name,
        duracion: _espectrograma!.duracionSegundos,
        espectrograma: _espectrograma!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Palabra "${resultado['texto']}" guardada')),
      );

      _textoController.clear();
      setState(() => _espectrograma = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _textoController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir palabra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textoController,
              decoration: const InputDecoration(
                labelText: 'Significado',
                hintText: 'Ej: gustar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TipoPalabra>(
              value: _tipoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de palabra',
                border: OutlineInputBorder(),
              ),
              items: TipoPalabra.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _tipoSeleccionado = v);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _toggleGrabacion,
              icon: Icon(_grabando ? Icons.stop : Icons.mic),
              label: Text(_grabando ? 'Detener grabación' : 'Grabar audio'),
            ),
            const SizedBox(height: 8),
            Text(
              _espectrograma == null
                  ? 'Sin audio grabado'
                  : 'Audio listo: ${_espectrograma!.numeroFrames} frames'
                      ' (${_espectrograma!.duracionSegundos.toStringAsFixed(2)}s)',
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _enviando ? null : _enviarARails,
              child: Text(_enviando ? 'Guardando...' : 'Guardar palabra'),
            ),
          ],
        ),
      ),
    );
  }
}
