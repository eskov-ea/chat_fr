import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:equatable/equatable.dart';

abstract class DialogsEvent extends Equatable{
  @override
  List<DialogData> get props => [];
}

class DialogsLoadEvent extends DialogsEvent {}

class DialogsLoadedEvent extends DialogsEvent {
  final List<DialogData> dialogs;
  DialogsLoadedEvent({required this.dialogs});
}

class DialogsSearchDialogEvent extends DialogsEvent {
  final String searchQuery;

  DialogsSearchDialogEvent(this.searchQuery);
}

class ReceiveNewDialogEvent extends DialogsEvent{
  final DialogData dialog;

  ReceiveNewDialogEvent({required this.dialog});
}

class ReceiveDialogsOnUpdateEvent extends DialogsEvent{
  final List<DialogData> dialogs;

  ReceiveDialogsOnUpdateEvent({required this.dialogs});
}

class DialogDeletedChatEvent extends DialogsEvent{
  final DialogData dialog;

  DialogDeletedChatEvent({required this.dialog});
}

class DialogStateNewMessageReceived extends DialogsEvent{
  final MessageData message;

  DialogStateNewMessageReceived({required this.message});
}

class DialogStateNewMessagesOnUpdate extends DialogsEvent{
  final List<MessageData> messages;

  DialogStateNewMessagesOnUpdate({required this.messages});
}

class DialogsSearchEvent extends DialogsEvent{
  final String searchQuery;

  DialogsSearchEvent({required this.searchQuery});
}

class DialogUserJoinChatEvent extends DialogsEvent{
  final ChatUser user;

  DialogUserJoinChatEvent({
    required this.user
  });
}

class DialogStateNewMessageStatusesReceived extends DialogsEvent {
  final List<MessageStatus> statuses;

  DialogStateNewMessageStatusesReceived({required this.statuses});
}

class DialogUserExitChatEvent extends DialogsEvent{
  final ChatUser user;

  DialogUserExitChatEvent({
    required this.user
  });
}

class RefreshDialogsEvent extends DialogsEvent{}

class DialogsLoadFailureEvent extends DialogsEvent{}

class DeleteDialogsOnLogoutEvent extends DialogsEvent{}
