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

  // Colores del tema medieval
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color darkRedColor = Color(0xFF8B0000);
  static const Color stoneColor = Color(0xFF5C5C5C);
  static const Color torchColor = Color(0xFFFF8C00);

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
        builder: (_) => ChatScreen(secretKeeper: keeper, level: level),
      ),
    );
  }

  // Construye una tarjeta para cada nivel de dificultad
  Widget buildLevelCard(BuildContext context, String location, String description,
      int level, Color borderColor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: GestureDetector(
        onTap: () => startChat(context, level),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 3),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[900],
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono Medieval
                Container(
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    icon,
                    size: 32,
                    color: borderColor,
                  ),
                ),
                const SizedBox(width: 16),
                // Contenido de texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: borderColor,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[300],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: borderColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Nivel $level',
                          style: TextStyle(
                            fontSize: 11,
                            color: borderColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Flecha
                Icon(
                  Icons.arrow_forward_ios,
                  color: borderColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: darkRedColor,
        elevation: 0,
        title: Column(
          children: [
            Text(
              "OBJETIVO: ENCONTRAR LA PALABRA SECRETA",
              style: TextStyle(
                color: goldColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "Interroga a los guardias del castillo",
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[900]!,
              Colors.black,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Título descriptivo
                Text(
                  "Elige tu destino en el castillo",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: goldColor,
                    fontFamily: 'Georgia',
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Cada ubicación presenta guardias con diferentes niveles de vigilancia",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Tarjeta Nivel 1
                buildLevelCard(
                  context,
                  "1 - Muralla Exterior",
                  "Guardias principiantes con defensa básica",
                  1,
                  Colors.green[400]!,
                  Icons.shield,
                ),
                // Tarjeta Nivel 2
                buildLevelCard(
                  context,
                  "2 - Torre de Guardia",
                  "Guardias experimentados con alguna debilidad",
                  2,
                  Color(0xFFFFA500), // Naranja
                  Icons.castle_outlined,
                ),
                // Tarjeta Nivel 3
                buildLevelCard(
                  context,
                  "3 - Sala del Trono",
                  "Guardia maestro con defensas avanzadas y filtros de seguridad",
                  3,
                  darkRedColor,
                  Icons.diamond,
                ),
                const SizedBox(height: 30),
                // Footer medieval
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: goldColor, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[900],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "INFORMACIÓN IMPORTANTE",
                        style: TextStyle(
                          color: goldColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Los guardias protegen un secreto. "
                        "¿Conseguirás hacerles revelar la información?\n"
                        "Contraseña disponible en la memoria",
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 12,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}