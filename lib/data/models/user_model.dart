import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.userEmail,
    required super.name,
    required super.role,
    required super.team,
    super.phone,
    required super.createdAt,
    required super.isActive,
    super.managedCategories,
  });

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userEmail: json['user_email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      team: json['team'] as String,
      phone: json['phone'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      isActive: json['is_active'] as bool,
      managedCategories: json['managed_categories'] != null
          ? List<String>.from(json['managed_categories'] as List)
          : null,
    );
  }

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle createdAt field safely
    DateTime createdAt;
    try {
      if (data['created_at'] != null) {
        if (data['created_at'] is Timestamp) {
          createdAt = (data['created_at'] as Timestamp).toDate();
        } else if (data['created_at'] is String) {
          createdAt = DateTime.parse(data['created_at'] as String);
        } else {
          createdAt = DateTime.now(); // Fallback
        }
      } else {
        createdAt = DateTime.now(); // Fallback for missing field
      }
    } catch (e) {
      createdAt = DateTime.now(); // Fallback for any parsing error
    }

    return UserModel(
      userEmail:
          data['userEmail'] as String? ?? doc.id, // Use doc.id as fallback
      name: data['name'] as String,
      role: data['role'] as String,
      team: data['team'] as String,
      phone: data['phone'] as String?,
      createdAt: createdAt,
      isActive: data['is_active'] as bool? ?? true,
      managedCategories: data['managed_categories'] != null
          ? List<String>.from(data['managed_categories'] as List)
          : null,
    );
  }

  // Create from Firestore data map
  factory UserModel.fromFirestoreData(Map<String, dynamic> data) {
    return UserModel(
      userEmail: data['user_email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'Employee',
      team: data['team'] ?? '',
      phone: data['phone'],
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: data['is_active'] ?? true,
      managedCategories: data['managed_categories'] != null
          ? List<String>.from(data['managed_categories'] as List)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_email': userEmail,
      'name': name,
      'role': role,
      'team': team,
      'phone': phone,
      'created_at': _dateTimeToString(createdAt),
      'is_active': isActive,
      if (managedCategories != null) 'managed_categories': managedCategories,
    };
  }

  // Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'userEmail': userEmail, // Include userEmail in Firestore data
      'name': name,
      'role': role,
      'team': team,
      'phone': phone,
      'created_at': Timestamp.fromDate(createdAt),
      'is_active': isActive,
      if (managedCategories != null) 'managed_categories': managedCategories,
      // NOTE: fcmTokens field is deliberately NOT included here to avoid overwriting
      // FCM tokens that are managed separately by FCMService
    };
  }

  // Convert to Firestore data for safe merging (preserves existing fields like fcmTokens)
  Map<String, dynamic> toFirestoreForUpdate() {
    return {
      'userEmail': userEmail,
      'name': name,
      'role': role,
      'team': team,
      'phone': phone,
      'updated_at': FieldValue.serverTimestamp(),
      'is_active': isActive,
      if (managedCategories != null) 'managed_categories': managedCategories,
      // fcmTokens is intentionally excluded to preserve existing tokens
    };
  }

  // Convert to User entity
  User toEntity() {
    return User(
      userEmail: userEmail,
      name: name,
      role: role,
      team: team,
      phone: phone,
      createdAt: createdAt,
      isActive: isActive,
      managedCategories: managedCategories,
    );
  }

  // Create from User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      userEmail: user.userEmail,
      name: user.name,
      role: user.role,
      team: user.team,
      phone: user.phone,
      createdAt: user.createdAt,
      isActive: user.isActive,
      managedCategories: user.managedCategories,
    );
  }

  // Copy with method
  @override
  UserModel copyWith({
    String? userEmail,
    String? name,
    String? role,
    String? team,
    String? phone,
    DateTime? createdAt,
    bool? isActive,
    List<String>? managedCategories,
  }) {
    return UserModel(
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

  // Helper methods for date parsing
  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else {
      throw ArgumentError('Invalid date format: $value');
    }
  }

  static String _dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  @override
  String toString() {
    return 'UserModel{email: $userEmail, name: $name, role: $role, team: $team, isActive: $isActive, managedCategories: $managedCategories}';
  }
}
