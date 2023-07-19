import '../../models/chat_builder_model.dart';
import '../error_handler_bloc/error_types.dart';


class ChatsBuilderState {
   List<ChatsData> chats;
   //TODO: create normal equals rules for state
   int counter;
   Map<String, bool> messagesDictionary;
   AppErrorException? error;
   bool isError;

   ChatsBuilderState.initial()
      : chats =  <ChatsData>[], counter = 0, messagesDictionary = {},
         error = null, isError = false;

  ChatsBuilderState({
    required this.chats, required this.counter, required this.messagesDictionary,
    required this.error, required this.isError
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatsBuilderState &&
              runtimeType == other.runtimeType &&
              chats == other.chats &&
              chats.length == other.chats.length &&
              error == other.error &&
              counter == other.counter;
  @override
  int get hashCode =>
      chats.hashCode ^ chats.length ^ counter.hashCode ^error.hashCode;



  ChatsBuilderState copyWith({
    List<ChatsData>? updatedChats,
    updatedCounter,
    updatedMessagesDictionary,
    AppErrorException? error,
    bool? isError
  }) {
    return ChatsBuilderState(
      chats: updatedChats ?? this.chats,
      counter: updatedCounter ?? this.counter,
      messagesDictionary: updatedMessagesDictionary ?? this.messagesDictionary,
      error: error ?? this.error,
      isError: isError ?? this.isError
    );
  }
}

class ChatsBuilderInProgressState extends ChatsBuilderState{
  ChatsBuilderInProgressState({required List<ChatsData> chats,
    required int counter, required Map<String, bool> messagesDictionary,
    required AppErrorException? error, required bool isError}) :
        super(chats: chats, counter: counter, messagesDictionary: messagesDictionary,
          error: error, isError: isError
      );

}