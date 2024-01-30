import 'dart:async';
import 'package:chat/bloc/user_bloc/user_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/user_bloc/user_bloc.dart';
import '../../../../bloc/user_bloc/user_state.dart';
import '../../bloc/ws_bloc/ws_bloc.dart';
import '../../bloc/ws_bloc/ws_state.dart';
import '../../models/contact_model.dart';
import '../../models/dialog_model.dart';
import 'users_view_cubit_state.dart';

class UsersViewCubit extends Cubit<UsersViewCubitState> {
  final UsersBloc usersBloc;
  late final StreamSubscription<UsersState> usersBlocSubscription;
  final WsBloc wsBloc;
  late final StreamSubscription<WsBlocState> wsBlocSubscription;

  UsersViewCubit({
    required this.usersBloc,
    required this.wsBloc
  }) : super(UsersViewCubitLoadingState()) {
    wsBlocSubscription = wsBloc.stream.listen(_onWsStateChange);
    Future.microtask(() {
      _onState(usersBloc.state);
      usersBlocSubscription = usersBloc.stream.listen(_onState);
    });
  }

  void _onState(UsersState state) {
    if (state is UsersLoadedState){
      //TODO: refactor
      if (state.isAuthenticated) {
        final users = state.users;
        final Map<String, UserContact> usersDictionary = {};
        users.forEach((user) {
          usersDictionary["${user.id}"] = user;
        });
        emit(UsersViewCubitLoadedState(
            users: users,
            searchQuery: '',
            usersDictionary: usersDictionary,
            onlineUsersDictionary: state.onlineUsersDictionary,
            clientEvent: state.clientEventsDictionary
        ));
      } else {
        emit(UsersViewCubitLogoutState());
      }
    } else if (state is UsersErrorState) {
      emit(UsersViewCubitErrorState(errorType: state.errorType));
    }
  }

  void _onWsStateChange(WsBlocState state) {
    print("WsBlocState  ${state}");
    if (state is WsStateOnlineUsersInitialState) {
      final Map<int, bool> onlineUsersDictionary = {};
      state.onlineUsers.forEach((id) {
        onlineUsersDictionary[id] = true;
      });
      usersBloc.add(UsersUpdateOnlineStatusEvent(
        onlineUsersDictionary: onlineUsersDictionary,
        joinedUser: null,
        exitedUser: null,
        clientEvent: null,
        dialogId: null
      ));
    } else if (state is WsStateOnlineUsersExitState) {
      usersBloc.add(UsersUpdateOnlineStatusEvent(
        onlineUsersDictionary: null,
        joinedUser: null,
        exitedUser: state.userId,
        clientEvent: null,
        dialogId: null
      ));
    } else if (state is WsStateOnlineUsersJoinState) {
      usersBloc.add(UsersUpdateOnlineStatusEvent(
        onlineUsersDictionary: null,
        joinedUser: state.userId,
        exitedUser: null,
        clientEvent: null,
        dialogId: null
      ));
    } else if (state is WsOnlineUserTypingState) {
      print("WsBlocState  ${state.clientEvent.event}");
      usersBloc.add(UsersUpdateOnlineStatusEvent(
        onlineUsersDictionary: null,
        joinedUser: null,
        exitedUser: null,
        clientEvent: state.clientEvent,
        dialogId: state.dialogId
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