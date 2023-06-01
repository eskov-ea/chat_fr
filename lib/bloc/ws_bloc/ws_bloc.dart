import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat/bloc/ws_bloc/ws_event.dart';
import 'package:chat/bloc/ws_bloc/ws_state.dart';
import 'package:chat/services/messages/messages_api_provider.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/dialog_model.dart';
import '../../models/message_model.dart';
import '../../services/dialogs/dialogs_api_provider.dart';
import '../../services/ws/ws_repository.dart';
import '../../storage/data_storage.dart';

class WsBloc extends Bloc<WsBlocEvent, WsBlocState> {
  final _webSocketRepository = WebSocketRepository();
  final _secureStorage = DataProvider();
  final WsBlocState initialState;
  final DialogsProvider _dialogsProvider = DialogsProvider();
  final MessagesProvider _messagesProvider = MessagesProvider();
  List<StreamSubscription> eventSubscriptions = [];
  List<Channel?> channels = [];
  StreamSubscription? generalEventSubscription;
  SynchronousStreamController? socketConnectionEventSubscription;
  PusherChannelsClient? socket;
  String? token;
  int? userId;
  late PresenceChannel presenceChannel;

  static const options = PusherChannelsOptions.fromHost(
    scheme: 'wss',
    key: 'key',
    host: 'erp.mcfef.com',
    shouldSupplyMetadataQueries: true,
    metadata: PusherChannelsOptionsMetadata.byDefault(),
    port: 6001,
  );

  WsBloc({required this.initialState}) : super(initialState) {
    on<WsBlocEvent>((event, emit) async {
      if (event is InitializeSocketEvent) {
        await onInitializeSocketEvent(event, emit);
      } else if (event is ConnectingSocketEvent) {
        await onConnectingSocketEvent(event, emit);
      } else if (event is WsEventReceiveNewMessage) {
        onNewMessageReceived(event, emit);
      } else if (event is WsEventUpdateStatus) {
        onWsEventUpdateStatus(event, emit);
      } else if (event is WsEventNewDialogCreated) {
        await onWsNewDialogCreated(event, emit);
      } else if (event is WsEventReconnect) {
        onWsEventReconnect(event, emit);
      } else if (event is WsEventDisconnect) {
        onWsEventDisconnect(event, emit);
      } else if (event is WsEventCloseConnection) {
        onWsEventCloseConnection(event, emit);
      } else if (event is WsEventGetUpdatesOnResume) {
        await onWsEventGetUpdatesOnResume(event, emit);
      } else if (event is WsUserJoinChatEvent) {
        onWsUserJoinChatEvent(event, emit);
      } else if (event is WsUserExitChatEvent) {
        onWsUserExitChatEvent(event, emit);
      }
    });
  }

  onConnectingSocketEvent(event, emit) async {
    // TODO: check if it would be optimize listen to Dialogs Bloc to get dialogs
    emit(Connected(socket: event.socket));
  }

