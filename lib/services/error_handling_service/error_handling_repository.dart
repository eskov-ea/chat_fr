import 'dart:io';
import 'package:chat/models/error_model.dart';
import 'package:chat/services/error_handling_service/error_handling_repository_interface.dart';
import 'package:chat/services/logger/logger_service.dart';
import 'package:http/http.dart';

class ErrorHandlingRepository extends IErrorHandlingRepository {
   final _logger = Logger.getInstance();
   ErrorHandlingRepository._private();

   static final ErrorHandlingRepository _instance = ErrorHandlingRepository._private();
   static ErrorHandlingRepository get instance => _instance;

   AppErrorException handleError(Exception err, StackTrace stackTrace) {
      print('Error handler::: start ${err.runtimeType}  ${err.runtimeType is AppErrorException}\r\n');
      if (err is SocketException) {
         final url = err.address;
         final message = err.message;
         _logger.sendErrorTrace(stackTrace: stackTrace, additionalInfo: message, uri: url.toString(), errorType: 'SocketException');
         return AppErrorException(AppErrorExceptionType.socket);
      } else if (err is ClientException) {
         final url = err.uri;
         final message = err.message;
         _logger.sendErrorTrace(stackTrace: stackTrace, additionalInfo: message, uri: url.toString(), errorType: 'ClientException');
         return AppErrorException(AppErrorExceptionType.network);
      } else if (err is AppErrorException) {
         if (err.type != AppErrorExceptionType.network && err.type != AppErrorExceptionType.socket) {
            _logger.sendErrorTrace(stackTrace: stackTrace, errorType: err.type.toString());
         }
         print('Error handler::: return $err\r\n$stackTrace');
         return err;
      } else {
         return AppErrorException(AppErrorExceptionType.other);
      }
   }
}