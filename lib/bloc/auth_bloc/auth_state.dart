abstract class AuthState  {
  const AuthState();


  String get props => '';
}

class Unauthenticated extends AuthState{}

class Authenticating extends AuthState{}

class AuthCheckStatusInProgressState extends AuthState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AuthCheckStatusInProgressState &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class AuthCheckStatusFillFormInProgressState extends AuthState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AuthCheckStatusFillFormInProgressState &&
              runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class AuthenticatingFailure extends AuthState{
  final Object error;

  AuthenticatingFailure({required this.error});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AuthenticatingFailure &&
              runtimeType == other.runtimeType &&
              error == other.error;

  @override
  int get hashCode => error.hashCode;
}

class Authenticated extends AuthState{
  final String userToken;

  const Authenticated({this.userToken = ''});

  @override
  String get props => userToken;
}