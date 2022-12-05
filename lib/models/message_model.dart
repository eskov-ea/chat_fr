import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import '../services/global.dart';

final DateFormat _timeFormatter = DateFormat.Hm();
final DateFormat _dateFormatter = DateFormat.yMMMd();

@immutable
class MessageData extends Equatable{
  MessageData({
    required this.messageId,
    required this.senderId,
    required this.dialogId,
    required this.message,
    required this.messageDate,
    required this.messageTime,
    required this.rawDate,
    required this.status,
    required this.file,
    required this.parentMessageId,
    required this.parentMessage
  });
  int messageId;
  int? parentMessageId;
  final ParentMessage? parentMessage;
  final int senderId;
  final int dialogId;
  final String message;
  final String messageDate;
  final String messageTime;
  final DateTime rawDate;
  final MessageAttachmentsData? file;
  List<MessageStatuses> status;

  static MessageData fromJson(json) => MessageData(
    messageId: json["id"],
    parentMessageId: json["parent_id"] != null ? json["parent_id"].toInt() : null,
    senderId: json["user_id"],
    dialogId: json["chat_id"],
    message: json["message"],
    messageDate: getDate(DateTime.tryParse(json["created_at"])?.add(getTZ())),
    messageTime: getTime(DateTime.tryParse(json["created_at"])?.add(getTZ())),
    status: MessageStatuses.fromJson(json["statuses"]),
    rawDate: DateTime.tryParse(json["created_at"])!,
    file: json["file"] != null
            ? MessageAttachmentsData.fromJson(json["file"])
            : null,
    parentMessage: json["parent"] == null
            ? null
            : ParentMessage.fromJson(json["parent"])
  );

  Map<String, dynamic> toJson() => {
    "id": messageId,
    "user_id": senderId,
    "chat_id": dialogId,
    "message": message,
    "statuses": [status],
    "created_at": rawDate
  };

  @override
  List<Object?> get props => [messageId, senderId, message, messageDate,
    messageTime, status, rawDate];
}

class MessageStatuses {
  const MessageStatuses({
    required this.id,
    required this.userId,
    required this.statusId,
    required this.messageId,
    required this.dialogId,
    required this.createdAt
  });
  final int statusId;
  final int id;
  final int userId;
  final int messageId;
  final int dialogId;
  final String createdAt;

  static List<MessageStatuses> fromJson(json) {
    final List<MessageStatuses> msgStatusesList = [];
    for (var statusObj in json) {
      msgStatusesList.add(MessageStatuses(
          id: statusObj["id"],
          userId: statusObj["user_id"],
          messageId: statusObj["chat_message_id"],
          dialogId: statusObj["chat_id"],
          statusId: statusObj["chat_message_status_id"],
          createdAt: statusObj["created_at"]
      ));
    }
    return msgStatusesList;
  }
}


class MessageUsersData {
  const MessageUsersData({
    required this.senderName,
    required this.senderId
  });
  final String senderName;
  final String senderId;

  static MessageUsersData fromJson(json) => MessageUsersData(
      senderName: json["fullname"],
      senderId: json["_id"]
  );
}

class MessageDialogData {
  const MessageDialogData({
    required this.dialogId,
    required this.lastMessage
  });
  final String dialogId;
  final String lastMessage;

  static MessageDialogData fromJson(json) => MessageDialogData(
      dialogId: json["_id"],
      lastMessage: json["lastMessage"]
  );
}

class ParentMessage {
  const ParentMessage({
    required this.parentMessageText,
    required this.senderId,
    required this.parentMessageId
  });
  final String parentMessageText;
  final int parentMessageId;
  final int senderId;

  static ParentMessage fromJson(json) => ParentMessage(
    parentMessageText: json["message"],
    parentMessageId: json["id"],
    senderId: json["user_id"]
  );

  static ParentMessage toJson({required parentMessageText,
      required parentMessageId, senderId}) => ParentMessage(
    parentMessageId: parentMessageId,
    parentMessageText: parentMessageText,
    senderId: senderId
  );
}

class MessageAttachmentsData {
  const MessageAttachmentsData({
    required this.attachmentId,
    required this.chatMessageId,
    required this.name,
    required this.filetype,
    required this.preview,
    required this.content
  });
  final int attachmentId;
  final int chatMessageId;
  final String name;
  final String filetype;
  final String? preview;
  final String? content;

  static MessageAttachmentsData fromJson(json) =>
    MessageAttachmentsData(
      attachmentId: json["id"],
      chatMessageId: json["chat_message_id"],
      name: json["name"],
      filetype: json["ext"],
      preview: json["preview"],
      content: json["content"]
    );
}

String getDate (rawDate) {
  return _dateFormatter.format(rawDate);
}

String getTime (rawDate) {
  return _timeFormatter.format(rawDate);
}

int getMessageStatus (List collection) {
  return collection.last["id"];
}