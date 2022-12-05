import 'dart:async';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';

import '../../models/dialog_model.dart';
import '../dialogs/dialogs_api_provider.dart';


class DartPusherChannels {

  Channel? channel;
  StreamSubscription? eventSubscription;
  final token = "141|WGFNsqbOXbhDikE0UFWqRSMTX9aKUWdbpI62ps32";
  static const options = PusherChannelOptions.wss(
      host: 'erp.mcfef.com',
      port: 6001,
      key: 'key',
      protocol: 7,
      version: '7.0.3');
  List<StreamSubscription> eventSubscriptions = [];


  connect () async {
    final client = PusherChannelsClient.websocket(
        reconnectTries: 2,
        options: options,
        // Handle the errors based on the web sockets connection
        onConnectionErrorHandle: (error, trace, refresh) {});

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
          final dialogChannel = client.privateChannel('chat.${dialog.dialogId}',
              TokenAuthorizationDelegate(
                  authorizationEndpoint: Uri.parse('https://erp.mcfef.com/broadcasting/auth'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    // 'Referer': 'https://erp.mcfef.com'
                  }));
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