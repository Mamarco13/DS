import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/pantalla_suscripciones.dart';
import 'gestor_suscripciones.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GestorSuscripciones(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PantallaSuscripciones(),
    );
  }
}