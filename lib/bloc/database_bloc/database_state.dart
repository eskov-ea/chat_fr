import 'package:chat/models/call_model.dart';
import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';


abstract class DatabaseBlocState {}

class DatabaseBlocDBInitializedState extends DatabaseBlocState {
  final List<DialogData> dialogs;
  final Map<int, UserModel> users;
  final List<CallModel> calls;
  DatabaseBlocDBInitializedState({required this.dialogs, required this.users,
    required this.calls});
}
class DatabaseBlocDBNotInitializedState extends DatabaseBlocState {}
class DatabaseBlocDBFailedInitializeState extends DatabaseBlocState {}

class DatabaseBlocLoadingUsersState extends DatabaseBlocState {}
class DatabaseBlocLoadingDialogsState extends DatabaseBlocState {}
class DatabaseBlocLoadingCallsState extends DatabaseBlocState {}
