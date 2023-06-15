import 'package:chat/services/users/users_api_provider.dart';

import '../../models/contact_model.dart';
import '../../models/user_profile_model.dart';


class UsersRepository  {
  UsersProvider usersProvider = UsersProvider();

  Future <List<UserContact>> getAllUsers(token) => usersProvider.getUsers(token);
  Future <void> setSipContacts(List<UserContact> users) => usersProvider.setSipContacts(users);

}