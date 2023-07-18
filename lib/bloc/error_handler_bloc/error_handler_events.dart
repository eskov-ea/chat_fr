abstract class ErrorHandlerEvent {}

class ErrorHandlerInitialEvent extends ErrorHandlerEvent {}

class ErrorHandlerWithErrorEvent extends ErrorHandlerEvent {
  final Object error;
  final Object? errorStack;

  ErrorHandlerWithErrorEvent({
    required this.error,
    required this.errorStack
  });
}

class ErrorHandlerAccessDeniedEvent extends ErrorHandlerEvent{
  final Object error;
  final Object? errorStack;

  ErrorHandlerAccessDeniedEvent({
    required this.error,
    required this.errorStack
  });
}
