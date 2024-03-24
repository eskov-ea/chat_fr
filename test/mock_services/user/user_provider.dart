import 'package:chat/models/user_model.dart';
import 'package:chat/services/users/users_api_provider.dart';
import '../../mock_data/users.dart';

class MockUserProvider implements UsersProvider {
  @override
  Future<List<UserModel>> getUsers(String? token) {
    return Future(() => users);
  }

  @override
  String prepareSipContactsList(Map<int, UserModel> users) {
    throw UnimplementedError();
  }

  @override
  Map<String, String> setSipContacts(List<UserModel> users) {
    throw UnimplementedError();
  }

}