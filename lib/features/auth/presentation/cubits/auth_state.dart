import 'package:life_line/features/auth/domain/entities/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSignUp extends AuthState {}

class AuthAuthenticated extends AuthState {
  final DoctorUser user;
  AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState {}

class AuthUserInfoUpdated extends AuthState {
  final DoctorUser user;
  AuthUserInfoUpdated(this.user);
}

class AuthResetPassword extends AuthState {
  final String message;
  AuthResetPassword(this.message);
}


class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}