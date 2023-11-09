import 'package:equatable/equatable.dart';
import '../../models/call_model.dart';


abstract class CallState extends Equatable {
  const CallState();

}

class UnconnectedCallServiceState extends CallState{

  @override
  List<Object?> get props => [runtimeType];
}

class ConnectedCallServiceState extends CallState{


  @override
  List<Object?> get props => [runtimeType];
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

  final CallModel callData;

  const IncomingCallState({
    required this.callData
  });

  @override
  List<Object?> get props => [runtimeType, callData];

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