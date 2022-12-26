import 'dart:convert';
import 'package:chat/models/call_model.dart';

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
    final response = await http.post(
        Uri.parse('http://aster.mcfef.com/logs/user/last/'),
        body: postData
    );
    List<dynamic> collection = jsonDecode(response.body)["data"];
    List<CallModel> callLog =
      collection.map((call) => CallModel.fromJson(call)).toList();
    return callLog;
  }

}