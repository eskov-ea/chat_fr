import 'dart:convert';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/services/logger/logger_service.dart';
import 'package:http/http.dart';


AppErrorException? handleHttpResponse(Response response) {
  if (response.statusCode == 401) {
    Logger.getInstance().sendErrorTrace(stackTrace: StackTrace.fromString("Status code: [ ${response.statusCode} ]; response: [ ${response.body} ]"), uri: "${response.request?.method}; ${response.request?.url}; ${response.request?.headers}");
    return AppErrorException(AppErrorExceptionType.auth, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}");
  } else if (response.statusCode != 200) {
    Logger.getInstance().sendErrorTrace(stackTrace: StackTrace.fromString("Status code: [ ${response.statusCode} ]; response: [ ${response.body} ]"), uri: "${response.request?.method}; ${response.request?.url}; ${response.request?.headers}");
    return AppErrorException(AppErrorExceptionType.access, message: "\n\rStatus Code: [ ${response.statusCode} ], \n\rResponse: ${response.body}");
  }  else {
    var validationError;
    try {
      final e = jsonDecode(response.body)["meta"]["errors"];
      validationError = e;
    } catch (_) {    }
    if (validationError != null) {
      return AppErrorException(AppErrorExceptionType.requestError, message: jsonDecode(response.body)["meta"]["errors"].toString());
    }
    return null;
  }
}