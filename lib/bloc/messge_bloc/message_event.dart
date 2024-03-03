import 'package:chat/models/message_model.dart';
import 'package:equatable/equatable.dart';


class MessageBlocEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class MessageBlocReadMessagesFromDBEvent extends MessageBlocEvent {
  final int dialogId;
  final int page;

  MessageBlocReadMessagesFromDBEvent({required this.dialogId, required this.page});

  @override
  List<Object?> get props => [dialogId, page];
}

class MessageBlocLoadMessagesEvent extends MessageBlocEvent {
  final int dialogId;
  final int page;

  MessageBlocLoadMessagesEvent({required this.dialogId, required this.page});

  @override
  List<Object?> get props => [dialogId];
}

class MessageBlocLoadNextPortionMessagesEvent extends MessageBlocEvent {
  final int dialogId;
  final int page;

  MessageBlocLoadNextPortionMessagesEvent({required this.dialogId, required this.page});

  @override
  List<Object?> get props => [dialogId, page];
}

class MessageBlocReceivedMessageEvent extends MessageBlocEvent {
  final MessageData message;

  MessageBlocReceivedMessageEvent({required this.message});

  @override
  List<Object?> get props => [message.messageId];
}

class MessageBlocFlushMessagesEvent extends MessageBlocEvent {}