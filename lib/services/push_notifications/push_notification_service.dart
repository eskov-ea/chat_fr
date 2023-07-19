import 'dart:convert';
import 'dart:io';
import 'package:chat/services/logger/logger_service.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:http/http.dart' as http;

import '../../bloc/error_handler_bloc/error_types.dart';

class PushNotificationService {
  final _secureStorage = DataProvider();

  sendMissCallPush({required userId, required userName}) async {
    try {
      final String? token = await _secureStorage.getToken();
      final postData = jsonEncode(<String, Object>{
        'data': {
          'message': {
            'title': 'Пропущенный звонок от $userName',
            'body': ''
          }
        }
      });
      final response = await http.post(
          Uri.parse('https://erp.mcfef.com/api/user/push/$userId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: postData
      );
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, null,
            "MessagesProvider.loadAttachmentData");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null,
            "MessagesProvider.loadAttachmentData");
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "MessagesProvider.loadAttachmentData");
    } on AppErrorException {
      rethrow;
    } catch (err) {
      Logger.getInstance().sendErrorTrace(message: "PushNotificationService.sendMissCallPush", err: err.toString());
      throw AppErrorException(AppErrorExceptionType.other, null, "PushNotificationService.sendMissCallPush");
    }
  }

}