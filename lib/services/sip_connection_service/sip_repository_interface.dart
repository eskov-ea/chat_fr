import 'dart:async';
import 'sip_repository.dart';


abstract class ISipRepository {

  final _stateController = StreamController<SipConnectionState>.broadcast();
  Stream<SipConnectionState> get stream => _stateController.stream.asBroadcastStream();


  void sink(SipConnectionState state) => _stateController.sink.add(state);


}

