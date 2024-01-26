enum AppErrorExceptionType { network, auth, other, sessionExpired, access, parsing, getData, secureStorage, socket, render, requestError }

class AppErrorException implements Exception {
  final AppErrorExceptionType type;
  final String? message;
  // final String? location;

  AppErrorException(this.type, {this.message});

  @override
  toString() => "AppErrorException type: $type, message: ${message ?? "no message"}";
}