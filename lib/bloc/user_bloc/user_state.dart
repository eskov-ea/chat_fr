import 'package:chat/bloc/user_bloc/users_list_container.dart';
import '../../models/contact_model.dart';
import '../../models/dialog_model.dart';
import '../../models/user_profile_model.dart';

class UsersState {
  final UsersListContainer usersContainer = UsersListContainer.initial();
  final UsersListContainer searchUsersContainer = UsersListContainer.initial();
  final String searchQuery = "";
  final bool isSearchMode = false;
  copyWith(){}
  List<UserContact> get users => usersContainer.users;
  final Map<int, bool> onlineUsersDictionary = {};
  final Map<int, ClientUserEvent> clientEventsDictionary = {};
}

class UsersLoadedState extends UsersState {
  final UsersListContainer usersContainer;
  final UsersListContainer searchUsersContainer;
  final String searchQuery;
  final Map<int, bool> onlineUsersDictionary;
  final Map<int, ClientUserEvent> clientEventsDictionary;

  bool get isSearchMode => searchQuery.isNotEmpty;
  List<UserContact> get users =>
      isSearchMode ? searchUsersContainer.users : usersContainer.users;

  UsersLoadedState.initial()
      : usersContainer = const UsersListContainer.initial(),
        searchUsersContainer = const UsersListContainer.initial(),
        onlineUsersDictionary = {},
        clientEventsDictionary = {},
        searchQuery = "";

  UsersLoadedState({
    required this.usersContainer,
    required this.searchUsersContainer,
    required this.searchQuery,
    required this.onlineUsersDictionary,
    required this.clientEventsDictionary
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UsersLoadedState &&
              runtimeType == other.runtimeType &&
              usersContainer == other.usersContainer &&
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
    Map<int, ClientUserEvent>? clientEvent
  }) {
    return UsersLoadedState(
      usersContainer: usersContainer ?? this.usersContainer,
      searchUsersContainer: searchUsersContainer ?? this.searchUsersContainer,
      searchQuery: searchQuery ?? this.searchQuery,
      onlineUsersDictionary: onlineUsersDictionary ?? this.onlineUsersDictionary,
      clientEventsDictionary: clientEvent ?? this.clientEventsDictionary
    );
  }
}

class UsersErrorState extends UsersState {

}