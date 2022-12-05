abstract class CallState  {
  const CallState();

}

class UnconnectedCallServiceState extends CallState{}

class ConnectedCallServiceState extends CallState{

}

class EndedCallServiceState extends CallState{}

class OutgoingCallServiceState extends CallState{
  final String callerName;

  OutgoingCallServiceState({required this.callerName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is IncomingCallState &&
              callerName == other.callerName &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => callerName.hashCode;
}

class IncomingCallState extends CallState {

  final String callerName;

  const IncomingCallState({
    required this.callerName
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is IncomingCallState &&
              callerName == other.callerName &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => callerName.hashCode;
}

class ErrorCallServiceState extends CallState{
  final String callerName;

  ErrorCallServiceState({required this.callerName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is IncomingCallState &&
              callerName == other.callerName &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => callerName.hashCode;
}

class ConnectedCallState extends CallState{}
