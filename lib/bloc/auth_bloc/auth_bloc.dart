import 'package:chat/bloc/auth_bloc/auth_event.dart';
import 'package:chat/bloc/auth_bloc/auth_state.dart';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth/auth_repo.dart';
import '../../services/logger/logger_service.dart';
import '../../storage/data_storage.dart';


class AuthBloc
    extends Bloc<AuthEvent, AuthState> {
    final AuthRepository authRepo;
    final _dataProvider = DataProvider();
    final Logger _logger = Logger();

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
      } catch(err, stackTrace) {
        err as AppErrorException;
        _logger.sendErrorTrace(stackTrace: stackTrace, errorType: err.type.toString(), additionalInfo: err.message, uri: err.location);
        emit(AuthenticatingFailure(error: err));
      }
    }

    Future<void> onAuthLogoutEvent(
        LogoutEvent event,
        Emitter<AuthState> emit,
        ) async {
      try {
        await authRepo.logout();
        emit(Unauthenticated());
      } catch (err, stackTrace) {
        err as AppErrorException;
        _logger.sendErrorTrace(stackTrace: stackTrace, uri: err.location);
        emit(Unauthenticated());
      }
    }

    Future<void> onAuthCheckStatusEvent (
      AuthCheckStatusEvent event,
      Emitter<AuthState> emit,
    ) async {
      try {
        final String? token = await _dataProvider.getToken();
        final bool auth = await authRepo.checkAuthStatus(token);
        final newState =
        auth ? const Authenticated() : Unauthenticated();
        emit(newState);
      } catch (err, stackTrace) {
        err as AppErrorException;
        await _dataProvider.deleteToken();
        _logger.sendErrorTrace(stackTrace: stackTrace, additionalInfo: err.message, uri: err.location);
        emit(Unauthenticated());
      }
    }

}