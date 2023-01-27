import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final usernameController = TextEditingController();
  final receiverController = TextEditingController();
  final messageController = TextEditingController();
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    socket = GetIt.I.get<io.Socket>();
  }

  void _login() {
    Map<String, dynamic> loginMsg = {
      'userName': usernameController.text,
    };
    socket.emitWithAck('login', loginMsg, ack: (data) {
      if (data != null && data is String && data == "ok") {
        setState(() {
          Hive.box("settings").put("username", usernameController.text);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var userName =
        Hive.box("settings").get("username", defaultValue: null) as String?;

    if (userName == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              const Text("Please enter Username:"),
              const SizedBox(height: 20),
              SizedBox(
                width: 500,
                child: TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter username',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text('Log in'))
            ])),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Your Username:',
              ),
              Text(
                userName,
                style: Theme.of(context).textTheme.headline4,
              ),
              const SizedBox(height: 20),
              const ChatList()
            ],
          ),
        ));
  }
}

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  var chatBox = Hive.box("chats");

  _createChat() async {
    var controller = TextEditingController();

    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Create new Chat'),
              content: TextField(
                controller: controller,
                decoration:
                    const InputDecoration(hintText: "Enter Reveiver ID"),
              ),
              actions: <Widget>[
                OutlinedButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
                OutlinedButton(
                  child: const Text('OK'),
                  onPressed: () {
                    setState(() {
                      var receiver = controller.text;
                      chatBox
                          .put(
                            receiver,
                            receiver,
                          )
                          .then((value) => Hive.openBox(receiver).then((value) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                          receiver: controller.text)),
                                );
                              }));
                    });
                  },
                ),
              ],
            ));
  }

  _deleteChat(String chat) async {
    await chatBox.delete(chat);
    await Hive.deleteBoxFromDisk(chat);
  }

  _chatSelected(String chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(receiver: chat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ElevatedButton(onPressed: _createChat, child: const Text('New Chat')),
        const SizedBox(height: 20),
        ValueListenableBuilder<Box>(
            valueListenable: chatBox.listenable(),
            builder: (context, box, widget) {
              return SizedBox(
                width: 500,
                height: 500,
                child: ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (BuildContext context, int index) {
                      var chat = box.getAt(index);
                      return Card(
                          child: ListTile(
                        onTap: () => _chatSelected(chat),
                        title: Text(chat),
                        trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteChat(chat)),
                      ));
                    }),
              );
            }),
      ],
    );
  }
}
