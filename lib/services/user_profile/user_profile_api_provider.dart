import 'dart:convert';
import 'dart:io';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:http/http.dart' as http;
import '../../models/user_profile_model.dart';
import '../../storage/data_storage.dart';
import '../helpers/http_error_handler.dart';
import '../logger/logger_service.dart';


class UserProfileProvider {
  final _secureStorage = DataProvider();


  Future<UserProfileData> getUserProfile(String? token) async {
    try {
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/profile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      HttpErrorHandler.handleHttpResponse(response);
        final UserProfileData profile =
            UserProfileData.fromJson(jsonDecode(response.body)["data"]);
        return profile;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/profile ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
    }
  }


  Future<String?> loadUserAvatar(int userId) async {
    final token = await _secureStorage.getToken();
    try {
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/user/avatar/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        });
      HttpErrorHandler.handleHttpResponse(response);
      return jsonDecode(response.body)["data"];
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/user/avatar/$userId ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
    }
  }
}