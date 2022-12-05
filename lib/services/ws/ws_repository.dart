import 'package:chat/services/ws/ws_provider.dart';
import 'package:dart_pusher_channels/api.dart';

class WebSocketRepository  {
  WebSocketProvider webSocketProvider = WebSocketProvider();

  PusherChannelsClient? WsConnect() => webSocketProvider.connect();
}