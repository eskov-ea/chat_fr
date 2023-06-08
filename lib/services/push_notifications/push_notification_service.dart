import 'dart:convert';
import 'package:chat/services/logger/logger_service.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:http/http.dart' as http;

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
      print("PUSH SEND  -->  ${response}");
    } catch (err) {
      Logger.getInstance().sendErrorTrace(message: "PushNotificationService.sendMissCallPush", err: err.toString());
    }
  }

}