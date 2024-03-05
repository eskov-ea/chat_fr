import 'dart:async';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/services/dialogs/dialogs_repository.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';


https://github.com/slovnicki/reactive_repositories/blob/master/lib/domain/items/items_repository.dart
https://verygood.ventures/blog/how-to-use-bloc-with-streams-and-concurrency
https://pub.dev/packages/get_it

enum WSState { unconnected, connecting, connected, error }

class WebsocketRepository extends IWebsocketRepository{

  WSState state = WSState.unconnected;
  final _secureStorage = DataProvider.storage;
  PusherChannelsClient? socket;

  final options = PusherChannelsOptions.fromHost(
    scheme: 'wss',
    key: 'key',
    host: 'erp.mcfef.com',
    shouldSupplyMetadataQueries: true,
    metadata: PusherChannelsOptionsMetadata.byDefault(),
    port: 6001,
  );

  Future<void> connect() async {
    state = WSState.connecting;
    final token = await _secureStorage.getToken();
    final rawUserId = await _secureStorage.getUserId();
    final userId = int.parse(rawUserId!);
    try {
      final List<DialogData>? dialogs = await DialogRepository().getDialogs();

      socket = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (error, trace, refresh) {
          print("SocketError:  ${error}");
          add(WsEventDisconnect());
          refresh();
        },
        minimumReconnectDelayDuration: const Duration(
          seconds: 1,
        ),
        defaultActivityDuration: const Duration(
          seconds: 5,
        ),
        activityDurationOverride: const Duration(
          seconds: 5,
        ),
        waitForPongDuration: const Duration(
          seconds: 5,
        ),
      );


      socket!.onConnectionEstablished.listen((event) async {
        print("socket onInitializeSocketEvent connection established");
        for (var subscription in eventSubscriptions) {
          await subscription.cancel();
        }
        await generalEventSubscription?.cancel();

        while (socket == null) {
          print("Socket null::::");
          Future.delayed(const Duration(milliseconds: 300));
        }
        final Channel channel = clientSubscribeToChannel(
            authToken: token, client: socket, channelName: 'private-chatinfo');
        channels[channel.name] = channel;
        generalEventSubscription = channel.bind('update').listen((event) {
          // final DialogData newDialog = DialogData.fromJson(jsonDecode(event.data)["chat"]);
          // print("CHATINFO   ->  $newDialog");
          //TODO: refactor db      new dialog comes
          // for (var user in newDialog.usersList) {
          //   if (user.id == userId) {
          //     add(WsEventNewDialogCreated(dialog: newDialog));
          //     return;
          //   }
          // }
        });
        channel.subscribeIfNotUnsubscribed();

        final Channel userInfoChannel = clientSubscribeToChannel(
            authToken: token,
            client: socket,
            channelName: 'private-userinfo.$rawUserId');
        channels[userInfoChannel.name] = userInfoChannel;
        generalEventSubscription =
            userInfoChannel.bind('update').listen((event) {
              print("USERINFOCHANNEL  ${event.channelName}   ${jsonDecode(
                  event.data)}");
              final data = jsonDecode(event.data);
              if (data["chat_join"] != null) {
                // final DialogData newDialog = DialogData.fromJson(data["chat_join"]);
                //TODO: refactor db
                // for (var user in newDialog.usersList) {
                //   if (user.id == userId) {
                //     add(WsEventNewDialogCreated(dialog: newDialog));
                //     return;
                //   }
                // }
              } else if (data["chat_exit"] != null) {
                //TODO: refactor db
// final DialogData newDialog = DialogData.fromJson(data["chat_exit"]);
                // print("UNSUBSCRIBE CHAT   -->   private-chat.${newDialog.dialogId}");
                // add(WsEventDialogDeleted(dialog: newDialog, channelName: "private-chat.${newDialog.dialogId}"));
                return;
              }
            });
        userInfoChannel.subscribeIfNotUnsubscribed();

        presenceChannel = clientSubscribeToPresenceChannel(
            client: socket,
            channelName: 'presence-onlineinfo',
            authToken: token
        );
        presenceChannel!.subscribeIfNotUnsubscribed();

        socket?.eventStream.listen(_onSocketEvent);


        if (dialogs != null) {
          for (var dialog in dialogs) {
            final Channel dialogChannel = clientSubscribeToChannel(
                authToken: token,
                client: socket,
                channelName: 'private-chat.${dialog.dialogId}');
            channels[dialogChannel.name] = dialogChannel;
            StreamSubscription dialogEventSubscription =
            dialogChannel.bind('update').listen((event) {
              print("DialogChannel event:  $event");
              final data = jsonDecode(event.data);
              if (data["message"] != null) {
                final newMessage = MessageData.fromJson(data["message"]);
                print("NEW MESSAGE   ${event.channelName}    ->  $newMessage");
                Future.delayed(Duration(seconds: 1)).then((v) {
                  add(WsEventReceiveNewMessage(message: newMessage));
                });
              } else if (data["message_status"] != null) {
                final newStatuses = [
                  MessageStatus.fromJson(data["message_status"])
                ];
                print("UPDATE STATUSES    -> ${newStatuses}");
                add(WsEventUpdateStatus(statuses: newStatuses));
              } else if (data["join"] != null) {
                print("EVENTJOIN  ${data["join"]}");
                final user = ChatUser.fromJson(data["join"]);
                add(WsUserJoinChatEvent(user: user, dialogId: dialog.dialogId));
              } else if (data["exit"] != null) {
                final user = ChatUser.fromJson(data["exit"]);
                add(WsUserExitChatEvent(user: user, dialogId: dialog.dialogId));
              }
            });
            dialogChannel.subscribeIfNotUnsubscribed();
            eventSubscriptions.add(dialogEventSubscription);
          }
        }
      });
      await socket!.connect();
      emit(const Connected());
    } catch (_) {

    }
  }
}


abstract class IWebsocketRepository {
  final _controller = StreamController();

  Stream get items => _controller.stream.asBroadcastStream();
  void get close => _controller.stream.close();

  void addToStream(items) => _controller.sink.add(items);
}