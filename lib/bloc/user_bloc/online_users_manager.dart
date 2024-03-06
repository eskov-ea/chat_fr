import 'dart:async';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/services/ws/ws_repositor_interface.dart';
import 'package:chat/services/ws/ws_repository.dart';

class UserOnlineStatusManager {

  UserOnlineStatusManager._private() {
    _controller = _websocketRepo.events.listen((payload) {
      if (payload.event == WebsocketEvent.onlineUsers) {
        final List users = payload.data?["online_users"];
        print('online start:::  $users');
        users.forEach((id) {
          _onlineUsers.addAll({id:true});
          _sinkStatus({id:true});
        });
      } else if (payload.event == WebsocketEvent.online) {
        _onlineUsers.addAll({(payload.data?["online"]):true});
        _sinkStatus({(payload.data?["online"]):true});
      } else if (payload.event == WebsocketEvent.offline) {
        _onlineUsers.remove(payload.data?["offline"]);
        _sinkStatus({(payload.data?["offline"]):false});
      } else if (payload.event == WebsocketEvent.userEvent) {
        final ClientUserEvent userEvent = payload.data?["user_event"];
        _usersEvents.addAll({userEvent.dialogId:userEvent});
        _sinkEvent(userEvent);
      }
    });
  }

  static final UserOnlineStatusManager _instance = UserOnlineStatusManager._private();
  static UserOnlineStatusManager get instance => _instance;
  final WebsocketRepository _websocketRepo = WebsocketRepository.instance;
  late final StreamSubscription<WebsocketEventPayload> _controller;

  final _statusController = StreamController<Map<int, bool>>.broadcast();
  final _eventController = StreamController<ClientUserEvent>.broadcast();

  void _sinkStatus(Map<int, bool> status) => _statusController.sink.add(status);
  void _sinkEvent(ClientUserEvent event) => _eventController.sink.add(event);
  final Map<int, bool> _onlineUsers = {};
  final Map<int, ClientUserEvent> _usersEvents = {};


  Stream<Map<int, bool>> get status => _statusController.stream.asBroadcastStream();
  Stream<ClientUserEvent> get event => _eventController.stream.asBroadcastStream();
  Map<int, bool> get onlineUsers => _onlineUsers;
  Map<int, ClientUserEvent> get events => _usersEvents;
  void sendEvent(ClientUserEvent event) {
    _websocketRepo.trigger(event);
  }
}