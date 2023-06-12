enum ApiClientExceptionType { network, auth, other, sessionExpired, access }

class ApiClientException implements Exception {
  final ApiClientExceptionType type;
  final dynamic message;

  ApiClientException(this.type, this.message);
}