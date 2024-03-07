// import 'package:dart_pusher_channels/dart_pusher_channels.dart';
// import 'package:equatable/equatable.dart';
// import '../../models/dialog_model.dart';
// import '../../models/message_model.dart';
//
// abstract class WsBlocEvent extends Equatable {
//   @override
//   List<Object> get props => [];
// }
//
// class InitializeSocketEvent extends WsBlocEvent{}
//
// class WsEventUpdateStatus extends WsBlocEvent{
//   final List<MessageStatus> statuses;
//
//   WsEventUpdateStatus({required this.statuses});
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//           other is WsEventUpdateStatus &&
//               runtimeType == other.runtimeType &&
//               statuses.last.id == other.statuses.last.id;
//
//   @override
//   int get hashCode =>
//       statuses.hashCode ^ statuses.last.id.hashCode ;
// }
//
//
//
// class WsUserJoinChatEvent extends WsBlocEvent{
//   final ChatUser user;
//   final int dialogId;
//
//   WsUserJoinChatEvent({
//     required this.user,
//     required this.dialogId
//   });
// }
//
// class WsUserExitChatEvent extends WsBlocEvent{
//   final ChatUser user;
//   final int dialogId;
//
//   WsUserExitChatEvent({
//     required this.user,
//     required this.dialogId
//   });
// }
//
// class ConnectingSocketEvent extends WsBlocEvent{
//   final PusherChannelsClient socket;
//
//   ConnectingSocketEvent({required this.socket});
// }
//
// class WsEventReceiveNewMessage extends WsBlocEvent{
//   final MessageData message;
//
//   WsEventReceiveNewMessage({required this.message});
// }
//
// class WsEventNewDialogCreated extends WsBlocEvent {
//   final DialogData dialog;
//
//   WsEventNewDialogCreated({required this.dialog});
// }
//
// class WsEventDialogDeleted extends WsBlocEvent {
//   final DialogData dialog;
//   final String channelName;
//
//   WsEventDialogDeleted({required this.dialog, required this.channelName});
// }
//
// class WsOnlineUsersInitialEvent extends WsBlocEvent{
//   final List onlineUsers;
//
//   WsOnlineUsersInitialEvent({required this.onlineUsers});
// }
//
// class WsOnlineUsersJoinEvent extends WsBlocEvent{
//   final int userId;
//
//   WsOnlineUsersJoinEvent({required this.userId});
// }
//
// class WsOnlineUsersExitEvent extends WsBlocEvent{
//   final int userId;
//
//   WsOnlineUsersExitEvent({required this.userId});
// }
//
// class WsOnlineUserTypingEvent extends WsBlocEvent{
//   final ClientUserEvent clientEvent;
//   final int dialogId;
//
//   WsOnlineUserTypingEvent({
//     required this.clientEvent,
//     required this.dialogId
//   });
// }
//
// class WsEventDisconnect extends WsBlocEvent{}
//
// class WsEventCloseConnection extends WsBlocEvent{}
//
// class WsEventReconnect extends WsBlocEvent{}
//
// class WsEventGetUpdatesOnResume extends WsBlocEvent{}
//
