import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/bloc/ws_bloc/ws_event.dart';
import 'package:chat/bloc/ws_bloc/ws_state.dart';
import 'package:chat/services/logger/logger_service.dart';
import 'package:chat/services/messages/messages_api_provider.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/dialog_model.dart';
import '../../models/message_model.dart';
import '../../services/dialogs/dialogs_repository.dart';
import '../../storage/data_storage.dart';

class WsBloc extends Bloc<WsBlocEvent, WsBlocState> {
  final DataProvider secureStorage;
  final WsBlocState initialState;
  final DialogRepository dialogsRepository;
  final MessagesProvider _messagesProvider = MessagesProvider();
  List<StreamSubscription> eventSubscriptions = [];
  // List<Channel?> channels = [];
  Map<String, Channel> channels = {};
  // Map<String, StreamSubscription> eventSubscriptions = {};
  StreamSubscription? generalEventSubscription;
  SynchronousStreamController? socketConnectionEventSubscription;
  PusherChannelsClient? socket;
  String? token;
  int? userId;
  PresenceChannel? presenceChannel;
  StreamSubscription<ChannelReadEvent>? presenceChannelSubs;

  static const options = PusherChannelsOptions.fromHost(
    scheme: 'wss',
    key: 'key',
    host: 'erp.mcfef.com',
    shouldSupplyMetadataQueries: true,
    metadata: PusherChannelsOptionsMetadata.byDefault(),
    port: 6001,
  );

