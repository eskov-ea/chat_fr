import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:http/http.dart' as http;
import '../../models/dialog_model.dart';
import '../../storage/data_storage.dart';
import '../logger/logger_service.dart';


class DialogsProvider {
  final _secureStorage = DataProvider();

  Future<List<DialogData>> getDialogs() async {
    try {
      final String? token = await _secureStorage.getToken();
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/chat/chats'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      print("[ API CHECK ]: ${response.statusCode} ${response.body}");
      if (response.statusCode == 200) {
        List<dynamic> collection = jsonDecode(response.body)["data"];
        print("Loading dialogs:   ${response.body}");
        List<DialogData> dialogs =
            collection.map((dialog) => DialogData.fromJson(dialog)).toList();
        return dialogs;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: "https://erp.mcfef.com/api/chat/chats");
      } else {
        return throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: "https://erp.mcfef.com/api/chat/chats");
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: "https://erp.mcfef.com/api/chat/chats");
    } on AppErrorException{
      rethrow;
    } catch(err) {
      return throw AppErrorException(AppErrorExceptionType.other, location: "https://erp.mcfef.com/api/chat/chats");
    }
  }

  Future<List<DialogData>> getPublicDialogs() async {

    try {
      final String? token = await _secureStorage.getToken();
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/chat/chats/public'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> collection = jsonDecode(response.body)["data"];
        List<DialogData> dialogs =
        collection.map((dialog) => DialogData.fromJson(dialog)).toList();
        return dialogs;
      } else if (response.statusCode == 403) {
        throw AppErrorException(AppErrorExceptionType.access, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: "https://erp.mcfef.com/api/chat/chats/public");
      }  else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: "https://erp.mcfef.com/api/chat/chats/public");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: "https://erp.mcfef.com/api/chat/chats/public");
      }
    } on AppErrorException{
      rethrow;
    }  on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: "https://erp.mcfef.com/api/chat/chats/public");
    } catch(err) {
      throw AppErrorException(AppErrorExceptionType.other, location: "https://erp.mcfef.com/api/chat/chats/public");
    }
  }



  Future<DialogData> createDialog({required chatType, required users, required chatName, required chatDescription, required isPublic}) async {
    try {
      final String? token = await _secureStorage.getToken();
      final response = await http.post(
        Uri.parse('https://erp.mcfef.com/api/chat/add'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'data': {
            'chat_type_id': chatType,
            'users': users,
            'name': chatName,
            'description': chatDescription,
            'is_public': isPublic
          }
        }),
      );
      if (response.statusCode == 200) {
        DialogData dialog =
            DialogData.fromJson(jsonDecode(response.body)["data"]);
        return dialog;
      } else if (response.statusCode == 403) {
        throw AppErrorException(AppErrorExceptionType.access, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: "https://erp.mcfef.com/api/chat/add");
      }  else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: "https://erp.mcfef.com/api/chat/add");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: "https://erp.mcfef.com/api/chat/add");
      }
    } on AppErrorException{
      rethrow;
    }  on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: "https://erp.mcfef.com/api/chat/add");
    } catch(err) {
      throw AppErrorException(AppErrorExceptionType.other, location: "https://erp.mcfef.com/api/chat/add");
    }
  }

  Future<ChatUser> joinDialog(userId, dialogId) async {
    try {
      final String? token = await _secureStorage.getToken();
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/chat/join/$dialogId/$userId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return ChatUser.fromJson(jsonDecode(response.body)["data"]);
      } else if (response.statusCode == 403) {
        throw AppErrorException(AppErrorExceptionType.access, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}, \n\rDialog: $dialogId",
        location: "https://erp.mcfef.com/api/chat/join/$dialogId/$userId}");
      }  else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}, \n\rDialog: $dialogId",
        location: "https://erp.mcfef.com/api/chat/join/$dialogId/$userId}");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}, \n\rDialog: $dialogId",
        location: "https://erp.mcfef.com/api/chat/join/$dialogId/$userId}");
      }
    } on AppErrorException{
      rethrow;
    }  on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: "https://erp.mcfef.com/api/chat/join/$dialogId/$userId}");
    } catch(err) {
      throw AppErrorException(AppErrorExceptionType.other, location: "https://erp.mcfef.com/api/chat/join/$dialogId/$userId}");
    }
  }

  Future<void> exitDialog(userId, dialogId) async {
    final String? token = await _secureStorage.getToken();

    try {
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/chat/exit/$dialogId/$userId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/chat/exit/$dialogId/$userId}');
      }
    } on AppErrorException{
      rethrow;
    }  on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: 'https://erp.mcfef.com/api/chat/exit/$dialogId/$userId}');
    } catch(err) {
      throw AppErrorException(AppErrorExceptionType.other, location: 'https://erp.mcfef.com/api/chat/exit/$dialogId/$userId}');
    }
  }

}