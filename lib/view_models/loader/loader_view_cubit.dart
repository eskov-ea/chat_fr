import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../../bloc/auth_bloc/auth_event.dart';
import '../../../../bloc/auth_bloc/auth_state.dart';


enum LoaderViewCubitState { unknown, authorized, notAuthorized }

class LoaderViewCubit extends Cubit<LoaderViewCubitState> {
  final AuthBloc authBloc;
  late final StreamSubscription<AuthState> authBlocSubscription;

  LoaderViewCubit({
    required LoaderViewCubitState initialState,
    required this.authBloc,
  }) : super(initialState) {
    Future.microtask(
          () {
        _onState(authBloc.state);
        authBlocSubscription = authBloc.stream.listen(_onState);
      },
    );
  }

  void _onState(AuthState state) {
    print('AuthState state    $state');
    if (state is Authenticated) {
      emit(LoaderViewCubitState.authorized);
    } else if (state is Unauthenticated) {
      print('notAuthorized');
      emit(LoaderViewCubitState.notAuthorized);
    }
  }

  start() {
    print('AUTHSTATE:::: step1 ${DateTime.now().millisecondsSinceEpoch}');
    authBloc.add(AuthCheckStatusEvent());
  }

  @override
  Future<void> close() {
    authBlocSubscription.cancel();
    return super.close();
  }
}