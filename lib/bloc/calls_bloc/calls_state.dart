import '../../models/call_model.dart';

abstract class CallState  {
  const CallState();

}

class UnconnectedCallServiceState extends CallState{

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UnconnectedCallServiceState &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class ConnectedCallServiceState extends CallState{

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ConnectedCallServiceState &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class EndedCallServiceState extends CallState{
  final CallModel callData;

  EndedCallServiceState({
    required this.callData
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EndedCallServiceState &&
              callData.id == other.callData.id &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => callData.hashCode;
}

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

class ConnectedCallState extends CallState{

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ConnectedCallState &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class EndCallWithNoLogServiceState extends CallState{

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EndCallWithNoLogServiceState &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}