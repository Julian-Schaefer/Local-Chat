import 'package:flutter/material.dart';
import 'package:frontend/message.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatScreen extends StatefulWidget {
  final String receiver;

  const ChatScreen({super.key, required this.receiver});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  late Box chatBox;
  late io.Socket socket;
  late String userName;

  @override
  void initState() {
    super.initState();
    chatBox = Hive.box(widget.receiver);
    socket = GetIt.I.get<io.Socket>();

    userName = Hive.box("settings").get("username") as String;
  }

  void _sendMessage() {
    var msg = Message(userName, widget.receiver, messageController.text);

    socket.emitWithAck('message', msg.toJson(), ack: (data) async {
      if (data != null && data is String && data == "ok") {
        await chatBox.add(msg);
        setState(() {
          messageController.text = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.receiver),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              SizedBox(
                  width: 500,
                  height: 600,
                  child: ValueListenableBuilder<Box>(
                      valueListenable: chatBox.listenable(),
                      builder: (context, box, widget) {
                        return ListView.builder(
                            itemCount: box.length,
                            itemBuilder: ((context, index) {
                              var msg = box.getAt(index) as Message;
                              var indicator =
                                  msg.receiver == userName ? "From" : "To";
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "$indicator ${msg.receiver}: ${msg.message}"),
                                ),
                              );
                            }));
                      })),
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
