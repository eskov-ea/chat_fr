import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';


abstract class ChatsBuilderEvent{}


class ChatsBuilderCreateEvent extends ChatsBuilderEvent {}

class ChatsBuilderUpdateStatusMessagesEvent extends ChatsBuilderEvent {
  final int dialogId;

  ChatsBuilderUpdateStatusMessagesEvent({
    required this.dialogId
  });
}

class ChatsBuilderReceivedUpdatedMessageStatusesEvent extends ChatsBuilderEvent {
  final List<MessageStatuses> statuses;

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

class ChatsBuilderAddMessageEvent extends ChatsBuilderEvent {
  final MessageData message;
  final int dialog;

  ChatsBuilderAddMessageEvent({
    required this.message,
    required this.dialog,
  });
}

class ChatsBuilderUpdateMessageWithErrorEvent extends ChatsBuilderEvent {
  final MessageData message;
  final int dialog;

  ChatsBuilderUpdateMessageWithErrorEvent({
    required this.message,
    required this.dialog,
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
