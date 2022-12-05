import 'package:equatable/equatable.dart';

abstract class CallsEvent{}

class IncomingCallEvent extends CallsEvent {
  final String callerId;

  IncomingCallEvent({required this.callerId});
}

class MissedCallEvent extends CallsEvent {}

class ConnectedCallEvent extends CallsEvent {}

class OutgoingCallEvent extends CallsEvent {
  final String callerId;

  OutgoingCallEvent({required this.callerId});
}

class ErrorCallEvent extends CallsEvent {
  final String callerId;

  ErrorCallEvent({required this.callerId});
}

class ConnectingCallServiceEvent extends CallsEvent {}

class EndedCallServiceEvent extends CallsEvent {}

