import 'dart:convert';
import 'dart:io';
import 'package:chat/models/call_model.dart';
import 'package:chat/services/global.dart';
import '../../bloc/error_handler_bloc/error_types.dart';
import '../../storage/data_storage.dart';
import 'package:http/http.dart' as http;
import '../helpers/http_error_handler.dart';
import '../logger/logger_service.dart';


class CallLogService {
  final _secureStorage = DataProvider.storage;

  Future<List<CallModel>> getCallLogs({required passwd}) async {
    try {
      final int? userId = await _secureStorage.getUserId();
      final postData = jsonEncode({
        "id": "${SipConfig.getPrefix()}$userId",
        "password": passwd
      });

      final response = await http.post(
          Uri.parse('http://aster.mcfef.com/logs/user/last/'),
          body: postData);
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      List<dynamic> collection = jsonDecode(response.body)["data"];
      List<CallModel> callLog =
      collection.map((call) => CallModel.fromJson(call)).toList();
      print('calls log:: ${callLog}');
      return callLog;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: http://aster.mcfef.com/logs/user/last/ ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      print('Load calls error:  $err\r\n$stackTrace');
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
    }
  }

}