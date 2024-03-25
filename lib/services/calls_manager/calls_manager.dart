import 'dart:async';
import 'package:chat/bloc/calls_bloc/calls_state.dart';
import 'package:chat/models/call_model.dart';


class CallsManager {

  CallsManager._private();

  static final CallsManager _instance = CallsManager._private();
  static CallsManager get instance => _instance;

  final Map<String, ActiveCallModel> _activeCalls = {};
  late final StreamSubscription<CallState> _subscription;

  final _stateController = StreamController<Map<String, ActiveCallModel>>.broadcast();
  Stream<Map<String, ActiveCallModel>> get stream => _stateController.stream.asBroadcastStream();



  void subscribe(Stream<CallState> stream) {
    _subscription = stream.listen(_onCallStateChange);
  }


  void _notify() => _stateController.sink.add(_activeCalls);
  void _onCallStateChange(CallState state) {
    print('Calls manager state listener:: $state');
    if (state is IncomingCallState) {

    }
    else if (state is EndedCallState) {

    }
    else if (state is OutgoingCallState) {

    }
    else if (state is ConnectedCallState) {

    }
    else if (state is StreamRunningCallState) {

    }
    else if (state is StreamStopCallState) {

    }
    else if (state is ErrorCallState) {

    }
    else if (state is OutgoingRingingCallState) {

    }
    else if (state is EndCallWithNoLogState) {

    }
  }
}

class ActiveCallModel {
  final CallModel call;
  final CallState callState;
  final Timer timer;

  ActiveCallModel({required this.call, required this.callState, required this.timer});
}
