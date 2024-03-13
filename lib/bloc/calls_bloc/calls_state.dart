import 'package:equatable/equatable.dart';
import 'package:chat/models/call_model.dart';

abstract class CallState extends Equatable {
  const CallState();

}

class EndedCallState extends CallState{
  final CallModel callData;

  const EndedCallState({
    required this.callData
  });

  @override
  List<Object?> get props => [runtimeType, callData];
}

class OutgoingCallState extends CallState{
  final CallModel callData;

  const OutgoingCallState({required this.callData});

  @override
  List<Object?> get props => [runtimeType, callData];

}

class OutgoingRingingCallState extends CallState{
  final CallModel callData;

  const OutgoingRingingCallState({required this.callData});

  @override
  List<Object?> get props => [runtimeType, callData];

}

class IncomingCallState extends CallState {

  final String callerId;

  const IncomingCallState({
    required this.callerId
  });

  @override
  List<Object?> get props => [runtimeType, callerId];

}

class ConnectedCallState extends CallState{
  final CallModel callData;
  const ConnectedCallState({required this.callData});

  @override
  List<Object?> get props => [runtimeType,callData];
}

class ErrorCallState extends CallState{
  final CallModel callData;
  const ErrorCallState({required this.callData});

  @override
  List<Object?> get props => [runtimeType,callData];
}

class StreamRunningCallState extends CallState{
  final CallModel callData;


  const StreamRunningCallState({required this.callData});

  @override
  List<Object?> get props => [runtimeType];
}

class StreamStopCallState extends CallState{

  const StreamStopCallState();

  @override
  List<Object?> get props => [runtimeType];
}

class EndCallWithNoLogState extends CallState{

  const EndCallWithNoLogState();

  @override
  List<Object?> get props => [runtimeType];

}

class ReleasedCallState extends CallState{

  const ReleasedCallState();

  @override
  List<Object?> get props => [runtimeType];

}