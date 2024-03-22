import 'package:chat/models/user_model.dart';
import 'package:chat/services/users/users_api_provider.dart';


class UsersRepository  {
  UsersProvider usersProvider = UsersProvider();

  Future <List<UserModel>> getAllUsers(token) => usersProvider.getUsers(token);
  Map<String, String> getSipContacts(List<UserModel> users) => usersProvider.setSipContacts(users);
  String prepareSipContactsList(Map<int, UserModel> users) => usersProvider.prepareSipContactsList(users);

}