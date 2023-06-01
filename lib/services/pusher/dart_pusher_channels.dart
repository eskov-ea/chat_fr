import 'dart:async';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';

import '../../models/dialog_model.dart';
import '../dialogs/dialogs_api_provider.dart';


class DartPusherChannels {

  Channel? channel;
  StreamSubscription? eventSubscription;
  final token = "141|WGFNsqbOXbhDikE0UFWqRSMTX9aKUWdbpI62ps32";
  static const clientOptions = PusherChannelsOptions.fromCluster(
    scheme: 'wss',
    cluster: 'erp',
    key: 'key',
    host: 'erp.mcfef.com',
    shouldSupplyMetadataQueries: true,
    metadata: PusherChannelsOptionsMetadata.byDefault(),
    port: 6001,
  );
  List<StreamSubscription> eventSubscriptions = [];


  connect () async {
    final client = PusherChannelsClient.websocket(
        options: clientOptions,
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
        ));

    final DialogsProvider _dialogsProvider = DialogsProvider();
    final String token = "158|U24yIS6mMrmiDlb1ZdBU6I1TrYnZAwsaGuFWCsmd";
    final List<DialogData>? dialogs = await _dialogsProvider.getDialogs();

    client.onConnectionEstablished.listen((_) async {
      for (var subscription in eventSubscriptions) {
        await subscription.cancel();
      }
      // final channel = socket.privateChannel('private-chatinfo',
      //     TokenAuthorizationDelegate(
      //         authorizationEndpoint: Uri.parse('https://erp.mcfef.com/broadcasting/auth'),
      //         headers: {'Authorization': 'Bearer $token'}));
      // generalEventSubscription = channel.bind('update').listen((event) {
      //
      // });
      // channel.subscribe();
      if (dialogs != null) {
        for (var dialog in dialogs) {
          final dialogChannel = client.privateChannel(
            'chat.${dialog.dialogId}',
            authorizationDelegate: EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
              authorizationEndpoint: Uri.parse('https://erp.mcfef.com/broadcasting/auth'),
              headers: {
                'Authorization': 'Bearer $token',
              }
            ),
          );
          StreamSubscription dialogEventSubscription = dialogChannel.bind('update').listen((event) {
            // print("chatsEventSubscription2:   ${event.data["message"]}");
            if (event.data["message"] != null) {
              // final newMessage = MessageData.fromJson(event.data["message"]);
              print("NEW MESSAGE    -> ");
            } else if (event.data["message_status"] != null) {
              print("UPDATE STATUSES    -> ");
            }
          });
          dialogChannel.subscribe();
          eventSubscriptions.add(dialogEventSubscription);
        }
      }
  });
    client.connect();
  }
}