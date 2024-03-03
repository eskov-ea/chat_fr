import 'package:chat/models/message_model.dart';
import 'package:flutter/foundation.dart';

abstract class DatabaseBlocEvent {}

class DatabaseBlocInitializeEvent extends DatabaseBlocEvent {}

class DatabaseBlocInitializeInProgressEvent extends DatabaseBlocEvent {}

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

