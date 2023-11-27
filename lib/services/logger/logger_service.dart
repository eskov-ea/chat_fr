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

  Future<bool> sendUnhandledErrorsFromLog() async {
    List<String> chunks = [];
    String chunk = "";
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/logs.txt');
      String text = await file.readAsString();
      final List<String> separatedErrors = text.split("\r\n");
      for (int i=0; i < separatedErrors.length; ++i) {
        chunk += separatedErrors[i];
        if (i % 5 == 0) {
          chunks.add(chunk);
          chunk = "";
        }
      }
      chunks.add(chunk);
      for (int i=1; i<chunks.length; ++i) {
        final successful = await sendErrorTrace(err: chunks[i], message: "Unhandled error");
        if (!successful) throw Exception("Ошибка при отправке лог-файла");
      }
      file.deleteSync();
      return true;
    } catch (e) {
      print("Ошибка при отправке лог-файла    $e");
      return false;
    }
  }

}