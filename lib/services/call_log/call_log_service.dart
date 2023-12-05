import 'dart:convert';
import 'dart:io';
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
        "id": "${SipConfig.getPrefix()}$userId",
        "password": passwd
      });

      final response = await http.post(
          Uri.parse('http://aster.mcfef.com/logs/user/last/'),
          body: postData);
      print("Loading call logs  ${response.body}   ///   $passwd");
      if (response.statusCode == 200) {
        List<dynamic> collection = jsonDecode(response.body)["data"];
        List<CallModel> callLog =
        collection.map((call) => CallModel.fromJson(call)).toList();
        return callLog;
      } else if(response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.access, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
            location: "http://aster.mcfef.com/logs/user/last/");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}",
            location: "http://aster.mcfef.com/logs/user/last/");
      }
    }  on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, location: "http://aster.mcfef.com/logs/user/last/");
    } on AppErrorException{
      rethrow;
    } catch (err) {
      throw AppErrorException(AppErrorExceptionType.other, location: "http://aster.mcfef.com/logs/user/last/");
    }
  }

}