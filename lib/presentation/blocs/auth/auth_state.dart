import 'package:equatable/equatable.dart';
import '../../../domain/entities/app_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent(this.email);

  @override
  List<Object> get props => [email];
}

class AuthPasswordChanged extends AuthState {}

class AuthProfileUpdated extends AuthState {
  final AppUser user;

  const AuthProfileUpdated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthTokenRefreshed extends AuthState {
  final AppUser user;

  const AuthTokenRefreshed(this.user);

  @override
  List<Object> get props => [user];
}
