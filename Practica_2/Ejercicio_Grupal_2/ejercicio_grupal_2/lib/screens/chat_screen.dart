import 'package:flutter/material.dart';
import '../models/secret_keeper.dart';

class ChatScreen extends StatefulWidget {
  // Instancia de SecretKeeper (puede estar decorada según el nivel)
  final SecretKeeper secretKeeper;
  final int level;

  const ChatScreen({super.key, required this.secretKeeper, required this.level});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Controlador del campo de texto
  final TextEditingController _controller = TextEditingController();

  // Lista de mensajes (usuario y bot)
  final List<Map<String, String>> messages = [];

  // Indica si se está esperando respuesta de la IA
  bool isLoading = false;

  // Colores según el nivel
  Map<String, Color> getLevelColors() {
    switch (widget.level) {
      case 1:
        return {
          'primary': const Color(0xFF2ECC71),
          'secondary': const Color(0xFF27AE60),
          'user': const Color(0xFF27AE60),
          'bot': const Color(0xFFD5F4E6),
          'background': const Color(0xFFF0FDF4),
          'text': Colors.black,
        };
      case 2:
        return {
          'primary': const Color(0xFFFFA500),
          'secondary': const Color(0xFFE67E22),
          'user': const Color(0xFFE67E22),
          'bot': const Color(0xFFFFE8CC),
          'background': const Color(0xFFFFF8F0),
          'text': Colors.black,
        };
      case 3:
        return {
          'primary': const Color(0xFF8B0000),
          'secondary': const Color(0xFFD4AF37),
          'user': const Color(0xFF8B0000),
          'bot': const Color(0xFF333333),
          'background': const Color(0xFF1A1A1A),
          'text': const Color(0xFFD4AF37),
        };
      default:
        return {
          'primary': Colors.blue,
          'secondary': Colors.blueAccent,
          'user': Colors.blue,
          'bot': Colors.grey,
          'background': Colors.white,
          'text': Colors.black,
        };
    }
  }

  String getLevelTitle() {
    switch (widget.level) {
      case 1:
        return '🛡️ Muralla Exterior';
      case 2:
        return '🏰 Torre de Guardia';
      case 3:
        return '👑 Sala del Trono';
      default:
        return 'Chat';
    }
  }

  // Envía un mensaje al guardián
  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      isLoading = true;
    });

    _controller.clear();

    final response = await widget.secretKeeper.ask(text);

    setState(() {
      messages.add({"role": "bot", "text": response});
      isLoading = false;
    });
  }

  // Construye un mensaje en la interfaz
  Widget buildMessage(Map<String, String> msg) {
    final isUser = msg["role"] == "user";
    final colors = getLevelColors();

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? colors['user'] : colors['bot'],
          borderRadius: BorderRadius.circular(16),
          border: widget.level == 3 && !isUser
              ? Border.all(color: colors['secondary']!, width: 2)
              : null,
        ),
        child: Text(
          msg["text"]!,
          style: TextStyle(
            color: isUser ? Colors.white : colors['text'],
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = getLevelColors();

    return Scaffold(
      backgroundColor: colors['background'],
      appBar: AppBar(
        backgroundColor: colors['primary'],
        elevation: 2,
        title: Text(
          getLevelTitle(),
          style: TextStyle(
            color: widget.level == 3 ? colors['secondary'] : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: widget.level == 3 ? colors['secondary'] : Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
              reverse: false,
              padding: const EdgeInsets.only(top: 12, bottom: 12),
            ),
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors['primary']!),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: colors['primary']!,
                  width: 2,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Interroga al guardián...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: colors['primary']!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: colors['primary']!.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: colors['primary']!,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors['primary'],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                      onPressed: sendMessage,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}