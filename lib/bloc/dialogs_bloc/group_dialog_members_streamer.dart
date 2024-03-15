import 'dart:async';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/models/dialog_model.dart';


/// This class opens up a stream that would notify listeners
/// if one user joins/exits dialog
class GroupDialogsMemberStateStreamer {

  GroupDialogsMemberStateStreamer._private();

  static final GroupDialogsMemberStateStreamer _instance = GroupDialogsMemberStateStreamer._private();
  static GroupDialogsMemberStateStreamer get instance => _instance;

  final _stateController = StreamController<ChatUserEvent>.broadcast();
  Stream<ChatUserEvent> get stream => _stateController.stream.asBroadcastStream();


  void _sink(ChatUserEvent state) => _stateController.sink.add(state);

  void add(ChatUserEvent event) {
    print('We add group dialog user event::  $event');
    _sink(event);
  }

}

class ChatUserEvent {
  final ChatUser chatUser;
  final String event;

  ChatUserEvent({required this.chatUser, required this.event});

  @override
  String toString() => "Instance of ChatUserEvent:  event: $event, user: $chatUser";
}