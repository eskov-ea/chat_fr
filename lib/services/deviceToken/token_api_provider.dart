import 'dart:convert';
import 'package:http/http.dart' as http;
import '../logger/logger_service.dart';

class DeviceTokenProvider {

  Future setToken({
    required userId,
    required token,
    required platform
  }) async {
    try {
      final postData = jsonEncode(<String, String>{
        'userId': userId,
        'deviceToken': token,
        'platform': platform
      });
      await http.post(
          Uri.parse('https://web-notifications.ru/api/add_device_token'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: postData);
    } catch (err) {
      Logger.getInstance().sendErrorTrace(message: "DeviceTokenProvider.setToken", err: err.toString());
    }
  }
}