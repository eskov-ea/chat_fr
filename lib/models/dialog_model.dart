import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/contact_model.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import '../services/global.dart';
import 'message_model.dart';

// final DateFormat _dateFormater = DateFormat.yMMMd();

@immutable
class DialogData extends Equatable {
  DialogData(
      {required this.dialogId,
      required this.chatType,
      required this.userData,
      required this.usersList,
      required this.name,
      required this.description,
      required this.lastMessage,
      required this.messageCount,
      required this.chatUsers});
  final int dialogId;
  final DialogType chatType;
  final UserContact userData;
  // TODO: manage user list to <UserProfileData>
  final List<UserContact> usersList;
  LastMessageData lastMessage;
  final String name;
  final String? description;
  final int messageCount;
  final List<ChatUser>? chatUsers;

  static DialogData fromJson(json) {
    try {
      return DialogData(
          dialogId: json["id"],
          name: json["name"],
          description: json["description"],
          chatType: DialogType.fromJson(json["chat_type"]),
          userData: DialogAuthorData.fromJson(json["user"]),
          usersList: json["users"]
              .map<UserContact>((userData) => UserContact.fromJson(userData))
              .toList(),
          lastMessage: LastMessageData.fromJson(json["message"]),
          messageCount: json["message_count"],
          chatUsers: json["chat_users"] != null
              ? json["chat_users"]
                  .map<ChatUser>((chatUser) => ChatUser.fromJson(chatUser))
                  .toList()
              : null);
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.parsing, err.toString(), "DialogData model, fromJson method");
    }
  }

  @override
  List<Object?> get props =>
      [dialogId, chatType, userData, usersList, lastMessage];
}

class DialogType {
  const DialogType(
      {required this.typeId,
      required this.typeName,
      required this.p2p,
      required this.secure,
      required this.readonly,
      required this.picture,
      required this.name,
      required this.description});
  final int typeId;
  final String typeName;
  final int p2p;
  final int secure;
  final int readonly;
  final String picture;
  final String name;
  final String description;

  static DialogType fromJson(json) {
    try {
      return DialogType(
          typeId: json["id"],
          typeName: json["name"],
          p2p: json["p2p"],
          secure: json["secure"],
          readonly: json["readonly"],
          picture: json["picture"],
          name: json["name"],
          description: json["description"]);
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.parsing, err.toString(), "DialogType model");
    }
  }
}

class LastMessageData {
  int messageId;
  String message;
  int senderId;
  DateTime? time;
  List<MessageStatuses> statuses;
  // final int statuses;

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
            message: json["message"],
            senderId: json["user_id"],
            time: DateTime.tryParse(json["created_at"]),
            statuses: MessageStatuses.fromJson(json["statuses"]),
          );
  }
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
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.parsing, err.toString(), "DialogPartnerData model");
    }
  }
}

class DialogAuthorData {
  const DialogAuthorData({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.middlename,
    required this.company,
    required this.position,
    required this.phone,
    required this.dept,
    required this.email,
  });
  final int id;
  final String firstname;
  final String lastname;
  final String middlename;
  final String company;
  final String dept;
  final String position;
  final String phone;
  final String email;

  static UserContact fromJson(json) => UserContact.fromJson(json);
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
    catch (err) {
      throw AppErrorException(AppErrorExceptionType.parsing, err.toString(), "DialogMessageData model");
      return DialogMessageData.emptyData();
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
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.parsing, err.toString(), "SenderMessageData model");
    }
  }
}

class ChatUser {
  ChatUser(
      {required this.chatId,
      required this.userId,
      required this.chatUserRole,
      required this.active,
      required this.user});
  final int chatId;
  final int userId;
  final int chatUserRole;
  final bool active;
  final UserContact user;

  static ChatUser fromJson(json) {
    try {
      return ChatUser(
          chatId: json["chat_id"],
          userId: json["user_id"],
          chatUserRole: json["chat_user_role_id"],
          active: json["active"],
          user: UserContact.fromJson(json["user"]));
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.parsing, err.toString(), "ChatUser model");
    }
  }
}

class DialogId {
  DialogId({required this.dialogId});
  int dialogId;

  static DialogId fromJson(json) {
    try {
      return DialogId(dialogId: json["dialogId"] ?? json["_id"]);
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.parsing, err.toString(), "DialogId model");
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
