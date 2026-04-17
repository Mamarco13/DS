import 'package:ejercicio_grupal_2/models/secret_keeper.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {

  final SecretKeeper secretKeeper;

  const ChatScreen({super.key, required this.secretKeeper});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();final List<Map<String, String>> messages = [];
  bool isLoading = false;

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

  // Manu: Ten en cuenta que luego los mensajes seran tuplas con quien habla y que dice, yo lo veo util para
  //meter el decorator, si quieres ahorrar en lineas de codigo dime y cambiamos

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
      appBar: AppBar(
        title: const Text("Chat de prueba"),
      ),
      body: Column(
        children: [
          // Mensajes
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
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          // Input
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Escribe un mensaje...",
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