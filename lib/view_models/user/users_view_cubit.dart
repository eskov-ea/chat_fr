import 'dart:async';
import 'package:chat/bloc/database_bloc/database_bloc.dart';
import 'package:chat/bloc/database_bloc/database_state.dart';
import 'package:chat/bloc/user_bloc/user_bloc.dart';
import 'package:chat/bloc/user_bloc/user_event.dart';
import 'package:chat/bloc/user_bloc/user_state.dart';
import 'package:chat/services/ws/ws_repositor_interface.dart';
import 'package:chat/services/ws/ws_repository.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'users_view_cubit_state.dart';

class UsersViewCubit extends Cubit<UsersViewCubitState> {
  final UsersBloc usersBloc;
  final DatabaseBloc databaseBloc;
  final WebsocketRepository wsRepo;
  late final StreamSubscription<UsersState> usersBlocSubscription;
  late final StreamSubscription<DatabaseBlocState> databaseEventSubscription;
  late final StreamSubscription<WebsocketEventPayload> websocketEventSubscription;

  UsersViewCubit({
    required this.usersBloc,
    required this.wsRepo,
    required this.databaseBloc,
  }) : super(UsersViewCubitLoadingState()) {
    Future.microtask(() {
      _onUserBlocState(usersBloc.state);
      usersBlocSubscription = usersBloc.stream.listen(_onUserBlocState);
      databaseEventSubscription = databaseBloc.stream.listen(_onDatabaseState);
    });
    websocketEventSubscription = wsRepo.events.asBroadcastStream().listen(_onWebsocketUserEvent);
  }

  void _onUserBlocState(UsersState state) {
    if (state is UsersLoadedState){
      if (!state.isAuthenticated) {
        emit(UsersViewCubitLogoutState());
      }
      emit(UsersViewCubitLoadedState(
          users: state.users,
          searchQuery: '',
          usersDictionary: state.usersMapped,
          onlineUsersDictionary: state.onlineUsersDictionary,
          clientEvent: state.clientEventsDictionary
      ));
    } else if (state is UsersErrorState) {
      emit(UsersViewCubitErrorState(errorType: state.errorType));
    }
  }

  void _onDatabaseState(DatabaseBlocState state) async {
    print("DatabaseState  ${state}");
    if (state is DatabaseBlocDBInitializedState) {
      final userId = await DataProvider.storage.getUserId();
      final users = state.users;
      users.removeWhere((key, value) => key == userId);
      usersBloc.add(UsersLoadedEvent(users: users));
    }
  }

  void _onWebsocketUserEvent(WebsocketEventPayload payload) {
    if (payload.event == WebsocketEvent.onlineUsers) {
      final online = <int, bool>{};
      for (var id in payload.data?["online_users"]) {
        online.addAll({id: true});
      }
      usersBloc.add(UsersUpdateOnlineStatusEvent(
        onlineUsersDictionary: online,
        joinedUser: null,
        exitedUser: null,
        clientEvent: null
      ));
    } else if (payload.event == WebsocketEvent.online) {
      usersBloc.add(UsersUpdateOnlineStatusEvent(
          onlineUsersDictionary: null,
          joinedUser: payload.data?["online"],
          exitedUser: null,
          clientEvent: null
      ));
    } else if (payload.event == WebsocketEvent.offline) {
      usersBloc.add(UsersUpdateOnlineStatusEvent(
          onlineUsersDictionary: null,
          joinedUser: null,
          exitedUser: payload.data?["online"],
          clientEvent: null
      ));
    } else if (payload.event == WebsocketEvent.userEvent) {
      usersBloc.add(UsersUpdateOnlineStatusEvent(
          onlineUsersDictionary: null,
          joinedUser: null,
          exitedUser: null,
          clientEvent: payload.data?["user_event"]
      ));
    }
  }

  void refresh() {
    emit(UsersViewCubitLoadingState());
    usersBloc.add(UsersLoadEvent());
  }

  void searchContact(String text) {
    usersBloc.add(UsersSearchEvent(searchQuery: text.trim()));
  }

  void resetSearchQuery() {
    usersBloc.add(UsersSearchEvent(searchQuery: ''));
  }

  @override
  Future<void> close() {
    usersBlocSubscription.cancel();
    return super.close();
  }

}