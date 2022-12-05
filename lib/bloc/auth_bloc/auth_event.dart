import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String platform;
  final String token;

  AuthLoginEvent({required this.email, required this.password, required this.platform, required this.token});
}

class AuthCheckStatusEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class CheckAuthEvent extends AuthEvent {}
