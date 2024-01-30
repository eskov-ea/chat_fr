import 'package:equatable/equatable.dart';
import '../../models/dialog_model.dart';

abstract class UsersEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class UsersLoadEvent extends UsersEvent {}

class UsersDeleteUsersEvent extends UsersEvent{}

class UsersUpdateOnlineStatusEvent extends UsersEvent{
  final Map<int, bool>? onlineUsersDictionary;
  final int? joinedUser;
  final int? exitedUser;
  final ClientUserEvent? clientEvent;
  final int? dialogId;

  UsersUpdateOnlineStatusEvent({
    required this.onlineUsersDictionary,
    required this.joinedUser,
    required this.exitedUser,
    required this.clientEvent,
    required this.dialogId
  });
}

class UsersSearchEvent extends UsersEvent {
  final String searchQuery;

  UsersSearchEvent({required this.searchQuery});

  @override
  List<Object> get props => [searchQuery];
}
