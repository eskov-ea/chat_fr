import 'package:chat/models/user_profile_model.dart';
import 'package:chat/services/user_profile/user_profile_api_provider.dart';

class UserProfileRepository  {
  final UserProfileProvider provider;

  const UserProfileRepository({required this.provider});

  Future <UserProfileData> getUserProfile(token) => provider.getUserProfile(token);
}