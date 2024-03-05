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

  MessageBlocLoadMessagesEvent({required this.dialogId});

  @override
  List<Object?> get props => [dialogId];
}

class MessageBlocLoadNextPortionMessagesEvent extends MessageBlocEvent {
  final int dialogId;

  MessageBlocLoadNextPortionMessagesEvent({required this.dialogId});

  @override
  List<Object?> get props => [dialogId];
}

class MessageBlocReceivedMessageEvent extends MessageBlocEvent {
  final MessageData message;

  MessageBlocReceivedMessageEvent({required this.message});

  @override
  List<Object?> get props => [message.messageId];
}

class MessageBlocFlushMessagesEvent extends MessageBlocEvent {}

class MessageBlocSendReadMessagesStatusEvent extends MessageBlocEvent {
  final int dialogId;

  MessageBlocSendReadMessagesStatusEvent({required this.dialogId});
}

class MessageBlocNewMessageStatusesReceivedEvent extends MessageBlocEvent {
  final List<MessageStatus> statuses;

  MessageBlocNewMessageStatusesReceivedEvent({required this.statuses});
}

class MessageBlocUpdateLocalMessageEvent extends MessageBlocEvent {
  final int localId;
  final int messageId;
  final int dialogId;
  final List<MessageStatus> statuses;

  MessageBlocUpdateLocalMessageEvent({required this.localId, required this.dialogId, required this.messageId, required this.statuses});

}
