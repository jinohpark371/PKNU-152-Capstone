part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserInfo userInfo;
  AuthAuthenticated({required this.userInfo});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}