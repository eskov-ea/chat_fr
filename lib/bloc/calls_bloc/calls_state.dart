import 'package:chat/services/global.dart';
import 'package:chat/services/helpers/call_timer.dart';
import 'package:equatable/equatable.dart';
import 'package:chat/models/call_model.dart';

final Map<String, ActiveCallModel> _activeCalls = {};

class ActiveCallModel {
  final CallModel call;
  final CallTimer timer;
  final bool outgoing;
  int callState;
  bool active;

  ActiveCallModel({required this.call, required this.callState,
    required this.active, required this.timer, required this.outgoing});
}

abstract class CallState extends Equatable {
  addCall(CallModel call, {bool outgoing = false}) {
    if (!_activeCalls.containsKey(call.id)) {
      bool active = false;
      if (_activeCalls.isEmpty) active = true;
      if (outgoing) {
        _activeCalls.forEach((key, call) {
          call.active = false;
        });
        active = true;
      }
      final ac = ActiveCallModel(call: call, callState: call.callState!, timer: CallTimer(call.id),
          active: active, outgoing: outgoing);
      _activeCalls.addAll({call.id: ac});
    }
  }
  removeCall(CallModel call) {
    if (_activeCalls.containsKey(call.id)) {
      _activeCalls[call.id]?.timer.stop();
      _activeCalls[call.id]?.timer.close();
      _activeCalls.remove(call.id);
    }
    if (_activeCalls.isNotEmpty) {
    print('removeCall resume  ${_activeCalls.values.first.call.id} ${_activeCalls.values.first.call.callState}');
      resumeCall(_activeCalls.values.first.call.id);
    }
  }
  update(CallModel call, bool active) {
    if (_activeCalls.containsKey(call.id)) {
      _activeCalls[call.id]!.callState = call.callState!;
      if (active) {
        _activeCalls.values.forEach((c) {
          c.active = false;
        });
        _activeCalls[call.id]!.active = true;
      }
    }
  }
  pauseTimer(String callId) {
    _activeCalls[callId]?.timer.pause();
  }
  resumeTimer(String callId) {
    _activeCalls[callId]?.timer.resume();
  }
  stopTimer(String callId) {
    _activeCalls[callId]?.timer.stop();
  }
  startTimer(String callId) {
    _activeCalls[callId]?.timer.start();
  }

  Map<String, ActiveCallModel> get activeCalls => _activeCalls;
  ActiveCallModel? get activeCall {
    for (var call in _activeCalls.values) {
      if (call.active) return call;
    }
    return null;
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

  final CallModel callData;

  IncomingCallState({
    required this.callData
  });

  @override
  List<Object?> get props => [];

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