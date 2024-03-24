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
  List<StreamSubscription> eventSubscriptions = [];
  Map<String, Channel> channels = {};
  StreamSubscription? generalEventSubscription;


  final options = const PusherChannelsOptions.fromHost(
    scheme: 'wss',
    key: 'key',
    host: 'erp.mcfef.com',
    shouldSupplyMetadataQueries: true,
    metadata: PusherChannelsOptionsMetadata.byDefault(),
    port: 6001,
  );

  Future<void> connect(List<DialogData> dialogs) async {
    print('WS connect:::  $dialogs');
    currentState = PusherChannelsClientLifeCycleState.pendingConnection;
    sinkState(currentState);

    final token = await _secureStorage.getToken();
    final userId = await _secureStorage.getUserId();
    try {
      final List<DialogData> dialogs = await DialogsRepository().getDialogs();

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
        if (currentState == event) return;
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
        clientSubscribeToChatInfoChannel(
            authToken: token, client: _socket, channelName: 'private-chatinfo'
        );


        clientSubscribeToUserInfoChannel(
            authToken: token,
            client: _socket,
            channelName: 'private-userinfo.$userId'
        );


        presenceChannel = clientSubscribeToPresenceChannel(
            client: _socket,
            channelName: 'presence-onlineinfo',
            authToken: token
        );
        presenceChannel!.subscribeIfNotUnsubscribed();

        _socket?.eventStream.listen(_onSocketEvent);


        if (dialogs != null) {
          for (var dialog in dialogs) {
            clientSubscribeToChannel(
                authToken: token,
                client: _socket,
                channelName: 'private-chat.${dialog.dialogId}'
            );
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

  void disconnect() {
    _socket?.disconnect();
  }

  void _onSocketEvent(PusherChannelsReadEvent event) {
    try {
      if (event.rootObject["event"] == "pusher_internal:subscription_succeeded" &&
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

  clientSubscribeToChatInfoChannel({
    required client,
    required String channelName,
    required String? authToken
  }) async {
    final Channel channel = client.privateChannel(
      channelName,
      authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
          authorizationEndpoint:
          Uri.parse('https://erp.mcfef.com/broadcasting/auth'),
          headers: {
            'Authorization': 'Bearer $authToken',
          }),
    );

    final token = await _secureStorage.getToken();
    channels[channel.name] = channel;
    generalEventSubscription = channel.bind('update').listen((event) {
      final DialogData? newDialog = DialogData.fromJson(jsonDecode(event.data)["chat"]);
      print("CHATINFO   ->  $newDialog");
      if (newDialog != null) {
        clientSubscribeToChannel(
            authToken: token,
            client: _socket,
            channelName: 'private-chat.${newDialog.dialogId}'
        );
        sinkEvent(WebsocketEventPayload(event: WebsocketEvent.dialog, data: {
          "dialog": newDialog
        }));
      }
    });
    channel.subscribeIfNotUnsubscribed();
  }

  clientSubscribeToUserInfoChannel({
    required client,
    required String channelName,
    required String? authToken
  }) {
    final Channel userInfoChannel =  client.privateChannel(
      channelName,
      authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
          authorizationEndpoint:
          Uri.parse('https://erp.mcfef.com/broadcasting/auth'),
          headers: {
            'Authorization': 'Bearer $authToken',
          }),
    );

    channels[userInfoChannel.name] = userInfoChannel;
    generalEventSubscription = userInfoChannel.bind('update').listen((event) {
      print("USERINFOCHANNEL  ${event.channelName}   ${jsonDecode(
          event.data)}");
      final data = jsonDecode(event.data);
      if (data["chat_join"] != null) {
        final DialogData? newDialog = DialogData.fromJson(data["chat_join"]);
        if (newDialog != null) {
          sinkEvent(WebsocketEventPayload(event: WebsocketEvent.dialog, data: {
            "dialog": newDialog
          }));
        }
        // TODO: refactor db
      } else if (data["chat_exit"] != null) {
        // TODO: refactor db
// final DialogData newDialog = DialogData.fromJson(data["chat_exit"]);
        // print("UNSUBSCRIBE CHAT   -->   private-chat.${newDialog.dialogId}");
        // add(WsEventDialogDeleted(dialog: newDialog, channelName: "private-chat.${newDialog.dialogId}"));
        return;
      }
    });
    userInfoChannel.subscribeIfNotUnsubscribed();
  }

  clientSubscribeToChannel({
    required client,
    required String channelName,
    required String? authToken
  }) {
    final Channel dialogChannel = client.privateChannel(
      channelName,
      authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
          authorizationEndpoint:
          Uri.parse('https://erp.mcfef.com/broadcasting/auth'),
          headers: {
            'Authorization': 'Bearer $authToken',
          }),
    );
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
        print("EVENTEXIT ${data["exit"]}");
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
