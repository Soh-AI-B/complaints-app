import 'package:equatable/equatable.dart';
import '../../../domain/entities/app_user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;
  final String team;
  final String? phone;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    required this.team,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, name, role, team, phone];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final AppUser user;

  const AuthUserChanged(this.user);

  @override
  List<Object> get props => [user];
}

class AuthTokenRefreshRequested extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthPasswordChangeRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthPasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class AuthProfileUpdateRequested extends AuthEvent {
  final String? name;
  final String? phone;
  final String? team;

  const AuthProfileUpdateRequested({this.name, this.phone, this.team});

  @override
  List<Object?> get props => [name, phone, team];
}
