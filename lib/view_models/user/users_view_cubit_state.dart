import '../../../../models/contact_model.dart';

abstract class UsersViewCubitState {
  final List<UserContact> users = [];
  final Map<String, UserContact> usersDictionary = {};
  final Map<int, bool> onlineUsersDictionary = {};
}

class UsersViewCubitLoadedState extends UsersViewCubitState {
  final List<UserContact> users;
  final String searchQuery;
  final Map<String, UserContact> usersDictionary;
  final Map<int, bool> onlineUsersDictionary;

  UsersViewCubitLoadedState({
    required this.users,
    required this.searchQuery,
    required this.usersDictionary,
    required this.onlineUsersDictionary
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UsersViewCubitLoadedState &&
              runtimeType == other.runtimeType &&
              users == other.users &&
              searchQuery == other.searchQuery &&
              usersDictionary == other.usersDictionary;

  @override
  int get hashCode => users.hashCode ^ searchQuery.hashCode ^ usersDictionary.hashCode;

  UsersViewCubitLoadedState copyWith({
    List<UserContact>? users,
    String? searchQuery,
    Map<String, UserContact>? usersDictionary,
    Map<int, bool>? onlineUsersDictionary,
  }) {
    return UsersViewCubitLoadedState(
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      usersDictionary: usersDictionary ?? this.usersDictionary,
      onlineUsersDictionary: onlineUsersDictionary ?? this.onlineUsersDictionary
    );
  }
}

class UsersViewCubitLoadingState extends UsersViewCubitState{}

class UsersViewCubitErrorState extends UsersViewCubitState{}