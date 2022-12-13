import '../../models/chat_builder_model.dart';


class ChatsBuilderState {
   List<ChatsData> chats;
   //TODO: create normal equals rules for state
   int counter;
   Map<String, bool> messagesDictionary;

   ChatsBuilderState.initial()
      : chats =  <ChatsData>[], counter = 0, messagesDictionary = {};

  ChatsBuilderState({
    required this.chats, required this.counter, required this.messagesDictionary
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatsBuilderState &&
              runtimeType == other.runtimeType &&
              chats == other.chats &&
              chats.length == other.chats.length &&
              counter == other.counter;
  @override
  int get hashCode =>
      chats.hashCode ^ chats.length ^ counter.hashCode;



  ChatsBuilderState copyWith({
    List<ChatsData>? updatedChats,
    updatedCounter,
    updatedMessagesDictionary
  }) {
    return ChatsBuilderState(
      chats: updatedChats ?? chats,
      counter: updatedCounter ?? counter,
      messagesDictionary: updatedMessagesDictionary ?? messagesDictionary,
    );
  }
}

class ChatsBuilderInProgressState extends ChatsBuilderState{
  ChatsBuilderInProgressState({required List<ChatsData> chats,
    required int counter, required Map<String, bool> messagesDictionary}) :
        super(chats: chats, counter: counter, messagesDictionary: messagesDictionary);

}