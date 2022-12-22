import 'package:flutter_bloc/flutter_bloc.dart';
import 'error_handler_events.dart';
import 'error_handler_state.dart';


class ErrorHandlerBloc extends Bloc<ErrorHandlerEvent, ErrorHandlerState> {


  ErrorHandlerBloc(): super( ErrorHandlerInitialState()){
    on<ErrorHandlerEvent>((event, emit) async {
      if (event is ErrorHandlerWithErrorEvent) {
        await onErrorEventEvent(event, emit);
      }
    });
  }

  Future<void> onErrorEventEvent (ErrorHandlerWithErrorEvent event, emit) async {
    emit(ErrorHandlerWithErrorState(error: event.error));
  }
}