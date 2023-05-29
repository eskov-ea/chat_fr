import 'dart:convert';
import '../../models/contact_model.dart';
import 'package:http/http.dart' as http;
import '../../models/user_profile_model.dart';


class UsersProvider {

  Future <List<UserContact>> getUsers(String? token) async {
    try {
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );
      List<dynamic> collection = jsonDecode(response.body)["data"];
      List<UserContact> users = collection.map((user) => UserContact.fromJson(user)).toList();
      print(users);
      return users;
    } catch (err) {
      print("ERRRRRR   $err");
      return [
        //TODO: fix the problems with incorrect user list
        UserContact(
          id: 121,
          firstname: "Slava",
          lastname: "Panarin",
          middlename: "Olegovich",
          company: "AO Kashalot",
          position: "Programmist",
          phone: "9991231315",
          dept: "IT",
          email: "slava@uma.ru"
        )
      ];
    }
  }
}