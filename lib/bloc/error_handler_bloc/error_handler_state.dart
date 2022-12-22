import 'error_types.dart';


class ErrorHandlerState {}

class ErrorHandlerInitialState extends ErrorHandlerState {
  // final Object? error = null;
  // final AppErrorTypes? errorType = null;
}

class ErrorHandlerWithErrorState extends ErrorHandlerState{
  final Object error;

  ErrorHandlerWithErrorState({
    required this.error
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ErrorHandlerWithErrorState &&
              runtimeType == other.runtimeType &&
              error == other.error;

  @override
  int get hashCode => error.hashCode;

}

