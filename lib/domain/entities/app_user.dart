import 'package:equatable/equatable.dart';
import 'user.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final String team;
  final String? phone;
  final bool isAuthenticated;
  final String? authToken;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? preferences;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.team,
    this.phone,
    required this.isAuthenticated,
    this.authToken,
    this.lastLoginAt,
    this.preferences,
  });

  // Create from User entity
  factory AppUser.fromUser(
    User user, {
    required String id,
    required bool isAuthenticated,
    String? authToken,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return AppUser(
      id: id,
      email: user.userEmail,
      name: user.name,
      role: user.role,
      team: user.team,
      phone: user.phone,
      isAuthenticated: isAuthenticated,
      authToken: authToken,
      lastLoginAt: lastLoginAt,
      preferences: preferences,
    );
  }

  // Convert to User entity
  User toUser() {
    return User(
      userEmail: email,
      name: name,
      role: role,
      team: team,
      phone: phone,
      createdAt: lastLoginAt ?? DateTime.now(),
      isActive: isAuthenticated,
    );
  }

  // Copy with method for creating modified copies
  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? team,
    String? phone,
    bool? isAuthenticated,
    String? authToken,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      team: team ?? this.team,
      phone: phone ?? this.phone,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      authToken: authToken ?? this.authToken,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
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

  // Check if user has team
  bool get hasTeam => team != null && team!.isNotEmpty;

  // Check if user has authentication token
  bool get hasAuthToken => authToken != null && authToken!.isNotEmpty;

  // Check if user session is valid (has token and is authenticated)
  bool get hasValidSession => isAuthenticated && hasAuthToken;

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

  // Get user preference by key
  T? getPreference<T>(String key) {
    if (preferences == null) return null;
    return preferences![key] as T?;
  }

  // Get user preference with default value
  T getPreferenceWithDefault<T>(String key, T defaultValue) {
    if (preferences == null) return defaultValue;
    return preferences![key] as T? ?? defaultValue;
  }

  // Update user preferences
  AppUser updatePreferences(Map<String, dynamic> newPreferences) {
    final updatedPreferences = Map<String, dynamic>.from(preferences ?? {});
    updatedPreferences.addAll(newPreferences);

    return copyWith(preferences: updatedPreferences);
  }

  // Set single preference
  AppUser setPreference(String key, dynamic value) {
    final updatedPreferences = Map<String, dynamic>.from(preferences ?? {});
    updatedPreferences[key] = value;

    return copyWith(preferences: updatedPreferences);
  }

  // Remove preference
  AppUser removePreference(String key) {
    if (preferences == null) return this;

    final updatedPreferences = Map<String, dynamic>.from(preferences!);
    updatedPreferences.remove(key);

    return copyWith(preferences: updatedPreferences);
  }

  // Update authentication status
  AppUser authenticate({required String authToken, DateTime? lastLoginAt}) {
    return copyWith(
      isAuthenticated: true,
      authToken: authToken,
      lastLoginAt: lastLoginAt ?? DateTime.now(),
    );
  }

  // Logout user
  AppUser logout() {
    return copyWith(isAuthenticated: false, authToken: null);
  }

  // Create empty/unauthenticated user
  static const AppUser empty = AppUser(
    id: '',
    email: '',
    name: '',
    role: '',
    team: '',
    isAuthenticated: false,
  );

  // Check if user is empty
  bool get isEmpty => this == AppUser.empty;

  // Check if user is not empty
  bool get isNotEmpty => this != AppUser.empty;

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    team,
    phone,
    isAuthenticated,
    authToken,
    lastLoginAt,
    preferences,
  ];

  @override
  String toString() {
    return 'AppUser{id: $id, email: $email, name: $name, role: $role, team: $team, isAuthenticated: $isAuthenticated}';
  }
}
