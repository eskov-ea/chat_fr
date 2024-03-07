import 'dart:async';
import 'package:chat/services/ws/ws_repository.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';

abstract class IWebsocketRepository {

  final _stateController = StreamController<PusherChannelsClientLifeCycleState>.broadcast();
  final _eventController = StreamController<WebsocketEventPayload>.broadcast();

  Stream<PusherChannelsClientLifeCycleState> get state => _stateController.stream.asBroadcastStream();
  Stream<WebsocketEventPayload> get events => _eventController.stream.asBroadcastStream();

  void sinkState(PusherChannelsClientLifeCycleState payload) => _stateController.sink.add(payload);
  void sinkEvent(WebsocketEventPayload payload) => _eventController.sink.add(payload);
}

class WebsocketStatePayload {
  final PusherChannelsClientLifeCycleState state;
  final Map<String, dynamic>? data;

  WebsocketStatePayload({required this.state, required this.data});
}

class WebsocketEventPayload {
  final WebsocketEvent event;
  final Map<String, dynamic>? data;

  WebsocketEventPayload({required this.event, required this.data});

  @override
  String toString() {
    return "Instance of WebsocketEventPayload [$event:  $data]";
  }
}