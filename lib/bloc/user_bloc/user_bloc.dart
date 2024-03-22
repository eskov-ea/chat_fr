import 'package:chat/bloc/error_handler_bloc/error_handler_bloc.dart';
import 'package:chat/bloc/error_handler_bloc/error_handler_events.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/bloc/user_bloc/user_event.dart';
import 'package:chat/bloc/user_bloc/user_state.dart';
import 'package:chat/bloc/user_bloc/users_list_container.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/services/logger/logger_service.dart';
import 'package:chat/services/users/users_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository usersRepository;
  final ErrorHandlerBloc errorHandlerBloc;
  final _logger = Logger.getInstance();
  final _methodChannel = const MethodChannel("com.application.chat/permission_method_channel");

  UsersBloc({
    required this.usersRepository,
    required this.errorHandlerBloc
  }) :  super(UsersState()) {

    on<UsersLoadedEvent>(onUsersLoadedEvent);
    on<UsersSearchEvent>(onUsersSearchEvent);
    on<UsersDeleteUsersEvent>(onUsersDeleteEvent);
    on<UsersUpdateOnlineStatusEvent>(onUsersUpdateOnlineStatusEvent);
  }


  void onUsersLoadedEvent (
      UsersLoadedEvent event, Emitter<UsersState> emit
      ) async {
    try {
      final users = event.users;
      final usersMap = usersRepository.prepareSipContactsList(users);
      if (!kIsWeb) {
        _methodChannel
            .invokeMethod("SAVE_SIP_CONTACTS", {"data": usersMap.toString()});
      }
      final usersList = users.entries.map((user) => user.value).toList();
      // usersList.sort((a, b) => a.lastname.compareTo(b.lastname));
      if (state.isSearchMode) {
        final query = state.searchQuery.toLowerCase();
        final container = state.searchUsersContainer;
        final filteredUsers = filterUsersBySearchQuery(usersList, query);
        final newContainer = container.copyWith(users: filteredUsers);
        emit(UsersLoadedState(
            usersContainer: state.usersContainer,
            searchQuery: query,
            searchUsersContainer: newContainer,
            usersMapped: users,
            onlineUsersDictionary: state.onlineUsersDictionary,
            clientEventsDictionary: state.clientEventsDictionary,
            isAuthenticated: true
        ));
      } else {
        final container = state.usersContainer;
        final newContainer = container.copyWith(users: usersList);
        emit(UsersLoadedState(
            usersContainer: newContainer,
            searchQuery: '',
            usersMapped: users,
            searchUsersContainer: state.searchUsersContainer,
            onlineUsersDictionary: state.onlineUsersDictionary,
            clientEventsDictionary: state.clientEventsDictionary,
            isAuthenticated: true
        ));
      }
    } catch (err, stackTrace) {
      _logger.sendErrorTrace(stackTrace: stackTrace);
      err as AppErrorException;
      if(err.type == AppErrorExceptionType.auth) {
        errorHandlerBloc.add(ErrorHandlerAccessDeniedEvent(error: err));
      } else {
        emit(UsersErrorState(errorType: err.type));
      }
    }
  }

  void onUsersSearchEvent(
    UsersSearchEvent event, Emitter<UsersState> emit
    ) async {
      if (event.searchQuery != "") {
        final query = event.searchQuery.toLowerCase();
        final filteredUsers = filterUsersBySearchQuery(state.usersContainer.users, query);
        final newContainer = UsersListContainer(users: filteredUsers);
        emit(UsersLoadedState(
            usersContainer: state.usersContainer,
            searchQuery: query,
            usersMapped: state.usersMapped,
            searchUsersContainer: newContainer,
            onlineUsersDictionary: state.onlineUsersDictionary,
            clientEventsDictionary: state.clientEventsDictionary,
            isAuthenticated: true
        ));
      } else {
        final container = state.usersContainer;
        final newContainer = container.copyWith(users: container.users);
        emit(UsersLoadedState(
            usersContainer: newContainer,
            searchQuery: '',
            usersMapped: state.usersMapped,
            searchUsersContainer: state.searchUsersContainer,
            onlineUsersDictionary: state.onlineUsersDictionary,
            clientEventsDictionary: state.clientEventsDictionary,
            isAuthenticated: true
        ));
      }
  }

  void onUsersDeleteEvent(
      UsersDeleteUsersEvent event, emit
  ) {
    final newState = UsersLoadedState(
        usersContainer: const UsersListContainer.initial(),
        searchUsersContainer: const UsersListContainer.initial(),
        searchQuery: "",
        usersMapped: {},
        onlineUsersDictionary: {},
        isAuthenticated: false,
        clientEventsDictionary: {}
    );
    emit(newState);
  }

  void onUsersUpdateOnlineStatusEvent(
      UsersUpdateOnlineStatusEvent event, emit
  ) {
    if (state is UsersLoadedState) {
      try {
        final st = state as UsersLoadedState;
        UsersLoadedState newState;
        if (event.onlineUsersDictionary != null) {
          newState = st.copyWith(
              usersContainer: st.usersContainer,
              searchUsersContainer: st.searchUsersContainer,
              searchQuery: st.searchQuery,
              onlineUsersDictionary: event.onlineUsersDictionary,
              clientEvent: st.clientEventsDictionary);
          emit(newState);
        } else if (event.exitedUser != null) {
          final int id = event.exitedUser!;
          st.onlineUsersDictionary.remove(id);
          newState = st.copyWith(
              usersContainer: st.usersContainer,
              searchUsersContainer: st.searchUsersContainer,
              searchQuery: st.searchQuery,
              onlineUsersDictionary: st.onlineUsersDictionary,
              clientEvent: st.clientEventsDictionary);
          emit(newState);
        } else if (event.joinedUser != null) {
          final int id = event.joinedUser!;
          st.onlineUsersDictionary[id] = true;
          newState = st.copyWith(
              usersContainer: st.usersContainer,
              searchUsersContainer: st.searchUsersContainer,
              searchQuery: st.searchQuery,
              onlineUsersDictionary: st.onlineUsersDictionary,
              clientEvent: st.clientEventsDictionary);
          emit(newState);
        } else if (event.clientEvent != null && event.clientEvent?.dialogId != null) {
          Map<int, ClientUserEvent> newClientEventDictionary =
              st.clientEventsDictionary;
          print(
              "onUsersUpdateOnlineStatusEvent     state is   ${newClientEventDictionary.length} ${newClientEventDictionary[193]?.event}  ${event.clientEvent?.event}");
          if (event.clientEvent?.event == "typing") {
            newClientEventDictionary[event.clientEvent!.dialogId] = event.clientEvent!;
          }
          if (event.clientEvent?.event == "finish_typing") {
            newClientEventDictionary.remove(event.clientEvent!.dialogId!);
          }
          newState = st.copyWith(
              usersContainer: st.usersContainer,
              searchUsersContainer: st.searchUsersContainer,
              searchQuery: st.searchQuery,
              onlineUsersDictionary: st.onlineUsersDictionary,
              clientEvent: newClientEventDictionary);
          emit(newState);
        }
      } catch (err, stackTrace) {
        _logger.sendErrorTrace(stackTrace: stackTrace);
        err as AppErrorException;
        emit(UsersErrorState(errorType: err.type));
      }
    } else {
      add(UsersLoadEvent());
    }
  }


  List<UserModel> filterUsersBySearchQuery(List<UserModel> users, query) {

    final List<UserModel> filteredUsers = [];
    for (var user in users) {
      if (user.firstname.toLowerCase().contains(query) || user.lastname.toLowerCase().contains(query)) {
        filteredUsers.add(user);
      }
    }
    return filteredUsers;
  }


  }