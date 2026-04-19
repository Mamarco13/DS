import 'package:flutter/material.dart';
import '../models/secret_keeper.dart';

class ChatScreen extends StatefulWidget {
  // Instancia de SecretKeeper (puede estar decorada según el nivel)
  final SecretKeeper secretKeeper;

  const ChatScreen({super.key, required this.secretKeeper});

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

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg["text"]!,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Guardian")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Escribe...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}