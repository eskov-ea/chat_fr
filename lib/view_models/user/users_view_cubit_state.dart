import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/models/dialog_model.dart';


abstract class UsersViewCubitState {

}

class UsersViewCubitLoadedState extends UsersViewCubitState {
  final List<UserModel> users;
  final String searchQuery;
  final Map<int, UserModel> usersDictionary;
  final Map<int, bool> onlineUsersDictionary;
  final Map<int, ClientUserEvent> clientEvent;

  UsersViewCubitLoadedState({
    required this.users,
    required this.searchQuery,
    required this.usersDictionary,
    required this.onlineUsersDictionary,
    required this.clientEvent
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UsersViewCubitLoadedState &&
              runtimeType == other.runtimeType &&
              users == other.users &&
              searchQuery == other.searchQuery &&
              clientEvent == other.clientEvent &&
              clientEvent.hashCode == other.clientEvent.hashCode &&
              clientEvent.length == other.clientEvent.length &&
              usersDictionary == other.usersDictionary;

  @override
  int get hashCode => users.hashCode ^ searchQuery.hashCode ^ clientEvent.hashCode ^ clientEvent.length.hashCode ^ usersDictionary.hashCode;

  UsersViewCubitLoadedState copyWith({
    List<UserModel>? users,
    String? searchQuery,
    Map<int, UserModel>? usersDictionary,
    Map<int, bool>? onlineUsersDictionary,
    Map<int, ClientUserEvent>? clientEvent
  }) {
    return UsersViewCubitLoadedState(
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      usersDictionary: usersDictionary ?? this.usersDictionary,
      onlineUsersDictionary: onlineUsersDictionary ?? this.onlineUsersDictionary,
      clientEvent: clientEvent ?? this.clientEvent
    );
  }
}

class UsersViewCubitLoadingState extends UsersViewCubitState{}

class UsersViewCubitLogoutState extends UsersViewCubitState{}

class UsersViewCubitErrorState extends UsersViewCubitState{
  final AppErrorExceptionType errorType;

  UsersViewCubitErrorState({required this.errorType});
}