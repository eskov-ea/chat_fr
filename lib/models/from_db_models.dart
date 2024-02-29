import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'dart:developer';



class DialogDataDB {

  final int dialogId;
  final String name;
  final String? description;
  final int dialogAuthorId;
  final int? lastMessageId;
  final bool isClosed;
  final bool isPublic;
  final int messageCount;
  final String? picture;
  final String createdAt;
  final String updatedAt;
  final String chatTypeName;
  final List<int> usersList;
  final int chatTypeId;
  final int p2p;
  final int readonly;
  final int secure;
  final String? chatTypePicture;
  final String? chatTypeDescription;


  DialogDataDB({
    required this.dialogId,
    required this.chatTypeName,
    required this.dialogAuthorId,
    required this.usersList,
    required this.name,
    required this.description,
    required this.lastMessageId,
    required this.messageCount,
    required this.picture,
    required this.isClosed,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.chatTypeId,
    required this.p2p,
    required this.secure,
    required this.readonly,
    required this.chatTypePicture,
    required this.chatTypeDescription
  });

  static DialogDataDB fromJson(json) {
    try {
      return DialogDataDB(
          dialogId: json["id"],
          name: json["name"],
          description: json["description"],
          chatTypeName: json["chat_type_name"],
          dialogAuthorId: json["author_id"],
          usersList: json["chat_users"].toString().split(',').map(int.parse).toList(),
          lastMessageId: json["message_id"],
          messageCount: json["message_count"],
          picture: json["picture"],
          createdAt: json["created_at"],
          updatedAt: json["updated_at"],
          isClosed: json["is_closed"] == 1 ? true : false,
          isPublic: json["is_public"] == 1 ? true : false,
          chatTypeId: json["chat_type_id"],
          p2p: json["chat_type_p2p"],
          secure: json["chat_type_secure"],
          readonly: json["chat_type_readonly"],
          chatTypePicture: json["chat_type_picture"],
          chatTypeDescription: json["chat_type_description"]
      );
    } catch (err, stack) {
      log('DB operational error:: $err \r\n $stack');
      rethrow;
    }
  }

}
