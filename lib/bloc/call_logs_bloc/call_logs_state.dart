import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import '../../models/call_model.dart';

abstract class CallLogsBlocState{
  final List<CallModel> callLog = [];
  final Map<String, bool> logsDictionary = {};
  final AppErrorExceptionType? errorType = null;
}

class CallLogInitialState extends CallLogsBlocState{}

class CallLogErrorState extends CallLogsBlocState{
  final AppErrorExceptionType? errorType;

  CallLogErrorState({required this.errorType});
}

class CallsLoadedLogState extends CallLogsBlocState{
  final List<CallModel> callLog;
  final Map<String, bool> logsDictionary;

  CallsLoadedLogState({
    required this.callLog,
    required this.logsDictionary
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CallsLoadedLogState &&
              runtimeType == other.runtimeType &&
              callLog == other.callLog &&
              callLog.length == other.callLog.length &&
              callLog.length == other.callLog.length &&
              logsDictionary.length == other.logsDictionary.length;

  @override
  int get hashCode =>
      callLog.hashCode ^ callLog.length.hashCode ^ logsDictionary.length.hashCode;

  CallsLoadedLogState copyWith({
    List<CallModel>? callLog,
    Map<String, bool>? logsDictionary
  }){
    return CallsLoadedLogState(
      callLog: callLog ?? this.callLog,
      logsDictionary: logsDictionary ?? this.logsDictionary
    );
  }

}

class CallsLogLogoutState extends CallLogsBlocState {}