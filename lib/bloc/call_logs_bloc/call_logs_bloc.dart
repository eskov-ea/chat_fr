import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/call_log/call_log_service.dart';
import '../error_handler_bloc/error_handler_bloc.dart';
import '../error_handler_bloc/error_handler_events.dart';
import '../error_handler_bloc/error_types.dart';
import 'call_logs_event.dart';
import 'call_logs_state.dart';

class CallLogsBloc extends Bloc<CallLogsEvent, CallLogsBlocState> {
  final CallLogService _callLogService = CallLogService();
  final ErrorHandlerBloc errorHandlerBloc;
  late final String _asteriskPasswd;

  CallLogsBloc({
    required CallLogsBlocState initialState,
    required this.errorHandlerBloc,
  }) : super(initialState) {
    on<CallLogsEvent>((event, emit) async {
      if(event is LoadCallLogsEvent) {
        try {
          final logs = await _callLogService.getCallLogs(passwd: event.passwd);
          _asteriskPasswd = event.passwd;
          final newState = CallsLoadedLogState(callLog: logs);
          emit(newState);
        } catch (err) {
          final e = err as AppErrorException;
          errorHandlerBloc.add(ErrorHandlerWithErrorEvent(error: err, errorStack: e.message));
          final errorState = CallLogErrorState();
          emit(errorState);
        }
      } else if (event is UpdateCallLogsEvent) {
        try {
          final logs = await _callLogService.getCallLogs(passwd: _asteriskPasswd);
          final newState = CallsLoadedLogState(callLog: logs);
          emit(newState);
        } catch (err) {
          final e = err as AppErrorException;
          errorHandlerBloc.add(ErrorHandlerWithErrorEvent(error: err, errorStack: e.message));
          final errorState = CallLogErrorState();
          emit(errorState);
        }
      }
    });
  }
}