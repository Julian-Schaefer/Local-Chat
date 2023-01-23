import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final messageController = TextEditingController();
  final String chat;

  ChatScreen({super.key, required this.chat});

  _sendMessage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(chat),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              SizedBox(
                width: 500,
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a message',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _sendMessage, child: const Text('Send'))
            ])));
  }
}
