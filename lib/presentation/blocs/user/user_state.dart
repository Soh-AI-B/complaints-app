import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

// Initial state
class UserInitial extends UserState {
  const UserInitial();
}

// Loading state
class UserLoading extends UserState {
  const UserLoading();
}

// User profile loaded
class UserProfileLoaded extends UserState {
  final User user;

  const UserProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

// Users list loaded
class UsersLoaded extends UserState {
  final List<User> users;

  const UsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

// User profile updated
class UserProfileUpdated extends UserState {
  final User user;

  const UserProfileUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

// User activated
class UserActivated extends UserState {
  final String userEmail;

  const UserActivated({required this.userEmail});

  @override
  List<Object?> get props => [userEmail];
}

// User deactivated
class UserDeactivated extends UserState {
  final String userEmail;

  const UserDeactivated({required this.userEmail});

  @override
  List<Object?> get props => [userEmail];
}

// Users searched
class UsersSearched extends UserState {
  final List<User> users;
  final String query;

  const UsersSearched({required this.users, required this.query});

  @override
  List<Object?> get props => [users, query];
}

// Error state
class UserError extends UserState {
  final String message;
  final String? errorCode;

  const UserError({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

// All users loaded (for management)
class AllUsersLoaded extends UserState {
  final List<User> users;

  const AllUsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

// User role updated
class UserRoleUpdated extends UserState {
  final String userEmail;
  final String newRole;

  const UserRoleUpdated({required this.userEmail, required this.newRole});

  @override
  List<Object?> get props => [userEmail, newRole];
}

// User status updated
class UserStatusUpdated extends UserState {
  final String userEmail;
  final bool isActive;

  const UserStatusUpdated({required this.userEmail, required this.isActive});

  @override
  List<Object?> get props => [userEmail, isActive];
}

// User deleted
class UserDeleted extends UserState {
  final String userEmail;

  const UserDeleted({required this.userEmail});

  @override
  List<Object?> get props => [userEmail];
}
