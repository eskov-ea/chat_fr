import 'package:chat/bloc/auth_bloc/auth_event.dart';
import 'package:chat/bloc/auth_bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth/auth_repo.dart';
import '../../storage/data_storage.dart';


class AuthBloc
    extends Bloc<AuthEvent, AuthState> {
    final AuthRepository authRepo;
    final _dataProvider = DataProvider();

    AuthBloc({
       required this.authRepo
    }) : super(AuthCheckStatusInProgressState()){
      on<AuthEvent>((event, emit) async {
        if(event is AuthLoginEvent) {
          await onAuthLoginEvent(event, emit);
        } else if (event is AuthCheckStatusEvent) {
          await onAuthCheckStatusEvent(event, emit);
        } else if (event is LogoutEvent) {
          await onAuthLogoutEvent(event, emit);
        }
      });
    }

    Future<void> onAuthLoginEvent(event, emit) async {
      emit(Authenticating());
      try{
        await authRepo.login(event.email, event.password, event.platform, event.token);
        emit(const Authenticated());
      } catch(err) {
        emit(AuthenticatingFailure(error: err));
      }
    }

    Future<void> onAuthLogoutEvent(
        LogoutEvent event,
        Emitter<AuthState> emit,
        ) async {
      try {
        final String? token = await _dataProvider.getToken();
        await authRepo.logout();
        emit(Unauthenticated());
      } catch (err) {
        print(err);
        emit(Unauthenticated());
        // emit(AuthenticatingFailure(error: err));
      }
    }

    Future<void> onAuthCheckStatusEvent (
      AuthCheckStatusEvent event,
      Emitter<AuthState> emit,
    ) async {
      final String? token = await _dataProvider.getToken();
      print("AuthCheckStatusEvent  $token");
      final bool auth = await authRepo.checkAuthStatus(token);
      if (!auth) await _dataProvider.deleteToken();
      final newState =
      auth == true ? const Authenticated() : Unauthenticated();
      emit(newState);
    }

}