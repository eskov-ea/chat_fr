abstract class DatabaseBlocEvent {}

class DatabaseBlocInitializeEvent extends DatabaseBlocEvent {}

class DatabaseBlocLoadUsersEvent extends DatabaseBlocEvent {}
class DatabaseBlocLoadDialogsEvent extends DatabaseBlocEvent {}
class DatabaseBlocLoadCallsEvent extends DatabaseBlocEvent {}