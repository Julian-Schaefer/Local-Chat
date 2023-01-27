// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:frontend/message.dart';
import 'package:get_it/get_it.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:cryptography_flutter/cryptography_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'chat_list_screen.dart';

void main() async {
  FlutterCryptography.enable();
  await Hive.initFlutter();
  Hive.registerAdapter(MessageAdapter());
  (await Hive.openBox("chats")).clear();
  (await Hive.openBox("settings")).clear();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    var socket = io.io(
        'http://localhost:8081',
        io.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM;
            .disableAutoConnect() // disable auto-connection
            .build());

    GetIt.I.registerSingleton<io.Socket>(socket);
    socket = socket.connect();

    socket.onConnect((_) {
      print('Connection established');

      var userName =
          Hive.box("settings").get("username", defaultValue: null) as String?;

      if (userName != null) {
        Map<String, dynamic> loginMsg = {
          'userName': userName,
        };
        socket.emit("login", loginMsg);
      }
    });
    socket.onDisconnect((_) => print('Connection Disconnection'));
    socket.onConnectError((err) => print(err));
    socket.onError((err) => print(err));

    socket.on('message', (data) async {
      var msgJson = data[0] as Map<String, dynamic>;
      var msg = Message.fromJson(msgJson);
      if (await Hive.boxExists(msg.sender)) {
        await Hive.box(msg.sender).add(msg);
      } else {
        var box = await Hive.openBox(msg.sender);
        await box.add(msg);
      }

      await Hive.box("chats").put(
        msg.sender,
        msg.sender,
      );

      final dataList = data as List;
      final ack = dataList.last as Function;
      ack("ok");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Chat',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const ChatListScreen(title: 'Local Chat'),
    );
  }
}
