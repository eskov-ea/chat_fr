import 'package:chat/models/message_model.dart';
import 'package:equatable/equatable.dart';

import '../../models/chat_builder_model.dart';
import '../error_handler_bloc/error_types.dart';


class ChatsBuilderState extends Equatable {
   final List<ChatsData> chats;
   final Map<String, bool> messagesDictionary;
   final AppErrorException? error;
   final bool isError;
   final bool isLoadingMessages;

   ChatsBuilderState.initial()
      : chats =  <ChatsData>[], messagesDictionary = {},
         error = null, isError = false, isLoadingMessages = false;

  const ChatsBuilderState({
    required this.chats, required this.messagesDictionary,
    required this.error, required this.isError, required this.isLoadingMessages
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatsBuilderState &&
              runtimeType == other.runtimeType &&
              chats == other.chats &&
              chats.length == other.chats.length &&
              error == other.error &&
              //TODO: implement comparation rules for chat instances
              true == false;
  @override
  int get hashCode =>
      chats.hashCode ^ chats.length ^ error.hashCode;



  ChatsBuilderState copyWith({
    List<ChatsData>? updatedChats,
    updatedCounter,
    updatedMessagesDictionary,
    AppErrorException? error,
    bool? isError,
    bool? isLoadingMessages
  }) {
    return ChatsBuilderState(
      chats: updatedChats ?? this.chats,
      messagesDictionary: updatedMessagesDictionary ?? this.messagesDictionary,
      error: error ?? this.error,
      isError: isError ?? this.isError,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages
    );
  }


  @override
  List<Object?> get props => [chats, messagesDictionary, error, isError];
}
