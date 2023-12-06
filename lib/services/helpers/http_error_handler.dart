import 'package:chat/services/logger/logger_service.dart';
import 'package:http/http.dart';
import '../../bloc/error_handler_bloc/error_types.dart';


class HttpErrorHandler {

  static final Logger _logger = Logger.getInstance();

  static handleHttpResponse(Response response) async {
    if (response.statusCode == 401) {
      await _logger.sendErrorTrace(stackTrace: StackTrace.fromString("Status code: [ ${response.statusCode} ]; response: [ ${response.body} ]"), uri: "${response.request?.method}; ${response.request?.url}; ${response.request?.headers}");
      throw AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}");
    } else if (response.statusCode != 200) {
      await _logger.sendErrorTrace(stackTrace: StackTrace.fromString("Status code: [ ${response.statusCode} ]; response: [ ${response.body} ]"), uri: "${response.request?.method}; ${response.request?.url}; ${response.request?.headers}");
      throw AppErrorException(AppErrorExceptionType.access, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}");
    }
  }
}