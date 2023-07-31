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

  Future<bool> sendErrorTrace({required String message, required String err, String? level}) async {
    level == null ? 'debug' : level;
    final String? token = await _secureStorage.getToken();
    final postData = jsonEncode(<String, Object>{
      'data': {
        'message': '$message, Error: $err',
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