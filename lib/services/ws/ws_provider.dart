import 'package:dart_pusher_channels/dart_pusher_channels.dart';

import '../../bloc/ws_bloc/ws_event.dart';


class WebSocketProvider {

  static const options = PusherChannelsOptions.fromHost(
    scheme: 'wss',
    key: 'key',
    host: 'erp.mcfef.com',
    shouldSupplyMetadataQueries: true,
    metadata: PusherChannelsOptionsMetadata.byDefault(),
    port: 6001,
  );

  PusherChannelsClient? connect() {

      final client = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (error, trace, refresh) {
          print("SocketError:  ${error}");
          refresh();
        },
        minimumReconnectDelayDuration: const Duration(
          seconds: 1,
        ),
        defaultActivityDuration: const Duration(
          seconds: 15,
        ),
        activityDurationOverride: const Duration(
          seconds: 15,
        ),
        waitForPongDuration: const Duration(
          seconds: 5,
        )
      );
      return client;
  }

}