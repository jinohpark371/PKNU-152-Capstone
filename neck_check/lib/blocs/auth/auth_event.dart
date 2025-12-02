part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final int userId;
  AuthLoginRequested(this.userId);
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  AuthRegisterRequested(this.name);
}

class AuthLogoutRequested extends AuthEvent {}