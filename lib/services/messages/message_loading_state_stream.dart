import 'dart:async';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';


class MessageLoadingStateStreamer {

  MessageLoadingStateStreamer._private();

  static final MessageLoadingStateStreamer _instance = MessageLoadingStateStreamer._private();
  static MessageLoadingStateStreamer get instance => _instance;

  final _stateController = StreamController<MessageLoadingState>.broadcast();
  Stream<MessageLoadingState> get stream => _stateController.stream.asBroadcastStream();


  void sink(MessageLoadingState state) => _stateController.sink.add(state);

}

class MessageLoadingState {
  final int dialogId;
  final bool status;
  final AppErrorException? error;

  MessageLoadingState({required this.dialogId, required this.status, required this.error});
}