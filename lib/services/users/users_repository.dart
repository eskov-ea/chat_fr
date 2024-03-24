import 'package:chat/models/user_model.dart';
import 'package:chat/services/users/users_api_provider.dart';


class UsersRepository  {
  final UsersProvider provider;

  const UsersRepository({required this.provider});

  Future <List<UserModel>> getAllUsers(token) => provider.getUsers(token);
  Map<String, String> getSipContacts(List<UserModel> users) => provider.setSipContacts(users);
  String prepareSipContactsList(Map<int, UserModel> users) => provider.prepareSipContactsList(users);

}