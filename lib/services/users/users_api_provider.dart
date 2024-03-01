import 'dart:convert';
import 'dart:io';
import 'package:chat/services/global.dart';
import 'package:chat/services/helpers/http_error_handler.dart';
import 'package:chat/services/logger/logger_service.dart';
import '../../bloc/error_handler_bloc/error_types.dart';
import '../../models/contact_model.dart';
import 'package:http/http.dart' as http;


class UsersProvider {

  Future <List<UserModel>> getUsers(String? token) async {
    try {
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      List<dynamic> collection = jsonDecode(response.body)["data"];
      List<UserModel> users = collection.map((user) => UserModel.fromJsonAPI(user)).toList();
      return users;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/users ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
    }
  }

  Map<String, String> setSipContacts(List<UserModel> users) {
    final Map<String, String> map = {};
    users.forEach((user) {
      map["${SipConfig.getPrefix()}${user.id}"] = "${user.lastname} ${user.firstname}";
    });
    return map;
  }

  String prepareSipContactsList(Map<int, UserModel> users) {
    final Map<String, String> map = {};
    users.forEach((key, user) {
      map["${SipConfig.getPrefix()}${user.id}"] = "${user.lastname} ${user.firstname}";
    });
    return map.toString();
  }
}