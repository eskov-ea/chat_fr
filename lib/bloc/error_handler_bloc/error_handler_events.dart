import 'error_types.dart';

abstract class ErrorHandlerEvent {}

class ErrorHandlerInitialEvent extends ErrorHandlerEvent {}

class ErrorHandlerWithErrorEvent extends ErrorHandlerEvent {
  final AppErrorException error;

  ErrorHandlerWithErrorEvent({
    required this.error
  });
}
class ErrorHandlerWithRuntimeErrorEvent extends ErrorHandlerEvent {
  final Object error;

  ErrorHandlerWithRuntimeErrorEvent({
    required this.error
  });
}

class ErrorHandlerAccessDeniedEvent extends ErrorHandlerEvent{
  final AppErrorException error;

  ErrorHandlerAccessDeniedEvent({
    required this.error
  });
}

class ErrorHandlerAuthExpiredEvent extends ErrorHandlerEvent{
  final AppErrorException error;

  ErrorHandlerAuthExpiredEvent({
    required this.error
  });
}
