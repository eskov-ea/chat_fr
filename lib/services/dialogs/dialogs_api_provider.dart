import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:http/http.dart' as http;
import '../../models/dialog_model.dart';
import '../../storage/data_storage.dart';
import '../helpers/http_error_handler.dart';
import '../logger/logger_service.dart';


class DialogsProvider {
  final _secureStorage = DataProvider.storage;

  Future<List<DialogData>> getDialogs() async {
    try {
      final String? token = await _secureStorage.getToken();
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/chat/chats'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        throw SocketException("Timed out");
      });
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      print("LOAD DIALOGS:  ${error}");
      List<dynamic> collection = jsonDecode(response.body)["data"];
      List<DialogData> dialogs =
          collection.map((dialog) => DialogData.fromJson(dialog)).toList();
      return dialogs;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/chats ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      log("GetDialogs:: $err \r\n $stackTrace");
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
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
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      List<dynamic> collection = jsonDecode(response.body)["data"];
      List<DialogData> dialogs =
      collection.map((dialog) => DialogData.fromJson(dialog)).toList();
      return dialogs;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/chats/public ]");
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
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      DialogData dialog = DialogData.fromJson(jsonDecode(response.body)["data"]);
      return dialog;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/add ]");
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
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      return ChatUser.fromJson(jsonDecode(response.body)["data"]);
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/join/$dialogId/$userId ]");
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
      final error = handleHttpResponse(response);
      if (error != null) throw error;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/chat/exit/$dialogId/$userId ]");
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

}