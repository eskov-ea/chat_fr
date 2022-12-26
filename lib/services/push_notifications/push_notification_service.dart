import 'dart:convert';
import 'package:chat/storage/data_storage.dart';
import 'package:http/http.dart' as http;

class PushNotificationService {
  final _secureStorage = DataProvider();

  sendMissCallPush({required userId, required userName}) async {
    final String? token = await _secureStorage.getToken();
    final postData = jsonEncode(<String, Object>{
      'data': {
        'message': {
          'title': 'Пропущенный звонок от ',
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
  }

}