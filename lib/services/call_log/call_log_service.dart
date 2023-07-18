import 'dart:convert';
import 'package:chat/models/call_model.dart';
import 'package:chat/services/global.dart';

import '../../bloc/error_handler_bloc/error_types.dart';
import '../../storage/data_storage.dart';
import 'package:http/http.dart' as http;

import '../logger/logger_service.dart';


class CallLogService {
  final _secureStorage = DataProvider();

  Future<List<CallModel>> getCallLogs({required passwd}) async {
    try {
      final String? userId = await _secureStorage.getUserId();
      final postData = jsonEncode({
        "id": "$prefix$userId",
        "password": passwd
      });

      final response = await http.post(
          Uri.parse('http://aster.mcfef.com/logs/user/last/'),
          body: postData);
      if (response.statusCode == 200) {
        List<dynamic> collection = jsonDecode(response.body)["data"];
        List<CallModel> callLog =
        collection.map((call) => CallModel.fromJson(call)).toList();
        return callLog;
      } else if(response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.access, null, "Call logs service, loading call logs");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null, "Call logs service, loading call logs");
      }
    } catch (err) {
      Logger.getInstance().sendErrorTrace(message: "CallLogService.getCallLogs", err: err.toString());
      rethrow;
      throw AppErrorException(AppErrorExceptionType.other, err.toString(), "Call logs service, loading call logs");
    }
  }

}