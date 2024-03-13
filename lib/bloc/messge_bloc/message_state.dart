import 'package:chat/models/message_model.dart';

enum MessageBlocError {db, network}

class MessagesBlocState {}

class MessageBlocInitialState extends MessagesBlocState {}

class MessageBlocInitializeInProgressState extends MessagesBlocState {}

class MessageBlocInitializationSuccessState extends MessagesBlocState {
  final int dialogId;
  final List<MessageData> messages;

  MessageBlocInitializationSuccessState({required this.dialogId, required this.messages});
}

class MessageBlocInitializationFailedState extends MessagesBlocState {
  final String message;
  final MessageBlocError error;

  MessageBlocInitializationFailedState({required this.message, required this.error});

}