  onInitializeSocketEvent(event, emit) async {
    emit(ConnectingState());
    print("socket onInitializeSocketEvent");
    token = await _secureStorage.getToken();
    final rawUserId = await _secureStorage.getUserId();
    userId = int.parse(rawUserId!);
    final List<DialogData>? dialogs = await _dialogsProvider.getDialogs();

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
          seconds: 15,
        ),
        activityDurationOverride: const Duration(
          seconds: 15,
        ),
        waitForPongDuration: const Duration(
          seconds: 5,
        )
    );

    socket!.onConnectionEstablished.listen((event) async {
      for (var subscription in eventSubscriptions) {
        await subscription.cancel();
      }
      await generalEventSubscription?.cancel();

      final Channel channel = clientSubscribeToChannel(
          authToken: token, client: socket, channelName: 'private-chatinfo');
      channels.add(channel);
      generalEventSubscription = channel.bind('update').listen((event) {
        final DialogData newDialog = DialogData.fromJson(event.data["chat"]);
        print("CHATINFO   ->  $newDialog");
        for (var user in newDialog.usersList) {
          if (user.id == userId) {
            add(WsEventNewDialogCreated(dialog: newDialog, socket: socket!));
            return;
          }
        }
      });
      channel.subscribeIfNotUnsubscribed();

      final Channel userInfoChannel = clientSubscribeToChannel(
          authToken: token,
          client: socket,
          channelName: 'private-userinfo.$rawUserId');
      channels.add(userInfoChannel);
      generalEventSubscription = channel.bind('update').listen((event) {
        print("USERINFOCHANNEL   $event");
      });
      userInfoChannel.subscribeIfNotUnsubscribed();

      presenceChannel = clientSubscribeToPresenceChannel(
        client: socket,
        channelName: 'presence-channel',
        authToken: token
      );
      presenceChannel.subscribeIfNotUnsubscribed();
      print("presenceChannel  ${presenceChannel.state?.status} ${presenceChannel.state?.subscriptionCount}");
      presenceChannel.trigger(eventName: 'join', data: {'userId' : 40});
      presenceChannel.whenMemberAdded().listen((event) {
        print('Member added, now members count is ${presenceChannel.state?.members?.membersCount}');
      });

      StreamSubscription<ChannelReadEvent> presenceChannelSubs = presenceChannel.bindToAll().listen((event) {
        print("presenceChannel event:  ${event}");
      });

      if (dialogs != null) {
        for (var dialog in dialogs) {
          final Channel dialogChannel = clientSubscribeToChannel(
              authToken: token,
              client: socket,
              channelName: 'private-chat.${dialog.dialogId}');
          channels.add(dialogChannel);
          StreamSubscription dialogEventSubscription =
            dialogChannel.bind('update').listen((event) {
              print("DialogChannel event:  $event");
              final data = jsonDecode(event.data);
              if (data["message"] != null) {
                final newMessage = MessageData.fromJson(data["message"]);
                print("NEW MESSAGE    ->  $newMessage");
                Future.delayed(Duration(seconds: 1)).then((v) {
                  add(WsEventReceiveNewMessage(message: newMessage));
                });
                // add(WsEventReceiveNewMessage(message: newMessage));
              } else if (data["message_status"] != null) {
                final newStatuses =
                    MessageStatuses.fromJson([data["message_status"]]);
                print("UPDATE STATUSES    -> ${newStatuses.last}");
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
    socket!.connect();
    emit(Connected(socket: socket!));
  }

  void onNewMessageReceived(event, emit) {
    emit(WsStateReceiveNewMessage(message: event.message));
  }

  void onWsUserJoinChatEvent(WsUserJoinChatEvent event, emit) {
    emit(WsStateNewUserJoinDialog(user: event.user, dialogId: event.dialogId));
  }

  void onWsUserExitChatEvent(WsUserExitChatEvent event, emit) {
    emit(WsStateNewUserExitDialog(user: event.user, dialogId: event.dialogId));
  }

  void onWsEventUpdateStatus(event, emit) {
    emit(WsStateUpdateStatus(statuses: event.statuses));
  }

  Future<void> onWsNewDialogCreated(event, emit) async {
    final dialogChannel = clientSubscribeToChannel(
      authToken: token,
      client: socket,
      channelName: 'private-chat.${event.dialog.dialogId}');
    StreamSubscription dialogEventSubscription =
      dialogChannel.bind('update').listen((event) {
        final data = jsonDecode(event.data);
        if (data["message"] != null &&
            data["message"]["user_id"] != userId) {
          final newMessage = MessageData.fromJson(data["message"]);
          print("NEW MESSAGE    ->  $newMessage");
          // add(WsEventReceiveNewMessage(message: newMessage));
          Future.microtask(() {
            add(WsEventReceiveNewMessage(message: newMessage));
          });
        } else if (data["message_status"] != null) {
          final newStatuses =
              MessageStatuses.fromJson([data["message_status"]]);
          add(WsEventUpdateStatus(statuses: newStatuses));
        }
      });
    dialogChannel.subscribe();
    eventSubscriptions.add(dialogEventSubscription);
    emit(WsStateNewDialogCreated(dialog: event.dialog));
  }

  void onWsEventDisconnected(event, emit) {
    emit(Unconnected());
  }

  void onWsEventReconnect(event, emit) {
    print("onWsEventReconnect");
    // for(var channel in channels) {
    //   channel?.subscribe();
    // }
    socket!.reconnect();
  }

  void onWsEventCloseConnection(event, emit) async {
    print("onWsEventCloseConnection");
    emit(Unconnected());
    await generalEventSubscription?.cancel();
    for (var eventSubscription in eventSubscriptions) {
      await eventSubscription.cancel();
    }
    for (var channel in channels) {
      try {
        channel?.unsubscribe();
      } catch (err) {
        print(err);
      }
    }
    generalEventSubscription = null;
    eventSubscriptions = [];
    socket?.dispose();
    socket = null;
    print("onWsEventGetUpdatesOnResume start");
    while (await hasNetwork() != true) {
      print("CHECK FOR INTERNET CONNECTIVITY");
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  void onWsEventDisconnect(event, emit) async {
    print("onWsEventDisconnect");
    emit(Unconnected());
    await generalEventSubscription?.cancel();
    for (var eventSubscription in eventSubscriptions) {
      await eventSubscription.cancel();
    }
    for (var channel in channels) {
      try {
        channel?.unsubscribe();
      } catch (err) {
        print(err);
      }
    }
    generalEventSubscription = null;
    eventSubscriptions = [];
    socket?.dispose();
    socket = null;
    print("onWsEventGetUpdatesOnResume start");
    while (await hasNetwork() != true) {
      print("CHECK FOR INTERNET CONNECTIVITY");
      await Future.delayed(const Duration(seconds: 3));
    }
    add(InitializeSocketEvent());
    while (socket == null) {
      //TODO: need to find a way to listen to the socket creation completed
      print("CHECK FOR SOCKET CREATION COMPLETED");
      await Future.delayed(const Duration(seconds: 1));
    }
    print("InitializeSocketEvent");
    add(WsEventGetUpdatesOnResume());
  }

  onWsEventGetUpdatesOnResume(event, emit) async {
    print("onWsEventGetUpdatesOnResume");

    // emit(Unconnected());
    // final List<DialogData>? dialogs = await _dialogsProvider.getDialogs();
    // if (dialogs != null && dialogs.isNotEmpty) {
    //   for (var dialog in dialogs) {
    //     add(WsEventNewDialogCreated(socket: socket!, dialog: dialog));
    //   }
    // }
    final Map<String, dynamic>? newUpdates =
        await _messagesProvider.getNewUpdatesOnResume();
    print(
        "newUpdates   $newUpdates     dialogsCollection     ${newUpdates?["chats"]}");
    if (newUpdates == null) return;
    final List<dynamic>? dialogsCollection = newUpdates["chats"];
    final List<dynamic>? messagesCollection = newUpdates["chat_messages"];
    final List<dynamic>? statusesCollection =
        newUpdates["chat_message_status_users"];

    if (dialogsCollection!.isNotEmpty) {
      final List<DialogData> newDialogs = dialogsCollection
          .map((dialog) => DialogData.fromJson(dialog))
          .toList();
      print("UPDATED_INFO DIALOGS    $newDialogs");
      for (var dialog in newDialogs) {
        //TODO: remove socket from event parameter
        add(WsEventNewDialogCreated(dialog: dialog, socket: socket!));
      }
    }
    if (messagesCollection!.isNotEmpty) {
      final List<MessageData> newMessages = messagesCollection
          .map((message) => MessageData.fromJson(message))
          .toList();
      print("UPDATED_INFO MESSAGES    $newMessages");

      for (var message in newMessages) {
        add(WsEventReceiveNewMessage(message: message));
      }
    }
    if (statusesCollection!.isNotEmpty) {
      final List<MessageStatuses> newStatuses =
          MessageStatuses.fromJson(statusesCollection).toList();
      print("UPDATED_INFO STATUSES    $newStatuses");
      add(WsEventUpdateStatus(statuses: newStatuses));
    }
  }
}

clientSubscribeToChannel(
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
