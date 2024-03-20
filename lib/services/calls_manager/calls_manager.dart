import 'dart:async';
import 'package:chat/models/call_model.dart';


class CallsManager {

  CallsManager._private();

  static final CallsManager _instance = CallsManager._private();
  static CallsManager get instance => _instance;

  final Map<String, CallModel> _activeCalls = {};

  final _stateController = StreamController<Map<String, CallModel>>.broadcast();
  Stream<Map<String, CallModel>> get stream => _stateController.stream.asBroadcastStream();


  void notify() => _stateController.sink.add(_activeCalls);

}
