import '../../models/contact_model.dart';

class UsersListContainer {
  final List<UserModel> users;

  const UsersListContainer.initial()
      : users = const <UserModel>[];

  UsersListContainer({
    required this.users,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UsersListContainer &&
              runtimeType == other.runtimeType &&
              users == other.users;

  @override
  int get hashCode =>
      users.hashCode;

  UsersListContainer copyWith({
    List<UserModel>? users,
  }) {
    return UsersListContainer(
      users: users ?? this.users
    );
  }
}