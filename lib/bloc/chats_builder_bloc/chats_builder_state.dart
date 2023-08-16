import 'package:chat/models/message_model.dart';
import 'package:equatable/equatable.dart';

import '../../models/chat_builder_model.dart';
import '../error_handler_bloc/error_types.dart';


class ChatsBuilderState extends Equatable {
   final List<ChatsData> chats;
   final Map<String, bool> messagesDictionary;
   final AppErrorException? error;
   final bool isError;

   ChatsBuilderState.initial()
      : chats =  <ChatsData>[], messagesDictionary = {},
         error = null, isError = false;

  ChatsBuilderState({
    required this.chats, required this.messagesDictionary,
    required this.error, required this.isError
  });


  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //         other is ChatsBuilderState &&
  //             runtimeType == other.runtimeType &&
  //             chats == other.chats &&
  //             chats.length == other.chats.length &&
  //             error == other.error;
  // @override
  // int get hashCode =>
  //     chats.hashCode ^ chats.length ^ error.hashCode;



  ChatsBuilderState copyWith({
    List<ChatsData>? updatedChats,
    updatedCounter,
    updatedMessagesDictionary,
    AppErrorException? error,
    bool? isError
  }) {
    return ChatsBuilderState(
      chats: updatedChats ?? this.chats,
      messagesDictionary: updatedMessagesDictionary ?? this.messagesDictionary,
      error: error ?? this.error,
      isError: isError ?? this.isError
    );
  }

  List<ChatsData> from() {
    List<ChatsData> chats = [];
    this.chats.forEach((chat) {
      List<MessageData> messages = [];
      chat.messages.forEach((message) {
        List<MessageStatuses> statuses = [];
        message.status.forEach((status) {
          final s = MessageStatuses(
              id: status.id,
              userId: status.userId,
              statusId: status.statusId,
              messageId: status.messageId,
              dialogId: status.dialogId,
              createdAt: status.createdAt
          );
          statuses.add(s);
        });
        final m = MessageData(
          messageId: message.messageId,
          senderId: message.senderId,
          dialogId: message.dialogId,
          message: message.message,
          messageDate: message.messageDate,
          messageTime: message.messageTime,
          rawDate: message.rawDate,
          status: statuses,
          file: message.file,
          parentMessageId: message.parentMessageId,
          isError: message.isError,
          parentMessage: message.parentMessage
        );
        messages.add(m);
      });
      final c = ChatsData(chatId: chat.chatId, messages: messages);
      chats.add(c);
    });
    return chats;
  }

  @override
  List<Object?> get props => [chats, messagesDictionary, error, isError];
}

// class ChatsBuilderInProgressState extends ChatsBuilderState{
//   ChatsBuilderInProgressState({required List<ChatsData> chats,
//     required int counter, required Map<String, bool> messagesDictionary,
//     required AppErrorException? error, required bool isError}) :
//         super(chats: chats, messagesDictionary: messagesDictionary,
//           error: error, isError: isError
//       );
// }