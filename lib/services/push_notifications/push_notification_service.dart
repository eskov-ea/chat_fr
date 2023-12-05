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
      if (response.statusCode == 200 || response.statusCode == 302) {
        return;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/user/push/$userId');
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
        location: 'https://erp.mcfef.com/api/user/push/$userId');
      }
    } on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: 'https://erp.mcfef.com/api/user/push/$userId');
    } on AppErrorException {
      rethrow;
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.other, location: 'https://erp.mcfef.com/api/user/push/$userId');
    }
  }

}