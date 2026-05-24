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

    if (path == null) {

      return const Text(
        "Sin grabar",
      );

    }

    return const Text(
      "Audio grabado",
    );
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Comparador de Audio",
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            // AUDIO 1

            ElevatedButton(

              onPressed: _grabarAudio1,

              child: Text(

                grabando1
                    ? "Detener Audio 1"
                    : "Grabar Audio 1",

              ),
            ),

            const SizedBox(height: 10),

            estadoAudio(audio1),

            const SizedBox(height: 30),

            // AUDIO 2

            ElevatedButton(

              onPressed: _grabarAudio2,

              child: Text(

                grabando2
                    ? "Detener Audio 2"
                    : "Grabar Audio 2",

              ),
            ),

            const SizedBox(height: 10),

            estadoAudio(audio2),

            const SizedBox(height: 40),

            // SELECTOR

            DropdownButton<String>(

              value: comparadorSeleccionado,

              items: const [

                DropdownMenuItem(
                  value: "coseno",
                  child: Text("Coseno"),
                ),

                DropdownMenuItem(
                  value: "mfcc",
                  child: Text("MFCC"),
                ),

              ],

              onChanged: (v) {

                setState(() {

                  comparadorSeleccionado = v!;

                });

              },
            ),

            const SizedBox(height: 30),

            // COMPARAR

            ElevatedButton(

              onPressed: compararAudios,

              child: const Text(
                "Comparar Audios",
              ),
            ),

            const SizedBox(height: 40),

            // RESULTADOS

            if (similitud != null)

              Text(

                "Similitud: ${(similitud! * 100).toStringAsFixed(2)}%",

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 20),

            if (sonParecidos != null)

              Text(

                sonParecidos!
                    ? "Son similares"
                    : "No son similares",

                style: TextStyle(
                  fontSize: 22,
                  color: sonParecidos!
                      ? Colors.green
                      : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}