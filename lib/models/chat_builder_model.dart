import 'package:chat/models/user_profile_model.dart';


import 'dialog_model.dart';
import 'message_model.dart';


class ChatsData {
  final int chatId;
  // final DialogType chatType;
  // final UserProfileData userData;
  // final List usersList;
  final List<MessageData> messages;

  ChatsData({
    required this.chatId,
    // required this.chatType,
    // required this.userData,
    // required this.usersList,
    required this.messages
  });

  static ChatsData makeChatsData(int chatId, List<MessageData> messages) => ChatsData(
      // usersList: dialog.usersList,
      // messages: createChatAndAddMessages(messages),
      messages: messages,
      // chatType: dialog.chatType,
      chatId: chatId,
      // userData: dialog.userData
  );

  static createChatAndAddMessages(List<MessageData> messages) {
    final it = messages.iterator;
    final List<MessageData> msgs = [];
    while (it.moveNext()) {
      msgs.add(it.current);
    }
    return msgs;
  }

  addMessagesToChat(List<MessageData> messages) {
    final it = messages.iterator;
    while (it.moveNext()) {
      this.messages.add(it.current);
    }
    return this;
  }
}