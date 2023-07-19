import '../../models/user_profile_model.dart';
abstract class UserProfileState {
  final UserProfileData? user = null;
}

class UserProfileInitialState extends UserProfileState {
  final UserProfileData? user;

  UserProfileInitialState({
    required this.user
  });
}

class UserProfileLoadedState extends UserProfileState{
  final UserProfileData? user;

  UserProfileLoadedState({
    required this.user
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserProfileLoadedState &&
              runtimeType == other.runtimeType &&
              user == other.user;

  @override
  int get hashCode => user.hashCode;

  UserProfileLoadedState copyWith({
    UserProfileData? user,
  }) {
    return UserProfileLoadedState(
      user: user ?? this.user,
    );
  }

}

class UserProfileLoggedOutState extends UserProfileState {
  final UserProfileData? user = null;
}

class UserProfileErrorState extends UserProfileState {}