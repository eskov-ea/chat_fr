import 'dart:convert';
import 'dart:io';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:http/http.dart' as http;
import '../../models/user_profile_model.dart';
import '../../storage/data_storage.dart';
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
      if (response.statusCode == 200) {
        final UserProfileData profile =
            UserProfileData.fromJson(jsonDecode(response.body)["data"]);
        return profile;
      } else if (response.statusCode == 401) {
        throw AppErrorException(AppErrorExceptionType.auth, null,
            "UserProfileProvider, getUserProfile");
      } else {
        throw AppErrorException(AppErrorExceptionType.getData, null,
            "UserProfileProvider, getUserProfile");
      }
    }  on SocketException{
      throw AppErrorException(AppErrorExceptionType.network, null, "UserProfileProvider, getUserProfile");
    } on AppErrorException{
      rethrow;
    } catch(err) {
      throw AppErrorException(AppErrorExceptionType.other, err.toString(), "UserProfileProvider, getUserProfile");
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
      if (response.statusCode == 200) {
        return jsonDecode(response.body)["data"];
      } else {
        return null;
      }
    } catch (err) {
      //TODO: error handling
      return null;
    }
  }
}