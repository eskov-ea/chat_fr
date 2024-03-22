import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:equatable/equatable.dart';

abstract class DialogEvent extends Equatable{
  @override
  List<DialogData> get props => [];
}

class DialogsLoadEvent extends DialogEvent {}

class DialogBlocDialogsLoadedEvent extends DialogEvent {
  final List<DialogData> dialogs;
  DialogBlocDialogsLoadedEvent({required this.dialogs});
}

class DialogsSearchDialogEvent extends DialogEvent {
  final String searchQuery;

  DialogsSearchDialogEvent(this.searchQuery);
}

class DialogBlocReceiveNewDialogEvent extends DialogEvent{
  final DialogData dialog;

  DialogBlocReceiveNewDialogEvent({required this.dialog});
}

class DialogBlocReceiveDialogsOnUpdateEvent extends DialogEvent{
  final List<DialogData> dialogs;

  DialogBlocReceiveDialogsOnUpdateEvent({required this.dialogs});
}

class DialogDeletedChatEvent extends DialogEvent{
  final DialogData dialog;

  DialogDeletedChatEvent({required this.dialog});
}

class DialogBlocNewMessageReceivedEvent extends DialogEvent{
  final MessageData message;

  DialogBlocNewMessageReceivedEvent({required this.message});
}

class DialogBlocNewMessagesOnUpdateEvent extends DialogEvent{
  final List<MessageData> messages;

  DialogBlocNewMessagesOnUpdateEvent({required this.messages});
}

class DialogsSearchEvent extends DialogEvent{
  final String searchQuery;

  DialogsSearchEvent({required this.searchQuery});
}

class DialogUserJoinChatEvent extends DialogEvent{
  final ChatUser user;

  DialogUserJoinChatEvent({
    required this.user
  });
}

class DialogBlocNewMessageStatusesReceivedEvent extends DialogEvent {
  final List<MessageStatus> statuses;

  DialogBlocNewMessageStatusesReceivedEvent({required this.statuses});
}

class DialogUserExitChatEvent extends DialogEvent{
  final ChatUser user;

  DialogUserExitChatEvent({
    required this.user
  });
}

class DialogBlocUpdateLastMessageEvent extends DialogEvent {
  final List<int> ids;
  final int dialogId;

  DialogBlocUpdateLastMessageEvent({required this.ids, required this.dialogId});
}

class RefreshDialogsEvent extends DialogEvent{}

class DialogsLoadFailureEvent extends DialogEvent{}

class DeleteDialogsOnLogoutEvent extends DialogEvent{}
