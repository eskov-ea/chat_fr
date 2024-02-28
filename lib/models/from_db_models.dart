import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'dart:developer';



class DialogDataDB {

  final int dialogId;
  final String name;
  final String? description;
  final int dialogAuthorId;
  final int lastMessageId;
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
          lastMessageId: json["message"],
          messageCount: json["message_count"],
          picture: json["picture"],
          createdAt: json["created_at"],
          updatedAt: json["updated_at"],
          isClosed: json["is_closed"],
          isPublic: json["is_public"],
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


class ChatUserDB {
  final int chatId;
  final int userId;
  final int chatUserRole;
  final int active;

  ChatUserDB({
    required this.chatId,
    required this.userId,
    required this.chatUserRole,
    required this.active
  });


  static ChatUserDB fromJson(json) {
    try {
      return ChatUserDB(
          chatId: json["chat_id"],
          userId: json["user_id"],
          chatUserRole: json["chat_user_role_id"],
          active: json["active"],
      );
    } catch (err, stack) {
      throw AppErrorException(AppErrorExceptionType.parsing, message: "Error happend parsing: $json\r\n$stack");
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ChatUserDB &&
            runtimeType == other.runtimeType &&
            other.active == active &&
            other.userId == userId;
  }
  int get hashCode => runtimeType.hashCode ^ userId.hashCode ^ active.hashCode;

  @override
  String toString() {
    return "Instance of ChatUser [ $chatId, $userId ]";
  }

}