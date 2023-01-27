import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 1)
class Message {
  @HiveField(0)
  final String sender;

  @HiveField(1)
  final String receiver;

  @HiveField(2)
  final String message;

  Message(this.sender, this.receiver, this.message);

  Map<String, dynamic> toJson() {
    return {'receiver': receiver, 'message': message};
  }

  static Message fromJson(Map<String, dynamic> json) {
    return Message(json["sender"], json["receiver"], json["message"]);
  }
}
