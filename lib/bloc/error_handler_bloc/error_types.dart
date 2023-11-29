enum AppErrorExceptionType { network, auth, other, sessionExpired, access, parsing, getData, secureStorage }

class AppErrorException implements Exception {
  final AppErrorExceptionType type;
  final String? message;
  final String errorLocation;

  AppErrorException(this.type, this.message, this.errorLocation);
}