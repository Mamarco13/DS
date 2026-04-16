import 'package:ejercicio_grupal_2/models/secret_keeper.dart';
import 'package:ejercicio_grupal_2/services/basic_secret_keeper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/gemini_service.dart';
import 'screens/chat_screen.dart';


// BORRAR ANTES DE ENTREGAR:
// Los comentarios que son modificaciones del código de Manu --> Ana
// Los comentarios en los que he puesto Manu:


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  /* Manu: Crear .env a la altura del REAdME(no quiero subir la clave API a GitHub para intentar ponerlo publico)
  y poner dentro API_KEY = "laquesea"
  Si no, no te va funcionar*/
  await dotenv.load(fileName: ".env");

  final apiKey = dotenv.env['API_KEY'];

  final geminiService = GeminiService(apiKey!);
  // Añadido: 
  final secretKeeper = BasicSecretKeeper(geminiService, "matricula de honor");

  //runApp(MyApp(geminiService: geminiService));
  runApp(MyApp(secretKeeper: secretKeeper));
}

class MyApp extends StatelessWidget {
  //final GeminiService geminiService;
  final SecretKeeper secretKeeper;

  const MyApp({super.key, required this.secretKeeper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardian Chat',
      //home: ChatScreen(geminiService: geminiService),
      home: ChatScreen(secretKeeper: secretKeeper),
    );
  }
}