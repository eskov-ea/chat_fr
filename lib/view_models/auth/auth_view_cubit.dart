import 'dart:async';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../../bloc/auth_bloc/auth_event.dart';
import '../../../../bloc/auth_bloc/auth_state.dart';
import 'auth_view_state.dart';


class AuthViewCubit extends Cubit<AuthViewCubitState> {
  final AuthBloc authBloc;
  late final StreamSubscription<AuthState> authBlocSubscription;

  AuthViewCubit({
    required AuthViewCubitState initialState,
    required this.authBloc,
  }) : super(initialState) {
    _onState(authBloc.state);
    authBlocSubscription = authBloc.stream.listen(_onState);
    authBloc.add(AuthCheckStatusEvent());
  }

  bool _isValid(String login, String password) =>
      login.isNotEmpty && password.isNotEmpty;

  void auth({required String email, required String password, required String platform, required String token}) {
    authBloc.add(AuthLoginEvent(email: email, password: password, token: token, platform: platform));
  }

  void logout(BuildContext context){
    print('logout event');
    authBloc.add(LogoutEvent());
    // Navigator.of(context).pushReplacementNamed(MainNavigationRouteNames.auth);
  }

  void _onState(AuthState state) {
    print("AUTHSTATE   $state");
    if (state is Unauthenticated) {
      emit(AuthViewCubitFormFillInProgressState());
    } else if (state is Authenticated) {
      // authBlocSubscription.cancel();
      emit(AuthViewCubitSuccessAuthState());
    } else if (state is AuthenticatingFailure) {
      final message = _mapErrorToMessage(state.error);
      emit(AuthViewCubitErrorState(message));
    } else if (state is Authenticating) {
      emit(AuthViewCubitAuthProgressState());
    } else if (state is AuthCheckStatusInProgressState) {
      emit(AuthViewCubitAuthProgressState());
    }
  }

  String _mapErrorToMessage(Object error) {
    if (error is !AppErrorException) {
      return 'Неизвестная ошибка, поторите попытку';
    }
    switch (error.type) {
      case AppErrorExceptionType.network:
        return 'Сервер не доступен. Проверте подключение к интернету';
      case AppErrorExceptionType.auth:
        return 'Неправильный логин или пароль!';
      case AppErrorExceptionType.access:
        return 'Недостаточно прав доступа!';
      case AppErrorExceptionType.sessionExpired:
        return 'Сессия устарела, обновите КЕШ';
      case AppErrorExceptionType.other:
        return 'Произошла ошибка. Попробуйте еще раз';
      case AppErrorExceptionType.parsing:
        return 'Произошла ошибка при обработке данных. Если повторится - свяжитесь с разработчиком';
      case AppErrorExceptionType.socket:
        return 'Произошла ошибка при получении данных по сети';
      case AppErrorExceptionType.render:
        return 'Произошла ошибка при создании виджета';
      case AppErrorExceptionType.getData:
        return 'Произошла ошибка при получении данных с сервера. Попробуйте еще раз';
      case AppErrorExceptionType.secureStorage:
        return 'Произошла ошибка при обращении к хранилищу данных. Попробуйте еще раз';
      case AppErrorExceptionType.requestError:
        return 'При отправке на сервер запрос не прошел валидацию - введены неверные данные';
    }
  }

  @override
  Future<void> close() {
    authBlocSubscription.cancel();
    return super.close();
  }
}