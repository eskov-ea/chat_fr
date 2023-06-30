import 'dart:convert';
import 'package:chat/services/exeptions/api_client_exceptions.dart';
import 'package:http/http.dart' as http;
import '../../models/user_profile_model.dart';
import '../../storage/data_storage.dart';


class UserProfileProvider {
  final _secureStorage = DataProvider();

  Future<UserProfileData> getUserProfile(String? token) async {
    final response = await http.get(
      Uri.parse('https://erp.mcfef.com/api/profile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final UserProfileData profile = UserProfileData.fromJson(jsonDecode(response.body)["data"]);
      return profile;
    } else {
      throw ApiClientException(ApiClientExceptionType.auth, "");
    }
    //TODO: error handling
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