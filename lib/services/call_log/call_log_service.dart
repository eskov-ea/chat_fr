import 'dart:convert';
import 'package:chat/models/call_model.dart';

import '../../bloc/error_handler_bloc/error_types.dart';
import '../../storage/data_storage.dart';
import 'package:http/http.dart' as http;


class CallLogService {
  final _secureStorage = DataProvider();

  Future<List<CallModel>> getCallLogs({required passwd}) async {
    final String? userId = await _secureStorage.getUserId();
    final postData = jsonEncode({
      "id": userId,
      "password": passwd
    });
    try {
      final response = await http.post(
          Uri.parse('http://aster.mcfef.com/logs/user/last/'),
          body: postData);
      if (response.statusCode == 200) {
        List<dynamic> collection = jsonDecode(response.body)["data"];
        List<CallModel> callLog =
        collection.map((call) => CallModel.fromJson(call)).toList();
        return callLog;
      } else if(response.statusCode == 403) {
        throw AppErrorException(AppErrorExceptionType.access, null, "Call logs service, loading call logs");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null, "Call logs service, loading call logs");
      }
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.other, err.toString(), "Call logs service, loading call logs");
    }
  }

}