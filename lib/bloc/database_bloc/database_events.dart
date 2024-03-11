import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:flutter/foundation.dart';

abstract class DatabaseBlocEvent {}

class DatabaseBlocInitializeEvent extends DatabaseBlocEvent {}

class DatabaseBlocInitializeInProgressEvent extends DatabaseBlocEvent {
  final String? message;
  final double? progress;

  DatabaseBlocInitializeInProgressEvent({required this.message, required this.progress});
}

class DatabaseBlocCheckAuthTokenEvent extends DatabaseBlocEvent {}

class DatabaseBlocSendMessageEvent extends DatabaseBlocEvent {
  final String? messageText;
  final int dialogId;
  final RepliedMessage? parentMessage;
  final String? filetype;
  final Uint8List? bytes;
  final String? filename;
  final String? content;

  DatabaseBlocSendMessageEvent({
    required this.dialogId, required this.messageText,
    required this.filetype, required this.parentMessage,
    required this.bytes, required this.filename,
    required this.content
  });
}

class DatabaseBlocNewDialogReceivedEvent extends DatabaseBlocEvent {
  final DialogData dialog;

  DatabaseBlocNewDialogReceivedEvent({required this.dialog});
}

class DatabaseBlocNewMessageReceivedEvent extends DatabaseBlocEvent {
  final MessageData message;

  DatabaseBlocNewMessageReceivedEvent({required this.message});
}

class DatabaseBlocUpdateLocalMessageEvent extends DatabaseBlocEvent {
  final int localId;
  final int messageId;
  final int dialogId;
  final List<MessageStatus> statuses;

  DatabaseBlocUpdateLocalMessageEvent({required this.localId, required this.messageId, required this.statuses, required this.dialogId});

}

class DatabaseBlocNewMessageStatusEvent extends DatabaseBlocEvent {
  final MessageStatus status;

  DatabaseBlocNewMessageStatusEvent({required this.status});
}

class DatabaseBlocGetUpdatesOnResume extends DatabaseBlocEvent {}

class DatabaseBlocResendMessageEvent extends DatabaseBlocEvent {
  final int localMessageId;
  final int dialogId;

  DatabaseBlocResendMessageEvent({required this.localMessageId, required this.dialogId});
}



