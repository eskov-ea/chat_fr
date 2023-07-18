import 'dart:convert';
import 'dart:io';
import 'package:chat/storage/data_storage.dart';
import 'package:chat/services/exeptions/api_client_exceptions.dart';
import 'package:chat/models/auth_user_model.dart';
import 'package:http/http.dart' as http;
import '../../models/user_profile_model.dart';
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
      print("response.body  -->  ${response.body}  ${response.statusCode}");
      if (response.statusCode == 200) {
        final AuthToken authToken = AuthToken.fromJson(json.decode(response.body));
        await _secureStorage.setToken(authToken.token);
        final UserProfileData profile = await _profileProvider.getUserProfile(authToken.token);
        final userId = profile.id;
        await _secureStorage.setUserId(userId);
        return authToken;
      } else if (response.statusCode == 403) {
        throw ApiClientException(ApiClientExceptionType.access, "403: do not have permission");
      } else {
        throw ApiClientException(ApiClientExceptionType.auth, "not authorized");
      }
    } on SocketException {
        throw ApiClientException(ApiClientExceptionType.network, "connection problems");
    } on ApiClientException {
        rethrow;
    } catch (err) {
        print("auth err  -->  $err");
        _logger.sendErrorTrace(message: "AuthRepository.login", err: err.toString());
        throw ApiClientException(ApiClientExceptionType.other, err.toString());
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
      final token2 = await _secureStorage.getToken();
      // TODO: function to delete deviceId for notifications from db
    } catch (err) {
      _logger.sendErrorTrace(message: "AuthRepository.logout", err: err.toString());
    }
  }

  Future<bool> checkAuthStatus(String? token) async {
    final response = await http.get(
      Uri.parse('https://erp.mcfef.com/api/profile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    print("AuthCheckStatusEvent  ${response.body}");
    if (response.statusCode == 200) {
      return true;
    }
    return false;
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
      print('RESET_PASSWORD_RESPONSE   ${response.body}');
    } catch (err) {
      _logger.sendErrorTrace(message: "AuthRepository.resetPassword", err: err.toString());
      print('RESET_PASSWORD_ERROR   $err');
    }
  }

}