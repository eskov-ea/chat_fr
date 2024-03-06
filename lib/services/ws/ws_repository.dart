import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/message_model.dart';
import 'package:chat/services/ws/ws_repositor_interface.dart';
import 'package:chat/services/dialogs/dialogs_repository.dart';
import 'package:chat/services/logger/logger_service.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';


enum WebsocketEvent { message, status, dialog, join, exit, onlineUsers, online, offline, userEvent }

class WebsocketRepository extends IWebsocketRepository{

  WebsocketRepository._private();

  static final WebsocketRepository _instance = WebsocketRepository._private();
  static WebsocketRepository get instance => _instance;

  PusherChannelsClientLifeCycleState currentState = PusherChannelsClientLifeCycleState.inactive;
  final _secureStorage = DataProvider.storage;
  StreamSubscription<ChannelReadEvent>? presenceChannelSubs;
  PusherChannelsClient? _socket;
  PresenceChannel? presenceChannel;


  final options = const PusherChannelsOptions.fromHost(
    scheme: 'wss',
    key: 'key',
    host: 'erp.mcfef.com',
    shouldSupplyMetadataQueries: true,
    metadata: PusherChannelsOptionsMetadata.byDefault(),
    port: 6001,
  );

  Future<void> connect(List<DialogData> dialogs) async {
    currentState = PusherChannelsClientLifeCycleState.pendingConnection;
    sinkState(currentState);

    List<StreamSubscription> eventSubscriptions = [];
    Map<String, Channel> channels = {};
    StreamSubscription? generalEventSubscription;

    final token = await _secureStorage.getToken();
    final rawUserId = await _secureStorage.getUserId();
    final userId = int.parse(rawUserId!);
    try {
      final List<DialogData>? dialogs = await DialogRepository().getDialogs();

      _socket = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (error, trace, refresh) {
          print("SocketError:  ${error}");
          refresh();
        },
        minimumReconnectDelayDuration: const Duration(
          seconds: 2,
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

      _socket!.lifecycleStream.listen((event) {
        currentState = event;
        sinkState(event);
      });

      _socket!.onConnectionEstablished.listen((event) async {
        print("socket onInitializeSocketEvent connection established");
        for (var subscription in eventSubscriptions) {
          await subscription.cancel();
        }
        await generalEventSubscription?.cancel();

        while (_socket == null) {
          print("Socket null::::");
          Future.delayed(const Duration(milliseconds: 300));
        }
        final Channel channel = clientSubscribeToChannel(
            authToken: token, client: _socket, channelName: 'private-chatinfo');
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
            client: _socket,
            channelName: 'private-userinfo.$rawUserId');
        channels[userInfoChannel.name] = userInfoChannel;
        generalEventSubscription = userInfoChannel.bind('update').listen((event) {
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
            client: _socket,
            channelName: 'presence-onlineinfo',
            authToken: token
        );
        presenceChannel!.subscribeIfNotUnsubscribed();

        _socket?.eventStream.listen(_onSocketEvent);


        if (dialogs != null) {
          for (var dialog in dialogs) {
            final Channel dialogChannel = clientSubscribeToChannel(
                authToken: token,
                client: _socket,
                channelName: 'private-chat.${dialog.dialogId}');
            channels[dialogChannel.name] = dialogChannel;
            StreamSubscription dialogEventSubscription =
            dialogChannel.bind('update').listen((event) {
              print("DialogChannel event:  $event");
              final data = jsonDecode(event.data);
              if (data["message"] != null) {
                final message = MessageData.fromJson(data["message"]);
                print("NEW MESSAGE   ${event.channelName}    ->  $message");
                sinkEvent(WebsocketEventPayload(event: WebsocketEvent.message, data: {
                  "message": message
                }));
              } else if (data["message_status"] != null) {
                final status = MessageStatus.fromJson(data["message_status"]);
                print("UPDATE STATUSES    -> ${status}");
                sinkEvent(WebsocketEventPayload(event: WebsocketEvent.status, data: {
                  "status": status
                }));
              } else if (data["join"] != null) {
                print("EVENTJOIN  ${data["join"]}");
                final user = ChatUser.fromJson(data["join"]);
                sinkEvent(WebsocketEventPayload(event: WebsocketEvent.join, data: {
                  "join": user
                }));
              } else if (data["exit"] != null) {
                final user = ChatUser.fromJson(data["exit"]);
                sinkEvent(WebsocketEventPayload(event: WebsocketEvent.exit, data: {
                  "exit": user
                }));
              }
            });
            dialogChannel.subscribeIfNotUnsubscribed();
            eventSubscriptions.add(dialogEventSubscription);
          }
        }
      });
      await _socket!.connect();
    } catch (_) {

    }
  }

  void reconnect() {
    if (_socket != null) {
      if (currentState != PusherChannelsClientLifeCycleState.reconnecting ||
          currentState != PusherChannelsClientLifeCycleState.establishedConnection ||
          currentState != PusherChannelsClientLifeCycleState.pendingConnection
      ) {
        _socket!.reconnect();
      }
    }
  }

  void trigger(ClientUserEvent event) {
    if (presenceChannel == null) return;
    presenceChannel!.trigger(eventName: "client-user-event",
        data: event.toMap()
    );
  }

  void _onSocketEvent(PusherChannelsReadEvent event) {
    try {
      if (event.rootObject["event"] ==
          "pusher_internal:subscription_succeeded" &&
          event.rootObject["data"] != null) {
        sinkEvent(WebsocketEventPayload(event: WebsocketEvent.onlineUsers, data: {
          "online_users": jsonDecode(event.rootObject["data"])["presence"]["ids"]
        }));
      } else if (event.rootObject["event"] ==
          "pusher_internal:member_removed") {
        print(
            'presenceChannel | Member removed, rootObject is ${jsonDecode(event.rootObject["data"])["user_id"].runtimeType}');
        final int id = int.parse(jsonDecode(event.rootObject["data"])["user_id"]);
        sinkEvent(WebsocketEventPayload(event: WebsocketEvent.offline, data: {
          "offline": id
        }));
      } else if (event.rootObject["event"] == "pusher_internal:member_added") {
        print(
            'presenceChannel | Member added, rootObject is ${jsonDecode(event.rootObject["data"])["user_id"].runtimeType}');
        final id = jsonDecode(event.rootObject["data"])["user_id"];
        sinkEvent(WebsocketEventPayload(event: WebsocketEvent.online, data: {
          "online": id
        }));
      } else if (event.rootObject["event"] == "client-user-event") {
        print("client-user-event  ${event.rootObject}  ${event.rootObject["data"]["event"]}  ${event.rootObject["data"]["fromUser"].runtimeType}");
        final clientEvent = ClientUserEvent.fromJson(event.rootObject["data"]);
        sinkEvent(WebsocketEventPayload(event: WebsocketEvent.userEvent, data: {
          "user_event": clientEvent
        }));
      }
    } catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: AppErrorExceptionType.socket.toString(), additionalInfo: "\r\nEvent was: ${event.rootObject}");
    }
  }
}


clientSubscribeToChannel (
    {required client,
      required String channelName,
      required String? authToken}) {
  return client.privateChannel(
    channelName,
    authorizationDelegate:
    EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint:
        Uri.parse('https://erp.mcfef.com/broadcasting/auth'),
        headers: {
          'Authorization': 'Bearer $authToken',
        }),
  );
}

clientSubscribeToPresenceChannel(
    {required client,
      required String channelName,
      required String? authToken}) {
  return client.presenceChannel(
    channelName,
    authorizationDelegate:
    EndpointAuthorizableChannelTokenAuthorizationDelegate.forPresenceChannel(
        authorizationEndpoint:
        Uri.parse('https://erp.mcfef.com/broadcasting/auth'),
        headers: {
          'Authorization': 'Bearer $authToken',
        }),
  );
}

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup('erp.mcfef.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}
