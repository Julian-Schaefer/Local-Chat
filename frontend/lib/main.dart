// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Chat',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Local Chat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final usernameController = TextEditingController();
  final receiverController = TextEditingController();
  final messageController = TextEditingController();
  late IO.Socket socket;

  String? userName;
  List<String> messages = [];

  @override
  void initState() {
    super.initState();

    socket = IO.io(
        'http://localhost:8081',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM;
            .disableAutoConnect() // disable auto-connection
            .build());

    socket.connect();

    socket.onConnect((_) {
      print('Connection established');
    });
    socket.onDisconnect((_) => print('Connection Disconnection'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));

    socket.on('message', (data) {
      setState(() {
        messages.add("From: ${data['sender']}: ${data['message']}");
      });
    });
  }

  void _login() {
    Map<String, dynamic> loginMsg = {
      'userName': usernameController.text,
    };
    socket.emitWithAck('login', loginMsg, ack: (data) {
      if (data != null && data is String && data == "ok") {
        setState(() {
          userName = usernameController.text;
        });
      }
    });
  }

  void _sendMessage() {
    Map<String, dynamic> msg = {
      'receiver': receiverController.text,
      'message': messageController.text
    };

    socket.emitWithAck('message', msg, ack: (data) {
      if (data != null && data is String && data == "ok") {
        setState(() {
          messageController.text = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              '$userName',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 500,
              child: TextField(
                controller: receiverController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a receiver',
                ),
              ),
            ),
            const SizedBox(height: 20),
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
            SizedBox(
              width: 500,
              height: 500,
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 50,
                      child: Center(
                          child: Text('Message $index: ${messages[index]}')),
                    );
                  }),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send',
        child: const Text('Send'),
      ),
    );
  }
}
