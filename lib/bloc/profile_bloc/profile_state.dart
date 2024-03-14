import '../../models/user_profile_model.dart';
abstract class UserProfileState {
  final UserProfileData? profile = null;
}

class UserProfileInitialState extends UserProfileState {
  final UserProfileData? profile;

  UserProfileInitialState({
    required this.profile
  });
}

class UserProfileLoadedState extends UserProfileState{
  final UserProfileData? profile;

  UserProfileLoadedState({
    required this.profile
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserProfileLoadedState &&
              runtimeType == other.runtimeType &&
              profile == other.profile;

  @override
  int get hashCode => profile.hashCode;

  UserProfileLoadedState copyWith({
    UserProfileData? user,
  }) {
    return UserProfileLoadedState(
      profile: user ?? this.profile,
    );
  }

}

class UserProfileLoggedOutState extends UserProfileState {
  final UserProfileData? profile = null;
}

class UserProfileErrorState extends UserProfileState {}