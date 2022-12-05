enum DataClientExceptionType { empty, }

class DataClientException implements Exception {
  final DataClientException type;

  DataClientException(this.type);
}