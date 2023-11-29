import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/logger/logger_service.dart';
import 'error_handler_events.dart';
import 'error_handler_state.dart';


class ErrorHandlerBloc extends Bloc<ErrorHandlerEvent, ErrorHandlerState> {
  final Logger _logger = Logger.getInstance();

  ErrorHandlerBloc(): super( ErrorHandlerInitialState()){
    on<ErrorHandlerEvent>((event, emit) async {
      if (event is ErrorHandlerWithErrorEvent) {
        onErrorEventEvent(event, emit);
      } else if (event is ErrorHandlerAccessDeniedEvent) {
        onErrorHandlerAccessDeniedEvent(event, emit);
      }
    });
  }

  Future<void> onErrorEventEvent (ErrorHandlerWithErrorEvent event, emit) async {
    _logger.sendErrorTrace(message: "${event.error.message}", err: "${event.error.type}");
    emit(ErrorHandlerWithErrorState(error: event.error));
  }

  void onErrorHandlerAccessDeniedEvent(ErrorHandlerAccessDeniedEvent event, emit) {
    _logger.sendErrorTrace(message: "${event.error.message}", err: "${event.error.type}");
    emit(ErrorHandlerWithErrorState(error: event.error));
  }

}