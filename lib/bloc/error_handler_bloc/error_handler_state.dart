import 'package:equatable/equatable.dart';

import 'error_types.dart';


class ErrorHandlerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ErrorHandlerInitialState extends ErrorHandlerState {}

class ErrorHandlerWithAppErrorState extends ErrorHandlerState{
  final AppErrorException error;

  ErrorHandlerWithAppErrorState({
    required this.error
  });

  @override
  List<Object?> get props => [runtimeType, error];

}

class ErrorHandlerWithRuntimeErrorState extends ErrorHandlerState{
  final Object error;

  ErrorHandlerWithRuntimeErrorState({
    required this.error
  });

  @override
  List<Object?> get props => [runtimeType, error];
}

