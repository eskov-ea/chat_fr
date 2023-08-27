import 'package:equatable/equatable.dart';

import '../../models/call_model.dart';

abstract class CallsEvent{}

class IncomingCallEvent extends CallsEvent {
  final String callerId;

  IncomingCallEvent({required this.callerId});
}

class MissedCallEvent extends CallsEvent {}

class ConnectedCallEvent extends CallsEvent {}

class StreamRunningCallEvent extends CallsEvent {}

class StreamStopCallEvent extends CallsEvent {}

class ConnectionFailedCallEvent extends CallsEvent {}

class OutgoingCallEvent extends CallsEvent {
  final String callerId;

  OutgoingCallEvent({required this.callerId});
}

class ErrorCallEvent extends CallsEvent {
  final String callerId;

  ErrorCallEvent({required this.callerId});
}

class ConnectingCallServiceEvent extends CallsEvent {}

class EndedCallEvent extends CallsEvent {
  final CallModel callData;

  EndedCallEvent({
    required this.callData
  });
}

class EndCallWithNoLogEvent extends CallsEvent {}


