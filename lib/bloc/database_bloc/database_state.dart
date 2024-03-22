import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/call_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/models/user_profile_model.dart';


abstract class DatabaseBlocState {}

class DatabaseBlocDBInitializedState extends DatabaseBlocState {
  final List<DialogData> dialogs;
  final Map<int, UserModel> users;
  final UserProfileData profile;
  final List<CallModel> calls;

  DatabaseBlocDBInitializedState({required this.dialogs, required this.users,
    required this.calls, required this.profile});

  DatabaseBlocDBInitializedState copyWith({
      List<DialogData>? dialogs,
      UserProfileData? profile,
      Map<int, UserModel>? users,
      List<CallModel>? calls
  }) {
    return DatabaseBlocDBInitializedState(
        dialogs: dialogs ?? this.dialogs,
        users: users ?? this.users,
        profile: profile ?? this.profile,
        calls: calls ?? this.calls
    );
  }
}

class DatabaseBlocDBNotInitializedState extends DatabaseBlocState {}

class DatabaseBlocInitializationInProgressState extends DatabaseBlocState {
  final String message;
  final double progress;

  DatabaseBlocInitializationInProgressState({required this.message, required this.progress});
}

class DatabaseBlocDBFailedInitializeState extends DatabaseBlocState {
  final AppErrorException exception;

  DatabaseBlocDBFailedInitializeState({required this.exception});
}

class DatabaseBlocNewMessageReceivedState extends DatabaseBlocState {
  final MessageData message;

  DatabaseBlocNewMessageReceivedState({required this.message});
}

class DatabaseBlocFailedSendMessageState extends DatabaseBlocState {
  final int localMessageId;
  final int dialogId;

  DatabaseBlocFailedSendMessageState({required this.localMessageId, required this.dialogId});
}

class DatabaseBlocUpdateErrorStatusOnResendState extends DatabaseBlocState {
  final String localMessageId;
  final int dialogId;

  DatabaseBlocUpdateErrorStatusOnResendState({required this.localMessageId, required this.dialogId});
}

class DatabaseBlocNewMessagesOnUpdateReceivedState extends DatabaseBlocState {
  final List<MessageData> messages;

  DatabaseBlocNewMessagesOnUpdateReceivedState({required this.messages});
}

class DatabaseBlocNewDialogReceivedState extends DatabaseBlocState {
  final DialogData dialog;

  DatabaseBlocNewDialogReceivedState({required this.dialog});
}

class DatabaseBlocNewDialogsOnUpdateState extends DatabaseBlocState {
  final List<DialogData> dialogs;

  DatabaseBlocNewDialogsOnUpdateState({required this.dialogs});
}

class DatabaseBlocUpdateMessageStatusesState extends DatabaseBlocState {
  final List<MessageStatus> statuses;

  DatabaseBlocUpdateMessageStatusesState({required this.statuses});
}

class DatabaseBlocUpdateLocalMessageState extends DatabaseBlocState {
  final String localId;
  final int messageId;
  final int dialogId;
  final List<MessageStatus> statuses;

  DatabaseBlocUpdateLocalMessageState({required this.localId, required this.dialogId, required this.messageId, required this.statuses});

}

class DatabaseBlocDeletedMessagesState extends DatabaseBlocState {
  final List<int> ids;
  final int dialogId;

  DatabaseBlocDeletedMessagesState({required this.ids, required this.dialogId});
}

class DatabaseBlocUserExitChatState extends DatabaseBlocState {
  final ChatUser chatUser;
  final event = "exit";

  DatabaseBlocUserExitChatState({required this.chatUser});
}

class DatabaseBlocUserJoinChatState extends DatabaseBlocState {
  final ChatUser chatUser;
  final event = "join";

  DatabaseBlocUserJoinChatState({required this.chatUser});
}