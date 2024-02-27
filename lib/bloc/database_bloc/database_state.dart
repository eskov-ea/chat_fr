abstract class DatabaseBlocState {}

class DatabaseBlocDBInitializedState extends DatabaseBlocState {}
class DatabaseBlocDBNotInitializedState extends DatabaseBlocState {}
class DatabaseBlocDBFailedInitializeState extends DatabaseBlocState {}

class DatabaseBlocLoadingUsersState extends DatabaseBlocState {}
class DatabaseBlocLoadingDialogsState extends DatabaseBlocState {}
class DatabaseBlocLoadingCallsState extends DatabaseBlocState {}

class DatabaseBlocLoadedUsersState extends DatabaseBlocState {}
class DatabaseBlocLoadedDialogsState extends DatabaseBlocState {}
class DatabaseBlocLoadedCallsState extends DatabaseBlocState {}