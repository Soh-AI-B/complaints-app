import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

class User extends Equatable {
  final String userEmail;
  final String name;
  final String role;
  final String team;
  final String? phone;
  final DateTime createdAt;
  final bool isActive;
  final List<String>?
  managedCategories; // Categories this manager handles (null = all categories for backward compatibility)

  const User({
    required this.userEmail,
    required this.name,
    required this.role,
    required this.team,
    this.phone,
    required this.createdAt,
    required this.isActive,
    this.managedCategories,
  });

  // Copy with method for creating modified copies
  User copyWith({
    String? userEmail,
    String? name,
    String? role,
    String? team,
    String? phone,
    DateTime? createdAt,
    bool? isActive,
    List<String>? managedCategories,
  }) {
    return User(
      userEmail: userEmail ?? this.userEmail,
      name: name ?? this.name,
      role: role ?? this.role,
      team: team ?? this.team,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      managedCategories: managedCategories ?? this.managedCategories,
    );
  }

  // Check if user is an employee
  bool get isEmployee => role == 'Employee';

  // Check if user is a manager
  bool get isManager => role == 'Manager';

  // Check if user is an admin
  bool get isAdmin => role == 'Admin';

  // Check if user can manage other users (only admin)
  bool get canManageUsers => isAdmin;

  // Check if user can manage tasks (manager and admin)
  bool get canManageTasks => isManager || isAdmin;

  // Check if manager can handle a specific category (admins can handle all)
  bool canHandleCategory(String category) {
    if (isAdmin) return true; // Admins handle all categories
    if (!isManager) return false; // Non-managers can't handle tasks
    return managedCategories == null ||
        managedCategories!.contains(
          category,
        ); // null = handle all (backward compatibility)
  }

  // Get categories this manager handles (returns all categories if null)
  List<String> get effectiveManagedCategories {
    if (isAdmin || managedCategories == null) {
      return AppConstants.taskCategories; // All categories
    }
    return managedCategories!;
  }

  // Get user's initials for avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    } else {
      return parts.first.substring(0, 1).toUpperCase() +
          parts.last.substring(0, 1).toUpperCase();
    }
  }

  // Get display name (first name)
  String get firstName {
    final parts = name.trim().split(' ');
    return parts.first;
  }

  // Get last name
  String get lastName {
    final parts = name.trim().split(' ');
    return parts.length > 1 ? parts.last : '';
  }

  // Check if user has phone number
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  // Get formatted phone number
  String? get formattedPhone {
    if (!hasPhone) return null;

    // Basic phone formatting (can be enhanced based on locale)
    final cleaned = phone!.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    return phone;
  }

  // Get account age in days
  int get accountAgeInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  // Check if account is new (less than 30 days)
  bool get isNewAccount => accountAgeInDays < 30;

  @override
  List<Object?> get props => [
    userEmail,
    name,
    role,
    team,
    phone,
    createdAt,
    isActive,
    managedCategories,
  ];

  @override
  String toString() {
    return 'User{email: $userEmail, name: $name, role: $role, team: $team, isActive: $isActive, managedCategories: $managedCategories}';
  }
}
