import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:equatable/equatable.dart';

abstract class DialogsEvent extends Equatable{
  @override
  List<DialogData> get props => [];
}

class DialogsLoadEvent extends DialogsEvent {}

class DialogsSearchDialogEvent extends DialogsEvent {
  final String searchQuery;

  DialogsSearchDialogEvent(this.searchQuery);
}

class ReceiveNewDialogEvent extends DialogsEvent{
  final DialogData dialog;

  ReceiveNewDialogEvent({required this.dialog});
}

class DialogDeletedChatEvent extends DialogsEvent{
  final DialogData dialog;

  DialogDeletedChatEvent({required this.dialog});
}

class UpdateDialogLastMessageEvent extends DialogsEvent{
  final MessageData message;

  UpdateDialogLastMessageEvent({required this.message});
}

class DialogsSearchEvent extends DialogsEvent{
  final String searchQuery;

  DialogsSearchEvent({required this.searchQuery});
}

class DialogUserJoinChatEvent extends DialogsEvent{
  final ChatUser user;
  final int dialogId;

  DialogUserJoinChatEvent({
    required this.user,
    required this.dialogId
  });
}

class DialogUserExitChatEvent extends DialogsEvent{
  final ChatUser user;
  final int dialogId;

  DialogUserExitChatEvent({
    required this.user,
    required this.dialogId
  });
}

class RefreshDialogsEvent extends DialogsEvent{}

class DialogsLoadFailureEvent extends DialogsEvent{}

class DeleteDialogsOnLogoutEvent extends DialogsEvent{}
