import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/call_log/call_log_service.dart';
import 'call_logs_event.dart';
import 'call_logs_state.dart';

class CallLogsBloc extends Bloc<CallLogsEvent, CallLogsBlocState> {
  final CallLogService _callLogService = CallLogService();

  CallLogsBloc(CallLogsBlocState initialState) : super(initialState) {
    on<CallLogsEvent>((event, emit) async {
      if(event is LoadCallLogsEvent) {
        final logs = await _callLogService.getCallLogs(passwd: event.passwd);
        final newState = CallsLoadedLogState(callLog: logs);
        emit(newState);
      }
    });
  }
}