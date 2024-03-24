import 'package:chat/models/user_profile_model.dart';
import 'package:chat/services/user_profile/user_profile_api_provider.dart';
import '../../mock_data/user_profile.dart';


class MockUserProfileProvider implements UserProfileProvider{


  Future<UserProfileData> getUserProfile(String? token) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return userProfileMock;
  }


  Future<String?> loadUserAvatar(int userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return null;
  }

}