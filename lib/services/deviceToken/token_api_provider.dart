import 'dart:convert';
import 'package:http/http.dart' as http;

class DeviceTokenProvider {

  Future setToken({
    required userId,
    required token,
    required platform
  }) async {
    print('SAVING TOKEN');
    final postData = jsonEncode(<String, String>{
      'userId': userId,
      'deviceToken': token,
      'platform': platform
    });
    final response = await http.post(
        Uri.parse('https://web-notifications.ru/api/add_device_token'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: postData
    );
    print("SEND DEVICE TOKEN   $postData");
    print(response.statusCode);
    print(response.body);
  }
}