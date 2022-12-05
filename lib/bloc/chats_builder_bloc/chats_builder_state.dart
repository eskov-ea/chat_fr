import '../../models/chat_builder_model.dart';


class ChatsBuilderState {
   List<ChatsData> chats;
   //TODO: create normal equals rules for state
   int counter;

   ChatsBuilderState.initial()
      : chats =  <ChatsData>[], counter = 0;

  ChatsBuilderState({
    required this.chats, required this.counter
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
    updatedCounter
  }) {
    return ChatsBuilderState(
      chats: updatedChats ?? chats,
      counter: updatedCounter ?? counter
    );
  }
}

class ChatsBuilderInProgressState extends ChatsBuilderState{
  ChatsBuilderInProgressState({required List<ChatsData> chats, required int counter}) : super(chats: chats, counter: counter);

}