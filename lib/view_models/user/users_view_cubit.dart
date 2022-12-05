import 'dart:async';
import 'package:chat/bloc/user_bloc/user_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/user_bloc/user_bloc.dart';
import '../../../../bloc/user_bloc/user_state.dart';
import 'users_view_cubit_state.dart';

class UsersViewCubit extends Cubit<UsersViewCubitState> {
  final UsersBloc usersBloc;
  late final StreamSubscription<UsersState> usersBlocSubscription;

  UsersViewCubit({
    required this.usersBloc
  }) : super(UsersViewCubitLoadingState()) {
    Future.microtask(() {
      _onState(usersBloc.state);
      usersBlocSubscription = usersBloc.stream.listen(_onState);
    });
  }

  void _onState(UsersState state) {
    if (state is UsersLoadedState){
      final users = state.users;
      emit(UsersViewCubitLoadedState(users: users, searchQuery: ''));
    }
  }

  void searchContact(String text) async {
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