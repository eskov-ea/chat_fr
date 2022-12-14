import 'package:chat/models/contact_model.dart';
import 'package:chat/models/user_profile_model.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import 'message_model.dart';

final DateFormat _dateFormater = DateFormat.yMMMd();

@immutable
class DialogData extends Equatable {
  DialogData({
    required this.dialogId,
    required this.chatType,
    required this.userData,
    required this.usersList,
    required this.name,
    required this.description,
    required this.lastMessage,
    required this.chatUsers
  });
  final int dialogId;
  final DialogType chatType;
  final UserContact userData;
  // TODO: manage user list to <UserProfileData>
  final List<UserContact> usersList;
  LastMessageData lastMessage;
  final String name;
  final String? description;
  final List<ChatUser>? chatUsers;



  static DialogData fromJson(json) => DialogData(
    dialogId: json["id"],
    name: json["name"],
    description: json["description"],
    chatType: DialogType.fromJson(json["chat_type"]),
    userData: DialogAuthorData.fromJson(json["user"]),
    usersList: json["users"].map<UserContact>((userData) => UserContact.fromJson(userData)).toList(),
    lastMessage: LastMessageData.fromJson(json["message"]),
    chatUsers: json["chat_users"] != null
      ? json["chat_users"].map<ChatUser>((chatUser) => ChatUser.fromJson(chatUser)).toList()
      : null
  );

  @override
  List<Object?> get props => [dialogId, chatType, userData, usersList, lastMessage];
}

class DialogType {
  const DialogType({
    required this.typeId,
    required this.typeName,
    required this.p2p ,
    required this.secure ,
    required this.readonly ,
    required this.picture,
    required this.name,
    required this.description
  });
  final int typeId;
  final String typeName;
  final int p2p;
  final int secure;
  final int readonly;
  final String picture;
  final String name;
  final String description;

  static DialogType fromJson(json) => DialogType(
    typeId: json["id"],
    typeName: json["name"],
    p2p: json["p2p"],
    secure: json["secure"],
    readonly: json["readonly"],
    picture: json["picture"],
    name: json["name"],
    description: json["description"]
  );
}

class LastMessageData {

   int messageId;
   String message;
   int senderId;
   DateTime? time;
   List<MessageStatuses> statuses;
  // final int statuses;

   LastMessageData({
    required this.messageId,
    required this.message,
    required this.senderId,
    required this.time,
    required this.statuses
  });

  static LastMessageData fromJson(json) {
    return json == null
        ?  LastMessageData(
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

  static DialogPartnerData fromJson(json) => DialogPartnerData(
    senderId: json["id"],
    senderName: json["fullname"],
    imageUrl: json["imageUrl"] ?? "https://sushistar73.ru/assets/img/noavatar.png"
  );
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
   DialogMessageData({
    required this.message,
    required this.messageDate,
    required this.readStatus,
    required this.senderMessageData,
    required this.attachments,
    required this.attachmentType
  });
  String message;
  String messageDate;
  bool readStatus;
  SenderMessageData senderMessageData;
  bool attachments;
  String? attachmentType;

  static DialogMessageData fromJson(json) =>
        json != null
            ? DialogMessageData(
                message: json["text"] ?? 'Нет сообщений',
                messageDate: getDate(DateTime.tryParse(json["updatedAt"])),
                readStatus: json["read"],
                senderMessageData: SenderMessageData.fromJson(json["user"]),
                attachments: json["attachments"].length > 0 ? true : false,
                attachmentType: json["attachments"].length > 0 ? json["attachments"][0]["filetype"] : null )
            : DialogMessageData(
            message: 'Нет сообщений',
            messageDate: '',
            readStatus: true,
            senderMessageData: SenderMessageData.fromJson(json),
            attachments: false,
            attachmentType: null);
}

class SenderMessageData {
  SenderMessageData({
    required this.id
  });
  String id;

  static SenderMessageData fromJson(json) =>
    json != null
      ? SenderMessageData(
          id: json["_id"] ?? '',
        )
      : SenderMessageData(
      id: '',
    );
}

class ChatUser {
  ChatUser({
    required this.chatId,
    required this.userId,
    required this.chatUserRole,
    required this.active,
    required this.user
  });
  final int chatId;
  final int userId;
  final int chatUserRole;
  final bool active;
  final UserContact user;

  static ChatUser fromJson(json) =>
    ChatUser(
      chatId: json["chat_id"],
      userId: json["user_id"],
      chatUserRole: json["chat_user_role_id"],
      active: json["active"],
      user: UserContact.fromJson(json["user"]
    ));
}

class DialogId {
  DialogId({
    required this.dialogId
  });
  int dialogId;

  static DialogId fromJson(json) => DialogId(
      dialogId: json["dialogId"] ?? json["_id"]
  );
}

String getDateDialogModel (rawDate) {
  // Todo: is that necessary to check it
  return rawDate != null ? _dateFormater.format(rawDate) : "";
}

String? getAttachmentType (json) {
  print(json);
}