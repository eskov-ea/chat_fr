enum ApiClientExceptionType { network, auth, other, sessionExpired, access }

class ApiClientException implements Exception {
  final ApiClientExceptionType type;

  ApiClientException(this.type);
}