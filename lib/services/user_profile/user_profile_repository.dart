import 'package:chat/services/user_profile/user_profile_api_provider.dart';

import '../../models/user_profile_model.dart';

class UserProfileRepository  {
  UserProfileProvider userProfileProvider = UserProfileProvider();

  Future <UserProfileData> getUserProfile(token) => userProfileProvider.getUserProfile(token);
}