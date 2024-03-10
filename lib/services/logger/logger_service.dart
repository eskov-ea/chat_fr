import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../../storage/data_storage.dart';

class Logger {

  final _secureStorage = DataProvider.storage;
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
      // final String? token = await _secureStorage.getToken();
      final int? userId = await _secureStorage.getUserId();
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String? version = packageInfo.version;
      final platform = Platform.operatingSystem;
      final String additional = additionalInfo ?? 'N/A';
      final String url = uri ?? 'N/A';
      final errorT = errorType ?? 'N/A';
      final postData = jsonEncode(<String, Object>{
        'data': {
          'message':
            'User ID: [ ${userId ?? "N/A"}] platform: [ $platform ], app version: [ $version ]\r\n'
            'URL was: [ $url ],  Error type: [ $errorT ], additional: [ $additional ] \r\n'
            '$stackTrace',
        }
      });
      await http.post(Uri.parse('https://erp.mcfef.com/api/log/$level'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // 'Authorization': 'Bearer $token'
        },
        body: postData);
    } catch (_) {}
  }

  Future<void> sendDebugMessage({required String message, required String operation, String? level}) async {
    level ?? 'debug';
    try {
      final int? userId = await _secureStorage.getUserId();
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