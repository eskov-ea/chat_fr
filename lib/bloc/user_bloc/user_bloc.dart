import 'dart:async';
import 'package:chat/bloc/user_bloc/user_event.dart';
import 'package:chat/bloc/user_bloc/user_state.dart';
import 'package:chat/bloc/user_bloc/users_list_container.dart';
import 'package:chat/services/logger/logger_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/contact_model.dart';
import '../../services/users/users_repository.dart';
import '../../storage/data_storage.dart';
import '../ws_bloc/ws_bloc.dart';


class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository usersRepository;
  late final StreamSubscription usersSubscription;
  final WsBloc webSocketBloc;
  final _secureStorage = DataProvider();
  final _logger = Logger.getInstance();

  final _methodChannel = const MethodChannel("com.application.chat/write_files_method");
  final _eventChannel = const EventChannel("event.channel/write_files_service");

  UsersBloc({
    required this.usersRepository,
    required this.webSocketBloc,
  }) :  super(UsersState()) {
    usersSubscription = webSocketBloc.stream.listen((streamState) {

    });
    on<UsersLoadEvent>(onUsersLoadEvent);
    on<UsersSearchEvent>(onUsersSearchEvent);
    on<UsersDeleteEvent>(onUsersDeleteEvent);
  }

  void onUsersLoadEvent (
      UsersLoadEvent event, Emitter<UsersState> emit
      ) async {
    try {
      final String? token = await _secureStorage.getToken();
      List<UserContact> users = await usersRepository.getAllUsers(token);
      final usersMap = usersRepository.getSipContacts(users);
      _methodChannel.invokeMethod("SAVE_SIP_CONTACTS", {
        "data" : usersMap
      });
      users.sort((a, b) => a.lastname.compareTo(b.lastname));
      print("STATE:   $state  ${state.searchQuery}");
      if (state.isSearchMode) {
        print('state.isSearchMode');
        final query = state.searchQuery.toLowerCase();
        final container = state.searchUsersContainer;
        final filteredUsers = filterUsersBySearchQuery(users, query);
        final newContainer = container.copyWith(users: filteredUsers);
        emit(UsersLoadedState(usersContainer: state.usersContainer, searchQuery: query, searchUsersContainer: newContainer));
      } else {
        print('not state.isSearchMode');
        final container = state.usersContainer;
        final newContainer = container.copyWith(users: users);
        emit(UsersLoadedState(usersContainer: newContainer, searchQuery: '', searchUsersContainer: state.searchUsersContainer));
      }
    } catch (err) {
      print("ERROR: onUsersLoadEvent ${err}");
      _logger.sendErrorTrace(message: "UsersBloc.onUsersLoadEvent", err: err.toString());
      emit(UsersErrorState());
    }
  }

  void onUsersSearchEvent(
    UsersSearchEvent event, Emitter<UsersState> emit
    ) async {
      if (event.searchQuery != "") {
        final query = event.searchQuery.toLowerCase();
        final container = state.usersContainer;
        final filteredUsers = filterUsersBySearchQuery(state.users, query);
        final newContainer = container.copyWith(users: filteredUsers);
        print("SEARCHWIGET   ${container.users}");
        emit(UsersLoadedState(usersContainer: container, searchQuery: query, searchUsersContainer: newContainer));
      } else {
        final container = state.usersContainer;
        final newContainer = container.copyWith(users: container.users);
        emit(UsersLoadedState(usersContainer: newContainer, searchQuery: '', searchUsersContainer: state.searchUsersContainer));
      }
  }

  void onUsersDeleteEvent(
      UsersDeleteEvent event, emit
      ) {
   emit(UsersState());
  }


  List<UserContact> filterUsersBySearchQuery(List<UserContact> users, query) {
    final List<UserContact> filteredUsers = [];
    for (var user in users) {
      if (user.firstname.toLowerCase().contains(query) || user.lastname.toLowerCase().contains(query)) {
        filteredUsers.add(user);
      }
    }
    return filteredUsers;
  }


  }