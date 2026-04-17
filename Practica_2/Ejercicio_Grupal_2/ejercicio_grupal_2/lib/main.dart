import 'package:ejercicio_grupal_2/models/secret_keeper.dart';
import 'package:ejercicio_grupal_2/services/basic_secret_keeper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/gemini_service.dart';
import 'screens/chat_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final apiKey = dotenv.env['API_KEY'];

  final geminiService = GeminiService(apiKey!);
  final secretKeeper = BasicSecretKeeper(geminiService, "matricula de honor");

  runApp(MyApp(secretKeeper: secretKeeper));
}

class MyApp extends StatelessWidget {
  final SecretKeeper secretKeeper;

  const MyApp({super.key, required this.secretKeeper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardian Chat',
      home: ChatScreen(secretKeeper: secretKeeper),
    );
  }
}