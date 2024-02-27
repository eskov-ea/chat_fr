import 'package:chat/services/users/users_api_provider.dart';

import '../../models/contact_model.dart';


class UsersRepository  {
  UsersProvider usersProvider = UsersProvider();

  Future <List<UserModel>> getAllUsers(token) => usersProvider.getUsers(token);
  Map<String, String> getSipContacts(List<UserModel> users) => usersProvider.setSipContacts(users);

}