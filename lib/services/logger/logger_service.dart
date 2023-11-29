import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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

  Future<bool> sendErrorTrace({required StackTrace stackTrace, String? errorType, String? level}) async {
    level == null ? 'debug' : level;
    final String? token = await _secureStorage.getToken();
    final postData = jsonEncode(<String, Object>{
      'data': {
        'message': errorType != null ? '\r\n$errorType\r\n$stackTrace' : '\r\n$stackTrace',
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
    print("TODAY::::: logger ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

}