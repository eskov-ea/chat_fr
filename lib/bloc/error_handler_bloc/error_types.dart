enum AppErrorExceptionType { network, db, auth, other, sessionExpired, access, parsing, getData, secureStorage, socket, render, requestError }

class AppErrorException implements Exception {
  final AppErrorExceptionType type;
  final String? message;

  AppErrorException(this.type, {this.message});

  @override
  toString() => "AppErrorException type: $type, message: ${message ?? "no message"}";

  @override
  bool operator ==(Object other) =>
    other is AppErrorException &&
    runtimeType == other.runtimeType &&
    type == other.type &&
    message == other.message;

  @override
  int get hashCode =>
      type.hashCode ^
      message.hashCode;
}