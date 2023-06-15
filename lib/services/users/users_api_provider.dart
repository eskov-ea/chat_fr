import 'dart:convert';
import 'package:chat/services/global.dart';
import 'package:chat/services/logger/logger_service.dart';
import 'package:chat/storage/data_storage.dart';

import '../../models/contact_model.dart';
import 'package:http/http.dart' as http;
import '../../models/user_profile_model.dart';
import '../exeptions/api_client_exceptions.dart';


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
      return users;
    } catch (err) {
      print("ERROR: $err");
      Logger.getInstance().sendErrorTrace(message: "UsersProvider.getUsers", err: err.toString());
      throw ApiClientException(ApiClientExceptionType.other, err.toString());
    }
  }

  Map<String, String> setSipContacts(List<UserContact> users) {
    final Map<String, String> map = {};
    users.forEach((user) {
      map["$prefix${user.id}"] = "${user.lastname} ${user.firstname}";
    });
    return map;
  }
}