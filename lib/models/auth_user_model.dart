class AuthToken {
  final String token;
  
  AuthToken({required this.token});
  
  static AuthToken fromJson(json) => AuthToken(token: json["data"]["token"]);
}

class AuthenticatedUser {
  final String userId;

  AuthenticatedUser({required this.userId});

  static AuthenticatedUser fromJson(json) => AuthenticatedUser(userId: json["id"]);
}

class AuthError {
  final String error;

  AuthError({required this.error});

  static AuthError fromJson(json) => AuthError(error: json["errors"]);
}