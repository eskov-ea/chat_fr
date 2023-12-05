import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../storage/data_storage.dart';

class Logger {

  final _secureStorage = DataProvider();
  static Logger? logger;

  static Logger getInstance() {
    if (logger == null) {
      logger = Logger();
      return logger!;
    } else {
      return logger!;
    }
  }

  Future<bool> sendErrorTrace({required StackTrace stackTrace, String? errorType, String? additionalInfo, String? level, String? uri}) async {
    level == null ? 'debug' : level;
    final String? token = await _secureStorage.getToken();
    final String? userId = await _secureStorage.getUserId();
    final String additional = additionalInfo ?? '';
    final String url = uri ?? '';
    final postData = jsonEncode(<String, Object>{
      'data': {
        'message': errorType != null ? '\r\nUser ID: [ ${userId ?? "N/A"}], URL was: [ $url ],  Error type: [ $errorType ]\r\n$stackTrace' + additional : '\r\n$stackTrace' + additional,
      }
    });
    final response = await http.post(
      Uri.parse('https://erp.mcfef.com/api/log/$level'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: postData
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

}