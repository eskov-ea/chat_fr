import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/services/helpers/dates.dart';
import 'package:chat/services/helpers/message_forwarding_util.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import '../services/global.dart';
import 'message_model.dart';



class DialogData {

  final int dialogId;
  final DialogType chatType;
  final int dialogAuthorId;
  //TODO: manage user list to <UserProfileData>
  MessageData? lastMessage;
  final String name;
  final String? description;
  final int messageCount;
  final List<int> users;
  final List<ChatUser> chatUsers;
  final DateTime? createdAt;
  final int isClosed;
  final int isPublic;
  final String? picture;

  DialogData({
    required this.dialogId,
    required this.chatType,
    required this.dialogAuthorId,
    required this.name,
    required this.description,
    required this.lastMessage,
    required this.messageCount,
    required this.users,
    required this.chatUsers,
    required this.picture,
    required this.isClosed,
    required this.isPublic,
    required this.createdAt
  });

  static DialogData fromJson(json) {
    try {
      return DialogData(
          dialogId: json["id"],
          name: json["name"],
          description: json["description"],
          chatType: DialogType.fromJson(json["chat_type"]),
          dialogAuthorId: json["user"]["id"],
          lastMessage: json["message"] == null
              ? null
              : MessageData.fromJson(json["message"]),
          messageCount: json["message_count"],
          picture: json["picture"],
          createdAt: DateTime.tryParse(json["created_at"]),
          isClosed: json["is_closed"],
          isPublic: json["is_public"],
          users: json["chat_users"].map<int>((chatUser) => ChatUser.fromJson(chatUser).userId).toList(),
          chatUsers: json["chat_users"]
            .map<ChatUser>((chatUser) => ChatUser.fromJson(chatUser))
            .toList()
          );
    } catch (err, stack) {
      throw AppErrorException(AppErrorExceptionType.parsing, message: "Error happend parsing: $json\r\n$stack");
    }
  }

  static DialogData fromDBJson(json) {
    try {
      return DialogData(
          dialogId: json["id"],
          name: json["name"],
          description: json["description"],
          chatType: DialogType.fromDBJson(json),
          dialogAuthorId: json["author_id"],
          lastMessage: json["message_id"] == null
              ? null
              : MessageData.fromDBJson(json),
          messageCount: json["message_count"],
          picture: json["picture"],
          createdAt: DateTime.tryParse(json["created_at"]),
          isClosed: json["is_closed"],
          isPublic: json["is_public"],
          chatUsers: [],
          users: json["chat_users"].toString().split(',').map(int.parse).toList(),
      );
    } catch (err, stack) {
      print('DB operational error:: $json \r\n $err \r\n $stack');
      rethrow;
    }
  }



  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DialogData &&
            runtimeType == other.runtimeType &&
            listEquals(users, other.users) &&
            users.length == other.users.length &&
            other.dialogId == dialogId;
  }
  @override
  int get hashCode => runtimeType.hashCode ^ users.length.hashCode ^ users.hashCode ^ dialogId.hashCode;

  @override
  String toString() {
    return "Instance of 'DialogData: chatUsers: $chatUsers'";
  }

}

class DialogType {
  const DialogType(
      {required this.typeId,
      required this.typeName,
      required this.p2p,
      required this.secure,
      required this.readonly,
      required this.picture,
      required this.description});
  final int typeId;
  final String typeName;
  final int p2p;
  final int secure;
  final int readonly;
  final String? picture;
  final String? description;

  static DialogType fromJson(json) {
    try {
      return DialogType(
          typeId: json["id"],
          typeName: json["name"],
          p2p: json["p2p"],
          secure: json["secure"],
          readonly: json["readonly"],
          picture: json["picture"],
          description: json["description"]);
    } catch (err, stack) {
      throw AppErrorException(AppErrorExceptionType.parsing, message: "Error happend parsing: $json\r\n$stack");
    }
  }

  static DialogType fromDBJson(json) {
    try {
      return DialogType(
          typeId: json["chat_type_id"],
          typeName: json["chat_type_name"],
          p2p: json["chat_type_p2p"],
          secure: json["chat_type_secure"],
          readonly: json["chat_type_readonly"],
          picture: json["chat_type_picture"],
          description: json["chat_type_description"]);
    } catch (err, stack) {
      throw AppErrorException(AppErrorExceptionType.parsing, message: "Error happend parsing: $json\r\n$stack");
    }
  }
}

class LastMessageData {
  int messageId;
  String message;
  int senderId;
  DateTime? time;
  List<MessageStatus> statuses;

  LastMessageData(
      {required this.messageId,
      required this.message,
      required this.senderId,
      required this.time,
      required this.statuses});

  static LastMessageData fromJson(json) {
    return json == null
        ? LastMessageData(
            messageId: 0,
            message: "Нет сообщений",
            senderId: 0,
            time: null,
            statuses: [],
          )
        : LastMessageData(
            messageId: json["id"],
            message: replaceForwardSymbol(json["message"]),
            senderId: json["user_id"],
            time: DateTime.tryParse(json["created_at"]),
            statuses: [MessageStatus.fromJson(json["statuses"])],
          );
  }

