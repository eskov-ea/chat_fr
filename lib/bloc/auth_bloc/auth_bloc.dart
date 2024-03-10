import 'dart:developer';
import 'dart:io';

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
    final _dataProvider = DataProvider.storage;

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
        await authRepo.logout();
        emit(Unauthenticated());
      } catch (err) {
        emit(Unauthenticated());
      }
    }

    Future<void> onAuthCheckStatusEvent (
      AuthCheckStatusEvent event,
      Emitter<AuthState> emit,
    ) async {
      print("onAuthCheckStatusEvent:::");
      try {
        final bool auth = await authRepo.checkAuthStatus();
        final newState =
            auth == true ? const Authenticated() : Unauthenticated();
        print('AUTHSTATE:::: step3 ${DateTime.now().millisecondsSinceEpoch}');
        emit(newState);
    } catch (err, stackTrace) {
        Logger.getInstance().sendErrorTrace(stackTrace: stackTrace, additionalInfo: stackTrace.toString(), uri: 'https://erp.mcfef.com/api/profile');
        emit(Unauthenticated());
      }
    }

}