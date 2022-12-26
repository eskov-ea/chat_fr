import '../../../../models/contact_model.dart';

abstract class UsersViewCubitState {
  final List<UserContact> users = [];
  final Map<String, UserContact> usersDictionary = {};
}

class UsersViewCubitLoadedState extends UsersViewCubitState {
  final List<UserContact> users;
  final String searchQuery;
  final Map<String, UserContact> usersDictionary;

  UsersViewCubitLoadedState({
    required this.users,
    required this.searchQuery,
    required this.usersDictionary
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UsersViewCubitLoadedState &&
              runtimeType == other.runtimeType &&
              users == other.users &&
              searchQuery == other.searchQuery;

  @override
  int get hashCode => users.hashCode ^ searchQuery.hashCode;

  UsersViewCubitLoadedState copyWith({
    List<UserContact>? users,
    String? searchQuery,
    Map<String, UserContact>? usersDictionary,
  }) {
    return UsersViewCubitLoadedState(
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      usersDictionary: usersDictionary ?? this.usersDictionary,
    );
  }
}

class UsersViewCubitLoadingState extends UsersViewCubitState{}