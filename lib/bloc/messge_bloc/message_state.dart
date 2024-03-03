import 'package:chat/models/message_model.dart';
import 'package:equatable/equatable.dart';

enum MessageBlocError {db, network}

class MessagesBlocState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MessageBlocInitialState extends MessagesBlocState {}
class MessageBlocInitializeInProgressState extends MessagesBlocState {}

class MessageBlocInitializationSuccessState extends MessagesBlocState {
  final int dialogId;
  final Map<int, MessageData> messagesDictionary;
  final int dialogLastPage;

  MessageBlocInitializationSuccessState({required this.dialogId,
    required this.messagesDictionary, required this.dialogLastPage});

  @override
  List<Object?> get props => [messagesDictionary.length, messagesDictionary];
}

class MessageBlocInitializationFailedState extends MessagesBlocState {
  final String message;
  final MessageBlocError error;

  MessageBlocInitializationFailedState({required this.message, required this.error});

  @override
  List<Object?> get props => [error];
}

// class MessagesBlocState extends Equatable {
//    final int dialogId;
//    final Map<int, MessageData> messagesDictionary;
//    final bool isLoadingMessages;
//
//    MessagesBlocState.initial()
//       : messagesDictionary = null,
//         dialogId = null,
//         isLoadingMessages = true;
//
//   const MessagesBlocState({
//     required this.chats, required this.messagesDictionary,
//     required this.error, required this.isError, required this.isLoadingMessages
//   });
//
//   MessagesBlocState copyWith({
//     List<ChatsData>? updatedChats,
//     updatedCounter,
//     updatedMessagesDictionary,
//     AppErrorException? error,
//     bool? isError,
//     bool? isLoadingMessages
//   }) {
//     return MessagesBlocState(
//       chats: updatedChats ?? chats,
//       messagesDictionary: updatedMessagesDictionary ?? messagesDictionary,
//       error: error ?? this.error,
//       isError: isError ?? this.isError,
//       isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages
//     );
//   }
//
//
//   @override
//   List<Object?> get props => [chats, messagesDictionary, error, isError];
// }
