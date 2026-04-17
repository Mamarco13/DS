import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/basic_secret_keeper.dart';
import 'decorators/keyword_block_decorator.dart';
import 'screens/chat_screen.dart';
import 'models/secret_keeper.dart';

import 'package:google_generative_ai/google_generative_ai.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final apiKey = dotenv.env['API_KEY'];

  final secretKeeper = BasicSecretKeeper(
    apiKey!,
    "matricula de honor",
  );

  //secretKeeper = KeywordBlockDecorator(secretKeeper);

  runApp(MyApp(secretKeeper: secretKeeper));
}

class MyApp extends StatelessWidget {
  final SecretKeeper secretKeeper;

  const MyApp({super.key, required this.secretKeeper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(secretKeeper: secretKeeper),
    );
  }
}