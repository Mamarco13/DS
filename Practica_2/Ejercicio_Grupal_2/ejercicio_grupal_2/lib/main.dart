import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/gemini_service.dart';
import 'screens/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /*IMPORTANTE:
  Crear .env a la altura del REAdME(no quiero subir la clave API a GitHub para intentar ponerlo publico)
  y poner dentro API_KEY = "laquesea"
  Si no, no te va funcionar*/
  await dotenv.load(fileName: ".env");

  final apiKey = dotenv.env['API_KEY'];

  final geminiService = GeminiService(apiKey!);

  runApp(MyApp(geminiService: geminiService));
}

class MyApp extends StatelessWidget {
  final GeminiService geminiService;

  const MyApp({super.key, required this.geminiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardian Chat',
      home: ChatScreen(geminiService: geminiService),
    );
  }
}