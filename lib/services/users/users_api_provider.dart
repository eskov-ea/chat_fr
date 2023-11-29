import 'dart:convert';
import 'dart:io';
import 'package:chat/services/global.dart';
import 'package:chat/services/logger/logger_service.dart';
import '../../bloc/error_handler_bloc/error_types.dart';
import '../../models/contact_model.dart';
import 'package:http/http.dart' as http;


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
      if (response.statusCode == 200) {
        List<dynamic> collection = jsonDecode(response.body)["data"];
        List<UserContact> users = collection.map((user) => UserContact.fromJson(user)).toList();
        return users;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, null,
            "DialogsProvider, creating dialogs");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null,
            "DialogsProvider, creating dialogs");
      }
    }  on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "DialogsProvider, creating dialogs");
    } on AppErrorException{
      rethrow;
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.other, err.toString(), "DialogsProvider, creating dialogs");
    }
  }

  Map<String, String> setSipContacts(List<UserContact> users) {
    final Map<String, String> map = {};
    users.forEach((user) {
      map["${SipConfig.getPrefix()}${user.id}"] = "${user.lastname} ${user.firstname}";
    });
    return map;
  }
}