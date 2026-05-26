import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../src/api/comparador.dart';
import '../src/api/espectrograma.dart';
import '../src/api/fft.dart';

class ComparadorAudioScreen extends StatefulWidget {
  const ComparadorAudioScreen({super.key});

  @override
  State<ComparadorAudioScreen> createState() =>
      _ComparadorAudioScreenState();
}

class _ComparadorAudioScreenState
    extends State<ComparadorAudioScreen> {

  final AudioRecorder _recorder = AudioRecorder();

  String? audio1;
  String? audio2;

  bool grabando1 = false;
  bool grabando2 = false;

  double? similitud;
  bool? sonParecidos;

  String comparadorSeleccionado = "coseno";

  // =========================
  // AUDIO 1
  // =========================

  Future<String> _rutaAudio(String nombre) async {

    final dir = await getTemporaryDirectory();

    return "${dir.path}/$nombre.wav";
  }

  Future<void> _grabarAudio1() async {

    try {

      // DETENER
      if (grabando1) {

        final path = await _recorder.stop();

        print("Audio1 guardado:");
        print(path);

        setState(() {

          audio1 = path;
          grabando1 = false;

        });

        return;
      }

      // PERMISOS
      final permiso = await _recorder.hasPermission();

      if (!permiso) {

        print("Sin permisos");

        return;
      }

      // RUTA REAL
      final path = await _rutaAudio("audio1");

      print(path);

      // START
      await _recorder.start(

        const RecordConfig(

          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,

        ),

        path: path,

      );

      setState(() {

        grabando1 = true;

      });

    } catch (e) {

      print("ERROR AUDIO1");
      print(e);

    }
  }
  // =========================
  // AUDIO 2
  // =========================

  Future<void> _grabarAudio2() async {

    try {

      // DETENER
      if (grabando2) {

        final path = await _recorder.stop();

        print("Audio2 guardado:");
        print(path);

        setState(() {

          audio2 = path;
          grabando2 = false;

        });

        return;
      }

      // PERMISOS
      final permiso = await _recorder.hasPermission();

      if (!permiso) {

        print("Sin permisos");

        return;
      }

      // RUTA REAL
      final path = await _rutaAudio("audio2");

      print(path);

      // START
      await _recorder.start(

        const RecordConfig(

          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,

        ),

        path: path,

      );

      setState(() {

        grabando2 = true;

      });

    } catch (e) {

      print("ERROR AUDIO2");
      print(e);

    }
  }
  // =========================
  // COMPARAR AUDIOS
  // =========================

  Future<void> compararAudios() async {

    try {

      if (audio1 == null || audio2 == null) {

        print("Faltan audios");

        return;
      }

      print("Construyendo espectrograma 1");

      final frames1 = await buildSpectrogram(audio1!);

      print("Construyendo espectrograma 2");

      final frames2 = await buildSpectrogram(audio2!);

      final espectro1 = Espectrograma(
        frames: frames1,
      ).normalizar();

      final espectro2 = Espectrograma(
        frames: frames2,
      ).normalizar();

      espectro1.debugResumen("AUDIO 1");

      espectro2.debugResumen("AUDIO 2");

      Comparador comparador;

      if (comparadorSeleccionado == "mfcc") {

        comparador = ComparadorMFCC();

      } else {

        comparador = ComparadorCoseno();

      }

      final s = comparador.similitud(
        espectro1,
        espectro2,
      );

      final iguales = comparador.comparar(
        espectro1,
        espectro2,
      );

      setState(() {

        similitud = s;
        sonParecidos = iguales;

      });

      print("Similitud:");
      print(s);

    } catch (e) {

      print("ERROR COMPARACION");
      print(e);

    }
  }

  // =========================
  // ESTADO AUDIO
  // =========================

  Widget estadoAudio(String? path) {
    final hasAudio = path != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          hasAudio ? Icons.check_circle_outline : Icons.warning_amber_rounded,
          color: hasAudio ? Colors.greenAccent : Colors.orangeAccent,
          size: 14,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            hasAudio ? "SEÑAL OK" : "SIN SEÑAL",
            style: TextStyle(
              color: hasAudio ? Colors.greenAccent : Colors.orangeAccent,
              fontFamily: 'monospace',
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.radar),
            SizedBox(width: 10),
            Text('ANÁLISIS DE FRECUENCIAS'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildAudioModule(
                      titulo: "FUENTE ALPHA",
                      grabando: grabando1,
                      path: audio1,
                      onTap: _grabarAudio1,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAudioModule(
                      titulo: "FUENTE BETA",
                      grabando: grabando2,
                      path: audio2,
                      onTap: _grabarAudio2,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildPanel(
                titulo: "ALGORITMO DE COMPARACIÓN",
                icono: Icons.memory,
                child: DropdownButtonFormField<String>(
                  value: comparadorSeleccionado,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.functions, color: Colors.cyanAccent),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "coseno",
                      child: Text("DISTANCIA COSENO"),
                    ),
                    DropdownMenuItem(
                      value: "mfcc",
                      child: Text("COEFICIENTES MFCC"),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      comparadorSeleccionado = v!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: compararAudios,
                icon: const Icon(Icons.analytics),
                label: const Text('EJECUTAR ANÁLISIS'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 24),
              if (similitud != null && sonParecidos != null)
                _buildResultsPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioModule({
    required String titulo,
    required bool grabando,
    required String? path,
    required VoidCallback onTap,
    required Color color,
  }) {
    return _buildPanel(
      titulo: titulo,
      icono: Icons.graphic_eq,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: grabando ? Colors.redAccent.withOpacity(0.2) : color.withOpacity(0.1),
                border: Border.all(
                  color: grabando ? Colors.redAccent : color,
                  width: grabando ? 4 : 2,
                ),
                boxShadow: [
                  if (grabando)
                    BoxShadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 5)
                  else
                    BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Icon(
                grabando ? Icons.stop : Icons.mic_none,
                size: 30,
                color: grabando ? Colors.redAccent : color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          estadoAudio(path),
        ],
      ),
    );
  }

  Widget _buildResultsPanel() {
    final match = sonParecidos!;
    final color = match ? Colors.greenAccent : Colors.redAccent;
    final text = match ? "COINCIDENCIA CONFIRMADA" : "DESVIACIÓN DETECTADA";

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            match ? Icons.verified_user : Icons.gpp_bad,
            color: color,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            "SIMILITUD: ${(similitud! * 100).toStringAsFixed(2)}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel({required String titulo, required IconData icono, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111122).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: Colors.cyanAccent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
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