  static LastMessageData from(LastMessageData parent) => LastMessageData(
      messageId: parent.messageId,
      message: parent.message,
      senderId: parent.senderId,
      time: parent.time,
      statuses: [...parent.statuses]
  );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LastMessageData &&
            runtimeType == other.runtimeType &&
            messageId == other.messageId &&
            statuses.length == other.statuses.length &&
            statuses.last.statusId == other.statuses.last.statusId;
  }
  @override
  int get hashCode => runtimeType.hashCode ^ messageId.hashCode ^ statuses.length.hashCode ^ statuses.last.statusId.hashCode;

}

class DialogPartnerData {
  const DialogPartnerData({
    required this.senderId,
    required this.senderName,
    required this.imageUrl,
  });
  final String senderId;
  final String senderName;
  final String imageUrl;

  static DialogPartnerData fromJson(json) {
    try {
      return DialogPartnerData(
          senderId: json["id"],
          senderName: json["fullname"],
          imageUrl: json["imageUrl"] ??
              "https://sushistar73.ru/assets/img/noavatar.png");
    } catch (err, stack) {
      throw AppErrorException(AppErrorExceptionType.parsing, message: "Error happend parsing: $json\r\n$stack");
    }
  }
}

class DialogMessageData {
  DialogMessageData(
      {required this.message,
      required this.messageDate,
      required this.readStatus,
      required this.senderMessageData,
      required this.attachments,
      required this.attachmentType});
  String message;
  String messageDate;
  bool readStatus;
  SenderMessageData senderMessageData;
  bool attachments;
  String? attachmentType;

  static DialogMessageData emptyData() => DialogMessageData(
    message: "",
    messageDate: "",
    readStatus: true,
    senderMessageData: SenderMessageData.fromJson(null),
    attachments: false,
    attachmentType: null
  );
  static DialogMessageData fromJson(json) {
    try {
      return DialogMessageData(
          message: json["text"] ?? 'Нет сообщений',
          messageDate: getDate(DateTime.tryParse(json["updatedAt"])),
          readStatus: json["read"],
          senderMessageData: SenderMessageData.fromJson(json["user"]),
          attachments: json["attachments"].length > 0 ? true : false,
          attachmentType: json["attachments"].length > 0
              ? json["attachments"][0]["filetype"]
              : null);
    }
    catch (err, stack) {
      throw AppErrorException(AppErrorExceptionType.parsing, message: "Error happend parsing: $json\r\n$stack");
    }
  }
}

class SenderMessageData {
  SenderMessageData({required this.id});
  String id;

  static SenderMessageData fromJson(json) {
    try {
      return SenderMessageData(
        id: json["_id"] ?? '',
      );
    } catch (err, stack) {
      throw AppErrorException(AppErrorExceptionType.parsing, message: "Error happend parsing: $json\r\n$stack");
    }
  }
}

class ChatUser {
  final int id;
  final int chatId;
  final int userId;
  final int chatUserRole;
  final bool active;
  final UserModel user;

  ChatUser({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.chatUserRole,
    required this.active,
    required this.user
  });


  static ChatUser fromJson(json) {
    try {
      return ChatUser(
          id: json["id"],
          chatId: json["chat_id"],
          userId: json["user_id"],
          chatUserRole: json["chat_user_role_id"],
          active: json["active"],
          user: json["user"] != null ?UserModel.fromJsonAPI(json["user"])
            : UserModel(id: json["user_id"], firstname: 'удален', lastname: 'Пользователь', middlename: '', company: '', position: '', phone: '', dept: '', email: '', avatar: null, birthdate: '', banned: 0, lastAccess: '')
      );
    } catch (err, stack) {
      throw AppErrorException(AppErrorExceptionType.parsing, message: "Error happend parsing: $json\r\n$stack");
    }
  }

  static ChatUser fromDBJson(json) {
    try {
      return ChatUser(
        id: json["chat_user_record_id"],
        chatId: json["chat_id"],
        userId: json["user_id"],
        chatUserRole: json["chat_user_role_id"],
        active: json["active"],
        user: UserModel.fromJsonDB(json)
      );
    } catch (err, stack) {
      throw AppErrorException(AppErrorExceptionType.parsing, message: "Error happend parsing: $json\r\n$stack");
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ChatUser &&
            runtimeType == other.runtimeType &&
            other.active == active &&
            other.userId == userId;
  }
  int get hashCode => runtimeType.hashCode ^ userId.hashCode ^ active.hashCode;

}

class DialogId {
  DialogId({required this.dialogId});
  int dialogId;

  static DialogId fromJson(json) {
    try {
      return DialogId(dialogId: json["dialogId"] ?? json["_id"]);
    } catch (err, stack) {
      throw AppErrorException(AppErrorExceptionType.parsing, message: "Error happend parsing: $json\r\n$stack");
    }
  }
}



String getDateDialogModel(DateTime rawDate) {
  // Todo: is that necessary to check it
  return rawDate != null ? dateFormater(rawDate) : "";
}

String? getAttachmentType(json) {
  print(json);
}

class ClientUserEvent {
  final int fromUser;
  final int toUser;
  final String event;

  ClientUserEvent({
    required this.fromUser,
    required this.toUser,
    required this.event
  });

  static ClientUserEvent fromJson(json) => ClientUserEvent(
    fromUser: json["fromUser"],
    toUser: json["toUser"],
    event: json["event"]
  );
}
