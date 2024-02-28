import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';


abstract class ChatsBuilderEvent{}


class ChatsBuilderUpdateStatusMessagesEvent extends ChatsBuilderEvent {
  final int dialogId;

  ChatsBuilderUpdateStatusMessagesEvent({
    required this.dialogId
  });
}

class ChatsBuilderReceivedUpdatedMessageStatusesEvent extends ChatsBuilderEvent {
  final List<MessageStatus> statuses;

  ChatsBuilderReceivedUpdatedMessageStatusesEvent({
    required this.statuses
  });
}

class ChatsBuilderLoadMessagesEvent extends ChatsBuilderEvent {
  final int dialogId;
  final int? pageNumber;

  ChatsBuilderLoadMessagesEvent({
    required this.dialogId,
    this.pageNumber = 1
  });
}

class ChatsBuilderDeleteLocalMessageEvent extends ChatsBuilderEvent {
  final int dialogId;
  final int messageId;

  ChatsBuilderDeleteLocalMessageEvent({
    required this.dialogId,
    required this.messageId
  });
}

class ChatsBuilderDeleteMessagesEvent extends ChatsBuilderEvent {
  final List<int> messagesId;
  final int dialogId;

  ChatsBuilderDeleteMessagesEvent({
    required this.messagesId,
    required this.dialogId,
  });
}

class ChatsBuilderAddMessageEvent extends ChatsBuilderEvent {
  final MessageData message;
  final int dialogId;

  ChatsBuilderAddMessageEvent({
    required this.message,
    required this.dialogId,
  });
}

class ChatsBuilderUpdateMessageWithErrorEvent extends ChatsBuilderEvent {
  final int messageId;
  final int dialog;
  final bool isHandling;

  ChatsBuilderUpdateMessageWithErrorEvent({
    required this.messageId,
    required this.dialog,
    this.isHandling = false
  });
}

class ChatsBuilderUpdateLocalMessageEvent extends ChatsBuilderEvent {
  final int localMessageId;
  final MessageData message;
  final int dialogId;

  ChatsBuilderUpdateLocalMessageEvent({
    required this.localMessageId,
    required this.message,
    required this.dialogId,
  });
}

class RefreshChatsBuilderEvent extends ChatsBuilderEvent{}

class DeleteAllChatsEvent extends ChatsBuilderEvent{}
