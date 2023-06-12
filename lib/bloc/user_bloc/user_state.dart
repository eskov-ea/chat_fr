import 'package:chat/bloc/user_bloc/users_list_container.dart';
import '../../models/contact_model.dart';
import '../../models/user_profile_model.dart';

class UsersState {
  final UsersListContainer usersContainer = UsersListContainer.initial();
  final UsersListContainer searchUsersContainer = UsersListContainer.initial();
  final String searchQuery = "";
  final bool isSearchMode = false;
  copyWith(){}
  List<UserContact> get users => usersContainer.users;
}

class UsersLoadedState extends UsersState {
  final UsersListContainer usersContainer;
  final UsersListContainer searchUsersContainer;
  final String searchQuery;

  bool get isSearchMode => searchQuery.isNotEmpty;
  List<UserContact> get users =>
      isSearchMode ? searchUsersContainer.users : usersContainer.users;

  UsersLoadedState.initial()
      : usersContainer = const UsersListContainer.initial(),
        searchUsersContainer = const UsersListContainer.initial(),
        searchQuery = "";

  UsersLoadedState({
    required this.usersContainer,
    required this.searchUsersContainer,
    required this.searchQuery
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UsersLoadedState &&
              runtimeType == other.runtimeType &&
              usersContainer == other.usersContainer &&
              searchUsersContainer == other.searchUsersContainer &&
              searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      usersContainer.hashCode ^
      searchUsersContainer.hashCode ^
      searchQuery.hashCode;

  UsersLoadedState copyWith({
    UsersListContainer? usersContainer,
    UsersListContainer? searchUsersContainer,
    String? searchQuery,
  }) {
    return UsersLoadedState(
      usersContainer: usersContainer ?? this.usersContainer,
      searchUsersContainer: searchUsersContainer ?? this.searchUsersContainer,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class UsersErrorState extends UsersState {

}