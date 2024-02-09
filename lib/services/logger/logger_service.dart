import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../storage/data_storage.dart';

class Logger {

  final _secureStorage = DataProvider();
  static Logger? logger;

  Logger._();

  static Logger getInstance() {
    if (logger == null) {
      logger = Logger._();
      return logger!;
    } else {
      return logger!;
    }
  }

  Future<void> sendErrorTrace({required StackTrace stackTrace, String? errorType, String? additionalInfo, String? level, String? uri}) async {
    try {
      level == null ? 'debug' : level;
      final String? token = await _secureStorage.getToken();
      final String? userId = await _secureStorage.getUserId();
      final String additional = additionalInfo ?? 'N/A';
      final String url = uri ?? 'N/A';
      final errorT = errorType ?? 'N/A';
      final postData = jsonEncode(<String, Object>{
        'data': {
          'message':
              '\r\nUser ID: [ ${userId ?? "N/A"}], URL was: [ $url ],  Error type: [ $errorT ], additional: [ $additional ] \r\n$stackTrace',
        }
      });
      await http.post(Uri.parse('https://erp.mcfef.com/api/log/$level'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: postData);
    } catch (_) {}
  }

  Future<void> sendDebugMessage({required String message, required String operation, String? level}) async {
    level ?? 'debug';
    try {
      final String? userId = await _secureStorage.getUserId();
      final postData = jsonEncode(<String, Object>{
        'data': {
          'message':
              '\r\nUser ID: [ ${userId ?? "N/A"}], Operation was: [ $operation ] \r\n$message',
        }
      });
      await http.post(
        Uri.parse('https://erp.mcfef.com/api/log/$level'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: postData);
    } catch (_) {}
  }

}