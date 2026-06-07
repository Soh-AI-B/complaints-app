import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

// Load user profile
class LoadUserProfile extends UserEvent {
  final String userEmail;

  const LoadUserProfile({required this.userEmail});

  @override
  List<Object?> get props => [userEmail];
}

// Update user profile
class UpdateUserProfile extends UserEvent {
  final String userEmail;
  final String? name;
  final String? phone;
  final String? team;
  final bool? notificationEnabled;
  final bool? taskReminderNotificationsEnabled;
  final bool? newTaskNotificationsEnabled;
  final List<String>? notificationTimes;

  const UpdateUserProfile({
    required this.userEmail,
    this.name,
    this.phone,
    this.team,
    this.notificationEnabled,
    this.taskReminderNotificationsEnabled,
    this.newTaskNotificationsEnabled,
    this.notificationTimes,
  });

  @override
  List<Object?> get props => [
    userEmail,
    name,
    phone,
    team,
    notificationEnabled,
    taskReminderNotificationsEnabled,
    newTaskNotificationsEnabled,
    notificationTimes,
  ];
}

// Load all users (for managers)
class LoadAllUsers extends UserEvent {
  const LoadAllUsers();
}

// Load users by role
class LoadUsersByRole extends UserEvent {
  final String role;

  const LoadUsersByRole({required this.role});

  @override
  List<Object?> get props => [role];
}

// Load users by team
class LoadUsersByTeam extends UserEvent {
  final String team;

  const LoadUsersByTeam({required this.team});

  @override
  List<Object?> get props => [team];
}

// Search users
class SearchUsers extends UserEvent {
  final String query;

  const SearchUsers({required this.query});

  @override
  List<Object?> get props => [query];
}

// Activate user
class ActivateUser extends UserEvent {
  final String userEmail;

  const ActivateUser({required this.userEmail});

  @override
  List<Object?> get props => [userEmail];
}

// Deactivate user
class DeactivateUser extends UserEvent {
  final String userEmail;

  const DeactivateUser({required this.userEmail});

  @override
  List<Object?> get props => [userEmail];
}

// Update user role (for managers)
class UpdateUserRole extends UserEvent {
  final String userEmail;
  final String newRole;
  final List<String>? managedCategories; // New field for manager categories

  const UpdateUserRole({
    required this.userEmail,
    required this.newRole,
    this.managedCategories,
  });

  @override
  List<Object?> get props => [userEmail, newRole, managedCategories];
}

// Update user status (active/inactive)
class UpdateUserStatus extends UserEvent {
  final String userEmail;
  final bool isActive;

  const UpdateUserStatus({required this.userEmail, required this.isActive});

  @override
  List<Object?> get props => [userEmail, isActive];
}

// Delete user (for managers)
class DeleteUser extends UserEvent {
  final String userEmail;

  const DeleteUser({required this.userEmail});

  @override
  List<Object?> get props => [userEmail];
}
