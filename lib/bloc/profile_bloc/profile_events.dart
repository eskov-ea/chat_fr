import 'package:chat/models/user_profile_model.dart';

abstract class ProfileBlocEvent {}

class ProfileBlocInitialEvent extends ProfileBlocEvent {}

class ProfileBlocLoadingEvent extends ProfileBlocEvent {}

class ProfileBlocErrorEvent extends ProfileBlocEvent {}

class ProfileBlocLoadedEvent extends ProfileBlocEvent {
  final UserProfileData profile;

  ProfileBlocLoadedEvent({required this.profile});
}

class ProfileBlocUpdateEvent extends ProfileBlocEvent {
  final UserProfileData profile;

  ProfileBlocUpdateEvent({required this.profile});
}

class ProfileBlocLogoutEvent extends ProfileBlocEvent {}

