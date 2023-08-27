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

class EndedCallState extends CallState{
  final CallModel callData;

  EndedCallState({
    required this.callData
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EndedCallState &&
              callData.id == other.callData.id &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => callData.hashCode;
}

class OutgoingCallState extends CallState{
  final String callerName;

  OutgoingCallState({required this.callerName});

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

class ErrorCallState extends CallState{
  final String callerName;

  ErrorCallState({required this.callerName});

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

class StreamRunningCallState extends CallState{

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StreamRunningCallState &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class StreamStopCallState extends CallState{

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StreamStopCallState &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class EndCallWithNoLogState extends CallState{

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EndCallWithNoLogState &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}