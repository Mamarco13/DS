import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/secret_keeper.dart';
import '../services/basic_secret_keeper.dart';
import '../decorators/keyword_block_decorator.dart';
import '../decorators/length_limit_decorator.dart';
import '../decorators/strong_system_prompt_decorator.dart';
import 'chat_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  // Construye dinámicamente el SecretKeeper aplicando decoradores según el nivel
  SecretKeeper buildKeeper(int level, String apiKey) {
    // Base SIEMPRE: comportamiento básico del guardián
    SecretKeeper keeper = BasicSecretKeeper(apiKey, "matricula de honor");

    // Nivel 2: añade un prompt más estricto (modifica el comportamiento de la IA)
    if (level >= 2) {
      keeper = StrongSystemPromptDecorator(keeper);
    }

    // Nivel 3: añade filtros de entrada (bloqueo de palabras y faltas)
    if (level >= 3) {
      keeper = KeywordBlockDecorator(keeper);
    }

    // A partir del nivel 2: limita la longitud del mensaje
    // Debe ir el último para ejecutarse el primero (orden del Decorator)
    if (level >= 2) {
      keeper = LengthLimitDecorator(keeper);
    }

    return keeper;
  }

  // Inicia el chat creando el SecretKeeper correspondiente al nivel seleccionado
  void startChat(BuildContext context, int level) {
    final apiKey = dotenv.env['API_KEY']!;
    final keeper = buildKeeper(level, apiKey);


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(secretKeeper: keeper),
      ),
    );
  }

  // Construye un botón para cada nivel de dificultad
  Widget buildButton(
      BuildContext context, String text, int level, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(
              horizontal: 30, vertical: 15),
        ),
        onPressed: () => startChat(context, level),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona nivel")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildButton(
              context,
              "Nivel 1 - Básico 😴",
              1,
              Colors.green,
            ),
            buildButton(
              context,
              "Nivel 2 - Mejorado 😐",
              2,
              Colors.orange,
            ),
            buildButton(
              context,
              "Nivel 3 - Difícil 😈",
              3,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}