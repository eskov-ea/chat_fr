import 'dart:developer';
import 'package:chat/services/helpers/message_forwarding_util.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../services/global.dart';

final DateFormat _timeFormatter = DateFormat.Hm();
final DateFormat _dateFormatter = DateFormat.yMd();

class MessageData extends Equatable{
  MessageData({
    required this.messageId,
    required this.senderId,
    required this.dialogId,
    required this.forwarderFromUser,
    required this.message,
    required this.messageDate,
    required this.messageTime,
    required this.rawDate,
    required this.file,
    required this.isError,
    required this.repliedMessage,
    required this.statuses,
    required this.localId,
    this.isHandling = false,
  });
  int messageId;
  final RepliedMessage? repliedMessage;
  final int senderId;
  final int dialogId;
  final String message;
  final String messageDate;
  final String messageTime;
  final String? localId;
  final String? forwarderFromUser;
  final DateTime rawDate;
  final MessageAttachmentData? file;
  final List<MessageStatus> statuses;
  int isError;
  bool isHandling;

  static MessageData fromJson(json) {
    try {
      return MessageData(
          messageId: json["id"],
          senderId: json["user_id"],
          dialogId: json["chat_id"],
          message: replaceForwardSymbol(json["message"]),
          messageDate: getDate(DateTime.tryParse(json["created_at"])?.add(getTZ())),
          messageTime: getTime(DateTime.tryParse(json["created_at"])?.add(getTZ())),
          rawDate: DateTime.tryParse(json["created_at"])!,
          localId: json["guid"],
          file: json["file"] != null
              ? MessageAttachmentData.fromJson(json["file"])
              : null,
          repliedMessage: json["parent"] == null
              ? null
              : RepliedMessage.fromJson(json["parent"]),
          isError: 0,
          isHandling: json["isHandling"] ?? false,
          forwarderFromUser: getForwardedMessageStatus(json["message"]),
          statuses: json["statuses"].map<MessageStatus>((status) => MessageStatus.fromJson(status)).toList()
      );
    } catch (err, stack) {
      log('Parse status error:  $err \r\n $json \r\n $stack');
      rethrow;
    }
  }

  static MessageData fromDBJson(json) {
    try {
      return MessageData(
          messageId: json["message_id"],
          senderId: json["user_id"],
          dialogId: json["chat_id"],
          message: replaceForwardSymbol(json["message"]),
          messageDate: getDate(DateTime.tryParse(json["message_created_at"])?.add(getTZ())),
          messageTime: getTime(DateTime.tryParse(json["message_created_at"])?.add(getTZ())),
          rawDate: DateTime.tryParse(json["message_created_at"])!,
          localId: json["local_id"],
          file: json["file_id"] == null
              ? null
              : MessageAttachmentData.fromDBJson(json),
          repliedMessage: json["replied_message_id"] == null
              ? null
              : RepliedMessage.fromDBJson(json),
          isError: json["send_failed"] ?? 0,
          isHandling: json["isHandling"] ?? false,
          forwarderFromUser: getForwardedMessageStatus(json["message"]),
          statuses: <MessageStatus>[]
      );
    } catch (err, stack) {
      log('Parse status error:  $err \r\n $stack');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "id": messageId,
    "user_id": senderId,
    "chat_id": dialogId,
    "message": message,
    "statuses": statuses,
    "created_at": rawDate
  };

  @override
  List<Object?> get props => [messageId, senderId, file, statuses, isError, isHandling];

  @override
  String toString() {
    return "Inctance of MessageData[ id: $messageId, author: $senderId, chat_id: $dialogId, "
        "message: $message, created_at: $rawDate} "
        "file: {id: ${file?.attachmentId}, local_id: $localId, name: ${file?.name} ]"
        "${messageId.runtimeType}, ${senderId.runtimeType}, ${dialogId.runtimeType} "
        "repliedId: ${repliedMessage?.parentMessageId}, ${message.runtimeType}, ${file.runtimeType}, "
        "${file?.attachmentId.runtimeType}, statuses: ${statuses}"
        "\r\n";
  }
}

class MessageStatus extends Equatable {
  const MessageStatus({
    required this.id,
    required this.userId,
    required this.statusId,
    required this.messageId,
    required this.dialogId,
    required this.updatedAt,
    required this.createdAt
  });
  final int statusId;
  final int id;
  final int userId;
  final int messageId;
  final int dialogId;
  final String createdAt;
  final String updatedAt;

  static MessageStatus fromJson(json) => MessageStatus(
        id: json["id"],
        userId: json["user_id"],
        messageId: json["chat_message_id"],
        dialogId: json["chat_id"],
        statusId: json["chat_message_status_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"]
    );

  static MessageStatus? fromDBJson(json) {
    if (json["message_status_user_id"] == null) return null;
    try {
      return MessageStatus(
          id: json["message_status_id"],
          userId: json["message_status_user_id"],
          messageId: json["chat_message_id"],
          dialogId: json["chat_id"],
          statusId: json["chat_message_status_id"],
          createdAt: json["message_status_created_at"],
          updatedAt: json["message_status_updated_at"]
      );
    } catch (err) {
      log('Parse error $err\r\n$json');
      rethrow;
    }
  }

  @override
  List<Object?> get props => [id, statusId];

  @override
  String toString() {
    return "Instance of MessageStatus[ $id, $dialogId, $messageId,  $statusId, $userId ]";
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

class RepliedMessage extends Equatable{
  const RepliedMessage({
    required this.parentMessageText,
    required this.senderId,
    required this.parentMessageId
  });
  final String parentMessageText;
  final int parentMessageId;
  final int senderId;

  static RepliedMessage fromJson(json) => RepliedMessage(
    parentMessageText: json["message"],
    parentMessageId: json["id"],
    senderId: json["user_id"]
  );

  static RepliedMessage fromDBJson(json) => RepliedMessage(
      parentMessageText: json["replied_message_text"],
      parentMessageId: json["replied_message_id"],
      senderId: json["replied_message_author"]
  );

  static RepliedMessage toJson({required parentMessageText,
      required parentMessageId, senderId}) => RepliedMessage(
    parentMessageId: parentMessageId,
    parentMessageText: parentMessageText,
    senderId: senderId
  );

  @override
  List<Object?> get props => [senderId, parentMessageId];
}

class MessageAttachmentData  extends Equatable{
  MessageAttachmentData({
    required this.attachmentId,
    required this.chatMessageId,
    required this.name,
    required this.filetype,
    required this.preview,
    required this.content,
    required this.path,
    required this.createdAt
  });
  int attachmentId;
  final int chatMessageId;
  final String name;
  final String filetype;
  final String? preview;
  final String? content;
  final String? path;
  final String createdAt;

  static MessageAttachmentData fromJson(json) =>
    MessageAttachmentData(
      attachmentId: json["id"],
      chatMessageId: json["chat_message_id"],
      name: json["name"],
      filetype: json["ext"],
      preview: json["preview"],
      content: json["content"],
      path: json["path"],
      createdAt: json["created_at"]
    );

  static MessageAttachmentData fromDBJson(json) =>
      MessageAttachmentData(
          attachmentId: json["file_id"],
          chatMessageId: json["message_id"],
          name: json["file_name"],
          filetype: json["file_ext"],
          preview: json["file_preview"],
          content: json["content"],
          path: json["file_path"],
          createdAt: json["file_created_at"]
      );

  @override
  List<Object?> get props => [attachmentId];

  @override
  String toString() => "Instance of MessageAttachmentData(id: $attachmentId, message: $chatMessageId, path: $path)";
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