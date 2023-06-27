import '../../../../models/contact_model.dart';
import '../../models/dialog_model.dart';

abstract class UsersViewCubitState {
  final List<UserContact> users = [];
  final Map<String, UserContact> usersDictionary = {};
  final Map<int, bool> onlineUsersDictionary = {};
  final Map<int, ClientUserEvent> clientEvent = {};

}

class UsersViewCubitLoadedState extends UsersViewCubitState {
  final List<UserContact> users;
  final String searchQuery;
  final Map<String, UserContact> usersDictionary;
  final Map<int, bool> onlineUsersDictionary;
  final Map<int, ClientUserEvent> clientEvent;

  UsersViewCubitLoadedState({
    required this.users,
    required this.searchQuery,
    required this.usersDictionary,
    required this.onlineUsersDictionary,
    required this.clientEvent
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UsersViewCubitLoadedState &&
              runtimeType == other.runtimeType &&
              users == other.users &&
              searchQuery == other.searchQuery &&
              clientEvent == other.clientEvent &&
              clientEvent.hashCode == other.clientEvent.hashCode &&
              clientEvent.length == other.clientEvent.length &&
              usersDictionary == other.usersDictionary;

  @override
  int get hashCode => users.hashCode ^ searchQuery.hashCode ^ clientEvent.hashCode ^ clientEvent.length.hashCode ^ usersDictionary.hashCode;

  UsersViewCubitLoadedState copyWith({
    List<UserContact>? users,
    String? searchQuery,
    Map<String, UserContact>? usersDictionary,
    Map<int, bool>? onlineUsersDictionary,
    Map<int, ClientUserEvent>? clientEvent
  }) {
    return UsersViewCubitLoadedState(
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      usersDictionary: usersDictionary ?? this.usersDictionary,
      onlineUsersDictionary: onlineUsersDictionary ?? this.onlineUsersDictionary,
      clientEvent: clientEvent ?? this.clientEvent
    );
  }
}

class UsersViewCubitLoadingState extends UsersViewCubitState{}

class UsersViewCubitErrorState extends UsersViewCubitState{}