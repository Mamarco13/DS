import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/level_selection_screen.dart';

Future<void> main() async {
  // Necesario para usar código async antes de runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Carga variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicia la aplicación Flutter
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Oculta el banner de debug
      debugShowCheckedModeBanner: false,

      // Pantalla inicial de la app
      home: LevelSelectionScreen(),
    );
  }
}