enum AppErrorExceptionType { network, auth, other, sessionExpired, access, parsing, getData, secureStorage, socket, render }

class AppErrorException implements Exception {
  final AppErrorExceptionType type;
  final String? message;
  // final String? location;

  AppErrorException(this.type, {this.message});
}