import 'dart:convert';
import 'dart:io';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/models/auth_user_model.dart';
import 'package:http/http.dart' as http;
import '../../models/user_profile_model.dart';
import '../helpers/http_error_handler.dart';
import '../logger/logger_service.dart';
import '../user_profile/user_profile_api_provider.dart';



class AuthRepository {
  final _secureStorage = DataProvider();
  final _profileProvider = UserProfileProvider();
  final _logger = Logger.getInstance();

  Future<AuthToken> login(username, password, platform, token) async {
    final String device_name = platform ?? "browser";
    try {
      final response = await http.post(
        Uri.parse('https://erp.mcfef.com/api/auth'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(
          <String, dynamic> {
            'data': {
              'email': username,
              'password': password,
              'device_name': "$device_name|$token"
            }
          }
        ),
      );
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      final AuthToken authToken = AuthToken.fromJson(json.decode(response.body));
      await _secureStorage.setToken(authToken.token);
      final UserProfileData profile = await _profileProvider.getUserProfile(authToken.token);
      final userId = profile.id;
      await _secureStorage.setUserId(userId);
      return authToken;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/auth ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: "$err, url was: https://erp.mcfef.com/api/auth");
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error while authenticating");
      throw AppErrorException(AppErrorExceptionType.other);
    }
  }

  Future<void> logout() async {
    try {
      final token = await _secureStorage.getToken();
      final res = await http.get(
        Uri.parse('https://erp.mcfef.com/api/logout'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      await _secureStorage.deleteUserId();
      await _secureStorage.deleteToken();
      await _secureStorage.deleteDeviceID();
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.auth);
    }
  }

  ///TODO: refactor this non-production solution caused iOS platform specific behavior
  Future<String?> _tokenAccessGuard() async {
    String? token = await DataProvider().getToken();
    if (token == null) {
      await Future.delayed(const Duration(milliseconds: 150));
      token = await DataProvider().getToken();
    }
    if (token == null) {
      await Future.delayed(const Duration(milliseconds: 50));
      token = await DataProvider().getToken();
    }
    if (token == null) {
      final os = Platform.operatingSystem;
      final version = Platform.operatingSystemVersion;
      final user = await DataProvider().getUserId();

      await Logger().sendDebugMessage(message: "Device token not found. USER ID: [ $user ], OS: [ $os ], VERSION: [ $version ]", operation: "Reading token");
    }
    return token;
  }

  Future<bool> checkAuthStatus() async {
    try {
      final token = _tokenAccessGuard();
      final response = await http.get(
        Uri.parse('https://erp.mcfef.com/api/profile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      final error = handleHttpResponse(response);
      if (error != null) throw error;
      return true;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
      "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/auth ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: "CHECK AUTH $err");
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      print("checkAuthStatus   $err");
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "CHECK AUTH");
      throw AppErrorException(AppErrorExceptionType.other);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('https://erp.mcfef.com/api/user/lostpassword'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(
            <String, dynamic> {
              'data': {
                'email': email
              }
            }
        ),
      );
      final error = handleHttpResponse(response);
      if (error != null) throw error;
    } on SocketException catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Error additional: [ message: ${err.message}, "
          "address: ${err.address}, port: ${err.port}, url was: https://erp.mcfef.com/api/user/lostpassword ]");
      throw AppErrorException(AppErrorExceptionType.network);
    } on http.ClientException catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: "HTTP ClientException", additionalInfo: err.toString());
      throw AppErrorException(AppErrorExceptionType.network);
    } on AppErrorException {
      rethrow;
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace);
      throw AppErrorException(AppErrorExceptionType.other);
    }
  }

}