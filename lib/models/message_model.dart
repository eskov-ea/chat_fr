import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import '../services/global.dart';

final DateFormat _timeFormatter = DateFormat.Hm();
// final DateFormat _dateFormatter = DateFormat.yMMMd();
final DateFormat _dateFormatter = DateFormat.yMd();

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
    required this.isError,
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
  bool isError;

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
            : ParentMessage.fromJson(json["parent"]),
    isError: json["isError"] ?? false,
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
  List<Object?> get props => [messageId, senderId, status];
}

class MessageStatuses extends Equatable {
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

  @override
  List<Object?> get props => [id, statusId];

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
  MessageAttachmentsData({
    required this.attachmentId,
    required this.chatMessageId,
    required this.name,
    required this.filetype,
    required this.preview,
    required this.content
  });
  int attachmentId;
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

String getDate (DateTime? rawDate) {
  if (rawDate == null) return "";
  final arr = _dateFormatter.format(rawDate).split('/');
  return [arr[1], getMonthRussianName(int.parse(arr[0])), arr[2]].join(" ");
}

String getTime (DateTime? rawDate) {
  if (rawDate == null) return "";
  return _timeFormatter.format(rawDate);
}

int getMessageStatus (List collection) {
  return collection.last["id"];
}