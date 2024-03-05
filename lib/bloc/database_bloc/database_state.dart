import 'package:chat/models/call_model.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';


abstract class DatabaseBlocState {}

class DatabaseBlocDBInitializedState extends DatabaseBlocState {
  final List<DialogData> dialogs;
  final Map<int, UserModel> users;
  final List<CallModel> calls;

  DatabaseBlocDBInitializedState({required this.dialogs, required this.users,
    required this.calls});

  DatabaseBlocDBInitializedState copyWith({
      List<DialogData>? dialogs,
      Map<int, UserModel>? users,
      List<CallModel>? calls
  }) {
    return DatabaseBlocDBInitializedState(
        dialogs: dialogs ?? this.dialogs,
        users: users ?? this.users,
        calls: calls ?? this.calls
    );
  }
}
class DatabaseBlocDBNotInitializedState extends DatabaseBlocState {}
class DatabaseBlocDBFailedInitializeState extends DatabaseBlocState {}

class DatabaseBlocLoadingUsersState extends DatabaseBlocState {}
class DatabaseBlocLoadingDialogsState extends DatabaseBlocState {}
class DatabaseBlocLoadingCallsState extends DatabaseBlocState {}

class DatabaseBlocNewMessageReceivedState extends DatabaseBlocState {
  final MessageData message;

  DatabaseBlocNewMessageReceivedState({required this.message});
}

class DatabaseBlocNewDialogReceivedState extends DatabaseBlocState {
  final DialogData dialog;

  DatabaseBlocNewDialogReceivedState({required this.dialog});
}

class DatabaseBlocUpdateMessageStatusesState extends DatabaseBlocState {
  final List<MessageStatus> statuses;

  DatabaseBlocUpdateMessageStatusesState({required this.statuses});
}

class DatabaseBlocUpdateLocalMessageState extends DatabaseBlocState {
  final int localId;
  final int messageId;
  final int dialogId;
  final List<MessageStatus> statuses;

  DatabaseBlocUpdateLocalMessageState({required this.localId, required this.dialogId, required this.messageId, required this.statuses});

}

