import 'dart:async';
import 'package:chat/bloc/user_bloc/user_event.dart';
import 'package:chat/bloc/user_bloc/user_state.dart';
import 'package:chat/bloc/user_bloc/users_list_container.dart';
import 'package:chat/models/user_profile_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/contact_model.dart';
import '../../services/users/users_repository.dart';
import '../../storage/data_storage.dart';
import '../ws_bloc/ws_bloc.dart';


class UsersBloc extends Bloc<UsersEvent, UsersLoadedState> {
  final UsersRepository usersRepository;
  late final StreamSubscription usersSubscription;
  final WsBloc webSocketBloc;
  final _secureStorage = DataProvider();


  UsersBloc({
    required this.usersRepository,
    required this.webSocketBloc,
  }) :  super(const UsersLoadedState.initial()) {
    usersSubscription = webSocketBloc.stream.listen((streamState) {

    });
    on<UsersLoadEvent>(onUsersLoadEvent);
    on<UsersSearchEvent>(onUsersSearchEvent);
  }

  void onUsersLoadEvent (
      UsersLoadEvent event, Emitter<UsersLoadedState> emit
      ) async {
    final String? token = await _secureStorage.getToken();
    List<UserContact> users = await usersRepository.getAllUsers(token);
    print(users);
    if (state.isSearchMode) {
      print('state.isSearchMode');
      final query = state.searchQuery.toLowerCase();
      final container = state.searchUsersContainer;
      final filteredUsers = filterUsersBySearchQuery(users, query);
      final newContainer = container.copyWith(users: filteredUsers);
      emit(UsersLoadedState(usersContainer: state.usersContainer, searchQuery: query, searchUsersContainer: newContainer));
    } else {
    final container = state.usersContainer;
    final newContainer = container.copyWith(users: users);
    emit(UsersLoadedState(usersContainer: newContainer, searchQuery: '', searchUsersContainer: state.searchUsersContainer));
    }
  }

  void onUsersSearchEvent(
      UsersSearchEvent event, Emitter<UsersLoadedState> emit
      ) async {
    if (state.searchQuery == event.searchQuery) return;
    final newState = state.copyWith(
      searchQuery: event.searchQuery,
      searchUsersContainer: const UsersListContainer.initial()
    );
    emit(newState);
    add(UsersLoadEvent());
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