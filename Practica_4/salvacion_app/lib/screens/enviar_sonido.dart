import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../src/api/espectrograma.dart';
import '../src/api/fft.dart';
import '../src/api/api_client.dart';
import '../src/widgets/language_selector.dart';

enum TipoPalabra { verbo, sustantivo, adjetivo, pronombre, adverbio, otro}

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
      case TipoPalabra.adverbio:
        return 'Adverbio';
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
  final TextEditingController _lenguajeController = TextEditingController(text: "MiLenguaje");

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

  Future<void> _enviarARails() async {
    if (_espectrograma == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero graba el audio para crear el espectrograma'),
        ),
      );
      return;
    }

    final texto = _textoController.text.trim();
    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un texto antes de enviar')),
      );
      return;
    }

    setState(() {
      _preparando = true;
    });

    try {
      final client = RailsApiClient();
      final nombreLenguaje = _lenguajeController.text.trim();
      if (nombreLenguaje.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escribe un nombre para el lenguaje')),
        );
        setState(() { _preparando = false; });
        return;
      }

      int? langId = await client.obtenerLenguajeId(nombreLenguaje);
      if (langId == null) {
        final creado = await client.crearLenguaje(nombreLenguaje);
        if (creado) {
          langId = await client.obtenerLenguajeId(nombreLenguaje);
        }
      }

      if (langId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No se pudo obtener o crear el lenguaje')),
        );
        return;
      }

      // La duración en segundos (approx) del espectrograma, se puede calcular 
      // asumiendo 44100 / window size. Por ahora pondremos un estimado según frames o 1.0.
      // O si preferimos, la duración se extrae de otra forma, pero según el backend espera un double.
      double duracion = _espectrograma!.numeroFrames / 100.0; // aprox

      final exito = await client.anadirPalabra(
        langId,
        texto,
        _tipoSeleccionado.name,
        duracion,
        _espectrograma!,
      );

      if (!mounted) return;
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Palabra guardada exitosamente en la BD')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la palabra')),
        );
      }
    } catch (e) {
      debugPrint('Error en envío: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excepción durante el envío a Rails')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _preparando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _textoController.dispose();
    _lenguajeController.dispose();
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
            LanguageSelector(controller: _lenguajeController),
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
              onPressed: _preparando ? null : _enviarARails,
              child: const Text('Enviar palabra a Rails'),
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