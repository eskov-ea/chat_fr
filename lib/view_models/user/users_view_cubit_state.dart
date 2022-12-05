import '../../../../models/contact_model.dart';
import '../../../../models/user_profile_model.dart';

abstract class UsersViewCubitState {
  final List<UserContact> users = [];
}

class UsersViewCubitLoadedState extends UsersViewCubitState {
  final List<UserContact> users;
  final String searchQuery;

  UsersViewCubitLoadedState({
    required this.users,
    required this.searchQuery
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
  }) {
    return UsersViewCubitLoadedState(
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class UsersViewCubitLoadingState extends UsersViewCubitState{}