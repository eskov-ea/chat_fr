import 'package:dart_pusher_channels/api.dart';
import 'package:dart_pusher_channels/base.dart';


class WebSocketProvider {

  Channel? channel;
  final token = "141|WGFNsqbOXbhDikE0UFWqRSMTX9aKUWdbpI62ps32";
  static const options = PusherChannelOptions.wss(
      host: 'erp.mcfef.com',
      port: 6001,
      key: 'key',
      protocol: 7,
      version: '7.0.3');

  PusherChannelsClient? connect() {
    try{
      final client = PusherChannelsClient.websocket(
          reconnectTries: 2,
          options: options,
          onConnectionErrorHandle: (error, trace, refresh) {});
      return client;
    } catch (err) {
      print(err);
    }
  }

}