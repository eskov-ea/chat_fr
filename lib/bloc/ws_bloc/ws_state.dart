import 'package:chat/models/dialog_model.dart';
import '../../models/message_model.dart';


abstract class WsBlocState {
  const WsBlocState();

}

class Unconnected extends WsBlocState{

  @override
  bool operator ==(Object other) =>
      other is Unconnected &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class ConnectingState extends WsBlocState{

  @override
  bool operator ==(Object other) =>
      other is ConnectingState &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Connected extends WsBlocState{

  const Connected();
  @override
  bool operator ==(Object other) =>
      other is Connected &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class WsStateReceiveNewMessage extends WsBlocState {
  final MessageData message;

   const WsStateReceiveNewMessage({required this.message});

  @override
  bool operator ==(Object other) =>
      other is WsStateReceiveNewMessage &&
          runtimeType == other.runtimeType &&
          message.messageId == other.message.messageId &&
          message.status.last.statusId == other.message.status.last.statusId;

  @override
  int get hashCode =>
      message.messageId.hashCode ^
      message.status.last.statusId;
}

class WsStateUpdateStatus extends WsBlocState {
  final List<MessageStatuses> statuses;

  const WsStateUpdateStatus({required this.statuses});


}

class WsStateNewDialogCreated extends WsBlocState {
  final DialogData dialog;

  const WsStateNewDialogCreated({required this.dialog});
}

class WsStateDialogDeleted extends WsBlocState {
  final DialogData dialog;
  final String channelName;

  const WsStateDialogDeleted({required this.dialog, required this.channelName});
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

  @override
  bool operator ==(Object other) =>
      other is WsStateNewUserJoinDialog &&
          runtimeType == other.runtimeType &&
          user.userId == other.user.userId &&
          dialogId == other.dialogId;

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      user.userId.hashCode ^
      dialogId.hashCode;
}

class WsStateNewUserExitDialog extends WsBlocState {
  final ChatUser user;
  final int dialogId;

  const WsStateNewUserExitDialog({
    required this.user,
    required this.dialogId
  });

  @override
  bool operator ==(Object other) =>
      other is WsStateNewUserJoinDialog &&
          runtimeType == other.runtimeType &&
          user.userId == other.user.userId &&
          dialogId == other.dialogId;

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      user.userId.hashCode ^
      dialogId.hashCode;
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

  @override
  bool operator ==(Object other) =>
      other is WsStateOnlineUsersJoinState &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      userId.hashCode;
}

class WsStateOnlineUsersJoinState extends WsBlocState {
  final int userId;

  WsStateOnlineUsersJoinState({required this.userId});

  @override
  bool operator ==(Object other) =>
      other is WsStateOnlineUsersJoinState &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      userId.hashCode;
}

class WsOnlineUserTypingState extends WsBlocState{
  final ClientUserEvent clientEvent;
  final int dialogId;

  WsOnlineUserTypingState({
    required this.clientEvent,
    required this.dialogId
  });

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is WsOnlineUserTypingState &&
        runtimeType == other.runtimeType &&
        clientEvent.event == other.clientEvent.event &&
        dialogId == other.dialogId &&
        clientEvent.fromUser == other.clientEvent.fromUser &&
        clientEvent.toUser == other.clientEvent.toUser;

  @override
  int get hashCode =>
      clientEvent.hashCode ^ clientEvent.toUser.hashCode ^ clientEvent.fromUser.hashCode ^
        clientEvent.event.hashCode ^ dialogId.hashCode;
}
