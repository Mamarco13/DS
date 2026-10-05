import 'package:flutter/material.dart';
import 'screens/lenguajes_screen.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Comparador de Audios',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LenguajesScreen(),
    );
  }
}
