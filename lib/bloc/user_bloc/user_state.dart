import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/bloc/user_bloc/users_list_container.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/user_model.dart';

class UsersState {
  final UsersListContainer usersContainer = const UsersListContainer.initial();
  final UsersListContainer searchUsersContainer = const UsersListContainer.initial();
  final String searchQuery = "";
  final bool isSearchMode = false;
  copyWith(){}
  List<UserModel> get users => usersContainer.users;
  final Map<int, bool> onlineUsersDictionary = {};
  final Map<int, ClientUserEvent> clientEventsDictionary = {};
  final Map<int, UserModel> usersMapped = {};
}

class UsersLoadedState extends UsersState {
  final UsersListContainer usersContainer;
  final UsersListContainer searchUsersContainer;
  final String searchQuery;
  final Map<int, bool> onlineUsersDictionary;
  final Map<int, ClientUserEvent> clientEventsDictionary;
  final bool isAuthenticated;
  final Map<int, UserModel> usersMapped;

  bool get isSearchMode => searchQuery.isNotEmpty;
  List<UserModel> get users =>
      isSearchMode ? searchUsersContainer.users : usersContainer.users;

  UsersLoadedState.initial()
      : usersContainer = const UsersListContainer.initial(),
        searchUsersContainer = const UsersListContainer.initial(),
        onlineUsersDictionary = {},
        clientEventsDictionary = {},
        usersMapped = {},
        isAuthenticated = true,
        searchQuery = "";

  UsersLoadedState({
    required this.usersContainer,
    required this.searchUsersContainer,
    required this.searchQuery,
    required this.onlineUsersDictionary,
    required this.isAuthenticated,
    required this.usersMapped,
    required this.clientEventsDictionary
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UsersLoadedState &&
              runtimeType == other.runtimeType &&
              usersContainer == other.usersContainer &&
              isAuthenticated == other.isAuthenticated &&
              searchUsersContainer == other.searchUsersContainer &&
              onlineUsersDictionary.length == other.onlineUsersDictionary.length &&
              onlineUsersDictionary.keys == other.onlineUsersDictionary.keys &&
              clientEventsDictionary.keys == other.clientEventsDictionary.keys &&
              clientEventsDictionary.length == other.clientEventsDictionary.length &&
              searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      usersContainer.hashCode ^
      searchUsersContainer.hashCode ^
      isAuthenticated.hashCode ^
      onlineUsersDictionary.hashCode ^
      onlineUsersDictionary.length.hashCode ^
      clientEventsDictionary.length.hashCode ^
      clientEventsDictionary.keys.hashCode ^
      onlineUsersDictionary.keys.hashCode ^
      searchQuery.hashCode;

  UsersLoadedState copyWith({
    UsersListContainer? usersContainer,
    UsersListContainer? searchUsersContainer,
    String? searchQuery,
    Map<int, bool>? onlineUsersDictionary,
    Map<int, ClientUserEvent>? clientEvent,
    Map<int, UserModel>? usersMapped,
    bool? isAuthenticated
  }) {
    return UsersLoadedState(
      usersContainer: usersContainer ?? this.usersContainer,
      searchUsersContainer: searchUsersContainer ?? this.searchUsersContainer,
      searchQuery: searchQuery ?? this.searchQuery,
      onlineUsersDictionary: onlineUsersDictionary ?? this.onlineUsersDictionary,
      usersMapped: usersMapped ?? this.usersMapped,
      clientEventsDictionary: clientEvent ?? this.clientEventsDictionary,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated
    );
  }
}

class UsersErrorState extends UsersState {
  final AppErrorExceptionType errorType;

  UsersErrorState({required this.errorType});
}