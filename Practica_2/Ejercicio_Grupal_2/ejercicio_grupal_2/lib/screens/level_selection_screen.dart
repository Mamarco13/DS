import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/secret_keeper.dart';
import '../services/basic_secret_keeper.dart';
import '../decorators/keyword_block_decorator.dart';
import '../decorators/dummy_decorator.dart';
import 'chat_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  SecretKeeper buildKeeper(int level, String apiKey) {
    SecretKeeper keeper =
    BasicSecretKeeper(apiKey, "matricula de honor");

    if (level >= 2) {
      // 🔸 Decorators vacíos de momento
      keeper = DummyDecorator(keeper);
      keeper = DummyDecorator(keeper);
    }

    if (level >= 3) {
      keeper = KeywordBlockDecorator(keeper);
    }

    return keeper;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona nivel")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => startChat(context, 1),
              child: const Text("Nivel 1 (fácil 😴)"),
            ),
            ElevatedButton(
              onPressed: () => startChat(context, 2),
              child: const Text("Nivel 2 (medio 😐)"),
            ),
            ElevatedButton(
              onPressed: () => startChat(context, 3),
              child: const Text("Nivel 3 (difícil 😈)"),
            ),
          ],
        ),
      ),
    );
  }
}