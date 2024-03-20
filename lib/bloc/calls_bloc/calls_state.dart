import 'package:equatable/equatable.dart';
import 'package:chat/models/call_model.dart';

abstract class CallState extends Equatable {
  final Map<String, CallModel> activeCalls = {};

  addCall(CallModel call) {
    if (!activeCalls.containsKey(call.id)) {
      activeCalls.addAll({call.id: call});
    }
  }
  removeCall(CallModel call) {
    if (activeCalls.containsKey(call.id)) {
      activeCalls.remove(call.id);
    }
  }
}

class EndedCallState extends CallState{
  final CallModel callData;

  EndedCallState({
    required this.callData
  });

  @override
  List<Object?> get props => [runtimeType, callData];
}

class OutgoingCallState extends CallState{
  final CallModel callData;

  OutgoingCallState({required this.callData});

  @override
  List<Object?> get props => [runtimeType, callData];

}

class OutgoingRingingCallState extends CallState{
  final CallModel callData;

  OutgoingRingingCallState({required this.callData});

  @override
  List<Object?> get props => [runtimeType, callData];

}

class IncomingCallState extends CallState {

  final String callerId;

  IncomingCallState({
    required this.callerId
  });

  @override
  List<Object?> get props => [runtimeType, callerId];

}

class ConnectedCallState extends CallState{
  final CallModel callData;
  ConnectedCallState({required this.callData});

  @override
  List<Object?> get props => [runtimeType,callData];
}

class ErrorCallState extends CallState{
  final CallModel callData;
  ErrorCallState({required this.callData});

  @override
  List<Object?> get props => [runtimeType,callData];
}

class StreamRunningCallState extends CallState{
  final CallModel callData;


  StreamRunningCallState({required this.callData});

  @override
  List<Object?> get props => [runtimeType];
}

class PausedCallState extends CallState{
  final CallModel callData;


  PausedCallState({required this.callData});

  @override
  List<Object?> get props => [runtimeType];
}

class ResumedCallState extends CallState{
  final CallModel callData;


  ResumedCallState({required this.callData});

  @override
  List<Object?> get props => [runtimeType];
}

class StreamStopCallState extends CallState{

  StreamStopCallState();

  @override
  List<Object?> get props => [runtimeType];
}

class EndCallWithNoLogState extends CallState{

  EndCallWithNoLogState();

  @override
  List<Object?> get props => [runtimeType];

}

class ReleasedCallState extends CallState{
  ReleasedCallState();

  @override
  List<Object?> get props => [runtimeType];

}