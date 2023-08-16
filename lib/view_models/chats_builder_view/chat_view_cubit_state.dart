import 'package:chat/models/chat_builder_model.dart';

abstract class ChatScreenViewCubitState {}

class ChatScreenViewCubitSuccessState extends ChatScreenViewCubitState{
  List<ChatsData> chats;

  ChatScreenViewCubitSuccessState({
    required this.chats,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatScreenViewCubitSuccessState &&
              runtimeType == other.runtimeType &&
              chats == other.chats;

  @override
  int get hashCode => chats.hashCode;

  ChatScreenViewCubitSuccessState copyWith({
    List<ChatsData>? chats
  }) {
    return ChatScreenViewCubitSuccessState(
      chats:
      chats ?? this.chats,
    );
  }
}

class ChatScreenViewCubitInProgressState extends ChatScreenViewCubitState{
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatScreenViewCubitSuccessState &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}