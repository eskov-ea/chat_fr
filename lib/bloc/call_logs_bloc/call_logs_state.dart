import '../../models/call_model.dart';

abstract class CallLogsBlocState{}

class CallLogInitialState extends CallLogsBlocState{}

class CallsLoadedLogState extends CallLogsBlocState{
  final List<CallModel> callLog;

  CallsLoadedLogState({
    required this.callLog
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CallsLoadedLogState &&
              runtimeType == other.runtimeType &&
              callLog == other.callLog &&
              callLog.length == other.callLog.length;

  @override
  int get hashCode =>
      callLog.hashCode;

  CallsLoadedLogState copyWith({
    List<CallModel>? callLog
  }){
    return CallsLoadedLogState(
      callLog: callLog ?? this.callLog
    );
  }

}