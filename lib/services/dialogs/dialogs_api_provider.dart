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
      if (response.statusCode == 200) {
        List<dynamic> collection = jsonDecode(response.body)["data"];
        print("Loading dialogs:   ${response.body}");
        List<DialogData> dialogs =
            collection.map((dialog) => DialogData.fromJson(dialog)).toList();
        return dialogs;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, null, "DialogsProvider, loading dialogs no auth");
      } else {
        return throw AppErrorException(AppErrorExceptionType.getData, null, "DialogsProvider, loading dialogs");
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "DialogsProvider, loading dialogs");
    } on AppErrorException{
      rethrow;
    } catch(err) {
      return throw AppErrorException(AppErrorExceptionType.other, null, "DialogsProvider, loading dialogs");
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
        throw AppErrorException(AppErrorExceptionType.access, null, "DialogsProvider, loading dialogs");
      }  else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, null, "DialogsProvider, loading dialogs");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null, "DialogsProvider, loading dialogs");
      }
    } on AppErrorException{
      rethrow;
    }  on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "DialogsProvider, loading dialogs");
    } catch(err) {
      throw AppErrorException(AppErrorExceptionType.other, err.toString(), "DialogsProvider, loading dialogs");
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
        throw AppErrorException(AppErrorExceptionType.access, null, "DialogsProvider, creating dialogs");
      }  else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, null, "DialogsProvider, creating dialogs");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null, "DialogsProvider, creating dialogs");
      }
    } on AppErrorException{
      rethrow;
    }  on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "DialogsProvider, creating dialogs");
    } catch(err) {
      throw AppErrorException(AppErrorExceptionType.other, err.toString(), "DialogsProvider, creating dialogs");
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
        throw AppErrorException(AppErrorExceptionType.access, null, "DialogsProvider, creating dialogs");
      }  else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, null, "DialogsProvider, creating dialogs");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null, "DialogsProvider, creating dialogs");
      }
    } on AppErrorException{
      rethrow;
    }  on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "DialogsProvider, joining user to dialog $dialogId");
    } catch(err) {
      throw AppErrorException(AppErrorExceptionType.other, err.toString(), "DialogsProvider, joining user to dialog $dialogId");
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
      if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, null, "DialogsProvider, creating dialogs");
      }
    } on AppErrorException{
      rethrow;
    }  on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "DialogsProvider, exiting user to dialog $dialogId");
    } catch(err) {
      throw AppErrorException(AppErrorExceptionType.other, null, "DialogsProvider, exiting user to dialog $dialogId");
    }
  }

}