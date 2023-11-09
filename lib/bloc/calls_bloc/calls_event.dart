import 'package:equatable/equatable.dart';

import '../../models/call_model.dart';

abstract class CallsEvent{}

class IncomingCallEvent extends CallsEvent {
  final CallModel callData;

  IncomingCallEvent({required this.callData});
}

class MissedCallEvent extends CallsEvent {}

class ConnectedCallEvent extends CallsEvent {
  final CallModel callData;

  ConnectedCallEvent({required this.callData});
}

class StreamRunningCallEvent extends CallsEvent {
  final CallModel callData;

  StreamRunningCallEvent({required this.callData});
}

class StreamStopCallEvent extends CallsEvent {}

class ConnectionFailedCallEvent extends CallsEvent {}

class OutgoingCallEvent extends CallsEvent {
  final CallModel callData;

  OutgoingCallEvent({required this.callData});
}

class OutgoingRingingCallEvent extends CallsEvent {
  final CallModel callData;

  OutgoingRingingCallEvent({required this.callData});
}

class ErrorCallEvent extends CallsEvent {
  final CallModel callData;

  ErrorCallEvent({required this.callData});
}

class ConnectingCallServiceEvent extends CallsEvent {}

class EndedCallEvent extends CallsEvent {
  final CallModel callData;

  EndedCallEvent({
    required this.callData
  });
}

class EndCallWithNoLogEvent extends CallsEvent {}


