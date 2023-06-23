import 'package:chat/models/contact_model.dart';
import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class UsersLoadEvent extends UsersEvent {}

class UsersDeleteEvent extends UsersEvent{}

class UsersUpdateOnlineStatusEvent extends UsersEvent{
  final Map<int, bool>? onlineUsersDictionary;
  final int? joinedUser;
  final int? exitedUser;

  UsersUpdateOnlineStatusEvent({
    required this.onlineUsersDictionary,
    required this.joinedUser,
    required this.exitedUser,
  });
}

class UsersSearchEvent extends UsersEvent {
  final String searchQuery;

  UsersSearchEvent({required this.searchQuery});

  @override
  List<Object> get props => [searchQuery];
}
