import 'package:chat/models/contact_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:equatable/equatable.dart';
import '../../models/message_model.dart';


abstract class WsBlocState extends Equatable {
  const WsBlocState();

  @override
  List<Object> get props => [];
}

class Unconnected extends WsBlocState{}

class ConnectingState extends WsBlocState{}

class Connected extends WsBlocState{
  final PusherChannelsClient socket;

  const Connected({required this.socket});

  @override
  List<PusherChannelsClient> get props => [socket];
}
class WsStateReceiveNewMessage extends WsBlocState {
  final MessageData message;

   const WsStateReceiveNewMessage({required this.message});

  @override
  List<MessageData> get props => [message];
}

class WsStateUpdateStatus extends WsBlocState {
  final List<MessageStatuses> statuses;

  const WsStateUpdateStatus({required this.statuses});

  @override
  List<Object> get props => [statuses];
}

class WsStateNewDialogCreated extends WsBlocState {
  final DialogData dialog;

  const WsStateNewDialogCreated({required this.dialog});
}

/**
 * User Exit/Join dialog related states */

class WsStateNewUserJoinDialog extends WsBlocState {
  final ChatUser user;
  final int dialogId;

  const WsStateNewUserJoinDialog({
    required this.user,
    required this.dialogId
  });
}

class WsStateNewUserExitDialog extends WsBlocState {
  final ChatUser user;
  final int dialogId;

  const WsStateNewUserExitDialog({
    required this.user,
    required this.dialogId
  });
}


/**
 * Online users related states */

class WsStateOnlineUsersInitialState extends WsBlocState {
  final List onlineUsers;

  WsStateOnlineUsersInitialState({required this.onlineUsers});
}

class WsStateOnlineUsersExitState extends WsBlocState {
  final int userId;

  WsStateOnlineUsersExitState({required this.userId});
}

class WsStateOnlineUsersJoinState extends WsBlocState {
  final int userId;

  WsStateOnlineUsersJoinState({required this.userId});
}
