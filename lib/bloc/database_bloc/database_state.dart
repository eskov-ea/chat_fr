import 'package:chat/models/dialog_model.dart';

abstract class DatabaseBlocState {}

class DatabaseBlocDBInitializedState extends DatabaseBlocState {}
class DatabaseBlocDBNotInitializedState extends DatabaseBlocState {}
class DatabaseBlocDBFailedInitializeState extends DatabaseBlocState {}

class DatabaseBlocLoadingUsersState extends DatabaseBlocState {}
class DatabaseBlocLoadingDialogsState extends DatabaseBlocState {}
class DatabaseBlocLoadingCallsState extends DatabaseBlocState {}

class DatabaseBlocLoadedUsersState extends DatabaseBlocState {}
class DatabaseBlocLoadedDialogsState extends DatabaseBlocState {
  final List<DialogData> dialogs;
  DatabaseBlocLoadedDialogsState({required this.dialogs});
}
class DatabaseBlocLoadedCallsState extends DatabaseBlocState {}