  WsBloc({
    required this.initialState,
    required this.dialogsRepository,
    required this.secureStorage
  }) : super(initialState) {
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
        onWsEventReconnect(event, emit);
      } else if (event is WsEventCloseConnection) {
        onWsEventCloseConnection(event, emit);
      } else if (event is WsEventGetUpdatesOnResume) {
        await onWsEventGetUpdatesOnResume(event, emit);
      } else if (event is WsUserJoinChatEvent) {
        onWsUserJoinChatEvent(event, emit);
      } else if (event is WsUserExitChatEvent) {
        onWsUserExitChatEvent(event, emit);
      } else if (event is WsOnlineUsersInitialEvent) {
        onWsOnlineUsersInitialEvent(event, emit);
      } else if (event is WsOnlineUsersExitEvent) {
        onWsOnlineUsersExitEvent(event, emit);
      } else if (event is WsOnlineUsersJoinEvent) {
        onWsOnlineUsersJoinEvent(event, emit);
      } else if (event is WsOnlineUserTypingEvent) {
        onWsOnlineUserTypingEvent(event, emit);
      } else if (event is WsEventDialogDeleted) {
        onWsEventDialogDeleted(event, emit);
      }
    });
  }

  onConnectingSocketEvent(event, emit) async {
    // TODO: check if it would be optimize listen to Dialogs Bloc to get dialogs
    emit(Connected());
  }

  onInitializeSocketEvent(event, emit) async {
    emit(ConnectingState());
    print("socket onInitializeSocketEvent");
    token = await secureStorage.getToken();
    final rawUserId = await secureStorage.getUserId();
    userId = int.parse(rawUserId!);
    try {
      final List<DialogData>? dialogs = await dialogsRepository.getDialogs();

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

      final Channel channel = clientSubscribeToChannel(
          authToken: token, client: socket, channelName: 'private-chatinfo');
      channels[channel.name] = channel;
      generalEventSubscription = channel.bind('update').listen((event) {
        final DialogData newDialog = DialogData.fromJson(jsonDecode(event.data)["chat"]);
        print("CHATINFO   ->  $newDialog");
        for (var user in newDialog.usersList) {
          if (user.id == userId) {
            add(WsEventNewDialogCreated(dialog: newDialog));
            return;
          }
        }
      });
      channel.subscribeIfNotUnsubscribed();

      final Channel userInfoChannel = clientSubscribeToChannel(
          authToken: token,
          client: socket,
          channelName: 'private-userinfo.$rawUserId');
      channels[userInfoChannel.name] = userInfoChannel;
      generalEventSubscription = userInfoChannel.bind('update').listen((event) {
        print("USERINFOCHANNEL  ${event.channelName}   ${jsonDecode(event.data)}");
        final data = jsonDecode(event.data);
        if (data["chat_join"] != null) {
          final DialogData newDialog = DialogData.fromJson(data["chat_join"]);
          for (var user in newDialog.usersList) {
            if (user.id == userId) {
              add(WsEventNewDialogCreated(dialog: newDialog));
              return;
            }
          }
        } else if(data["chat_exit"] != null) {
          final DialogData newDialog = DialogData.fromJson(data["chat_exit"]);
          print("UNSUBSCRIBE CHAT   -->   private-chat.${newDialog.dialogId}");
          add(WsEventDialogDeleted(dialog: newDialog, channelName: "private-chat.${newDialog.dialogId}"));
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
                final newStatuses =
                    MessageStatuses.fromJson([data["message_status"]]);
                print("UPDATE STATUSES    -> ${newStatuses.last.statusId}");
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
      emit(Connected());
    } catch (_) {
      emit(Unconnected());
    }
  }

  void _onSocketEvent(PusherChannelsReadEvent event) {
    try {
      if (event.rootObject["event"] ==
              "pusher_internal:subscription_succeeded" &&
          event.rootObject["data"] != null) {
        add(WsOnlineUsersInitialEvent(
            onlineUsers: jsonDecode(event.rootObject["data"])["presence"]
                ["ids"]));
      } else if (event.rootObject["event"] ==
          "pusher_internal:member_removed") {
        print(
            'presenceChannel | Member removed, rootObject is ${jsonDecode(event.rootObject["data"])["user_id"].runtimeType}');
        final int id =
            int.parse(jsonDecode(event.rootObject["data"])["user_id"]);
        add(WsOnlineUsersExitEvent(userId: id));
      } else if (event.rootObject["event"] == "pusher_internal:member_added") {
        print(
            'presenceChannel | Member added, rootObject is ${jsonDecode(event.rootObject["data"])["user_id"].runtimeType}');
        add(WsOnlineUsersJoinEvent(
            userId: jsonDecode(event.rootObject["data"])["user_id"]));
      } else if (event.rootObject["event"] == "client-user-event") {
        print(
            "client-user-event  ${event.rootObject}  ${event.rootObject["data"]["event"]}  ${event.rootObject["data"]["fromUser"].runtimeType}");
        add(WsOnlineUserTypingEvent(
            clientEvent: ClientUserEvent.fromJson(event.rootObject["data"]),
            dialogId: event.rootObject["data"]["dialogId"]));
      }
    } catch(err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, errorType: AppErrorExceptionType.socket.toString(), additionalInfo: "\r\nEvent was: ${event.rootObject}");
    }
  }

  void onNewMessageReceived(event, emit) {
    try {
      emit(WsStateReceiveNewMessage(message: event.message));
    } catch (err, stackTrace) {
      Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Event message was: [ $event, ${event.message} ]");
    }
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

  void onWsEventDialogDeleted(WsEventDialogDeleted event, emit) async {
    print("onWsEventDialogDeleted");
    channels[event.channelName]?.unsubscribe();
    print("UNSUBSCRIBE CHAT   ${channels[event.channelName]?.state}");
    channels.remove(event.channelName);
    emit(WsStateDialogDeleted(dialog: event.dialog, channelName: event.channelName));
  }

  void onWsEventDisconnected(event, emit) {
    emit(Unconnected());
  }


  void onWsEventCloseConnection(event, emit) async {
    print("onWsEventCloseConnection");
    await generalEventSubscription?.cancel();
    for (var eventSubscription in eventSubscriptions) {
      await eventSubscription.cancel();
    }
    channels.forEach((key, value) {
      try {
        channels[key]?.unsubscribe();
      } catch (err) {
        print(err);
      }
    });
    presenceChannel?.unsubscribe();
    generalEventSubscription = null;
    eventSubscriptions = [];
    socket?.dispose();
    socket = null;
    print("onWsEventGetUpdatesOnResume start");
    emit(Unconnected());
  }

  void onWsEventReconnect(event, emit) async {
    emit(Unconnected());
    await generalEventSubscription?.cancel();
    for (var eventSubscription in eventSubscriptions) {
      await eventSubscription.cancel();
    }
    channels.forEach((key, value) {
      try {
        channels[key]?.unsubscribe();
      } catch (err) {
        print(err);
      }
    });
    presenceChannel?.unsubscribe();
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
        add(WsEventNewDialogCreated(dialog: dialog));
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

void onWsOnlineUsersJoinEvent (WsOnlineUsersJoinEvent event, Emitter<WsBlocState> emit) {
  emit(WsStateOnlineUsersJoinState(userId: event.userId));
}

void onWsOnlineUsersInitialEvent(WsOnlineUsersInitialEvent event, Emitter<WsBlocState> emit) {
  try {
    emit(WsStateOnlineUsersInitialState(onlineUsers: event.onlineUsers));
  } catch(err, stackTrace) {
    Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: "Event online users were: [ $event, ${event.onlineUsers} ]");
  }
}

void onWsOnlineUsersExitEvent (WsOnlineUsersExitEvent event, Emitter<WsBlocState> emit) {
  emit(WsStateOnlineUsersExitState(userId: event.userId));
}

void onWsOnlineUserTypingEvent(WsOnlineUserTypingEvent event, Emitter<WsBlocState> emit) {
  print("onWsOnlineUserTypingEvent");
  emit(WsOnlineUserTypingState(
    clientEvent: event.clientEvent,
    dialogId: event.dialogId
  ));
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
