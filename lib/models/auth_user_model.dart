class AuthToken {
  final String token;
  
  AuthToken({required this.token});
  
  static AuthToken fromJson(json) => AuthToken(token: json["data"]["token"]);
}
