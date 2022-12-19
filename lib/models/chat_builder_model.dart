import 'message_model.dart';


class ChatsData {
  final int chatId;
  final List<MessageData> messages;

  ChatsData({
    required this.chatId,
    required this.messages
  });

  static ChatsData makeChatsData(int chatId, List<MessageData> messages) => ChatsData(
      messages: messages,
      chatId: chatId,
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