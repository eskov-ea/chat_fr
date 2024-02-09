import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/call_log/call_log_service.dart';
import '../../services/logger/logger_service.dart';
import '../error_handler_bloc/error_handler_bloc.dart';
import '../error_handler_bloc/error_handler_events.dart';
import '../error_handler_bloc/error_types.dart';
import 'call_logs_event.dart';
import 'call_logs_state.dart';

class CallLogsBloc extends Bloc<CallLogsEvent, CallLogsBlocState> {
  final CallLogService _callLogService = CallLogService();
  final ErrorHandlerBloc errorHandlerBloc;

  CallLogsBloc({
    required CallLogsBlocState initialState,
    required this.errorHandlerBloc,
  }) : super(initialState) {
    on<CallLogsEvent>((event, emit) async {
      if(event is LoadCallLogsEvent) {
        emit(CallLogInitialState());
        try {
          final logs = await _callLogService.getCallLogs(passwd: event.passwd);
          logs.forEach((call) {
            state.logsDictionary[call.id] = true;
          });
          final newState = CallsLoadedLogState(callLog: logs, logsDictionary: state.logsDictionary);
          emit(newState);
        } catch (err) {
          err as AppErrorException;
          final errorState = CallLogErrorState(errorType: err.type);
          emit(errorState);
        }
      } else if (event is UpdateCallLogsEvent) {
        try {
          final _asteriskPasswd = event.passwd;
          final logs = await _callLogService.getCallLogs(passwd: _asteriskPasswd);
          logs.forEach((call) {
            state.logsDictionary[call.id] = true;
          });
          final newState = CallsLoadedLogState(callLog: logs, logsDictionary: state.logsDictionary);
          emit(newState);
        } catch (err) {
          err as AppErrorException;
          final errorState = CallLogErrorState(errorType: err.type);
          emit(errorState);
        }
      } else if (event is AddCallToLogEvent) {
        print("IS_CALL_LOGGED  ${state.logsDictionary}  ${event.call.id}");
        if(state.logsDictionary[event.call.id]  != true) {
          final newLogState = [event.call, ...state.callLog];
          state.logsDictionary[event.call.id] = true;
          emit(CallsLoadedLogState(callLog: newLogState, logsDictionary: state.logsDictionary));
        }
      } else if (event is DeleteCallsOnLogoutEvent) {
        emit(CallsLogLogoutState());
      }
    });
  }
}