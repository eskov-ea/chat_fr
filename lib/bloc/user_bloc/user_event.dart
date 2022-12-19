import 'package:chat/models/contact_model.dart';
import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class UsersLoadEvent extends UsersEvent {}

class UsersDeleteEvent extends UsersEvent{}

class UsersSearchEvent extends UsersEvent {
  final String searchQuery;

  UsersSearchEvent({required this.searchQuery});

  @override
  List<Object> get props => [searchQuery];
}
