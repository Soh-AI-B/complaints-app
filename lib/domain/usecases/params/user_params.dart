import 'package:equatable/equatable.dart';

// Base class for user parameters
abstract class UserParams extends Equatable {
  const UserParams();
}

// Parameters for getting user profile
class GetUserProfileParams extends UserParams {
  final String userId;

  const GetUserProfileParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Parameters for updating user profile
class UpdateUserProfileParams extends UserParams {
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? department;
  final String? team;
  final String? role;
  final String? profilePictureUrl;
  final Map<String, dynamic>? preferences;
  final bool? isActive;

  const UpdateUserProfileParams({
    required this.email,
    this.name,
    this.phoneNumber,
    this.department,
    this.team,
    this.role,
    this.profilePictureUrl,
    this.preferences,
    this.isActive,
  });

  @override
  List<Object?> get props => [
    email,
    name,
    phoneNumber,
    department,
    team,
    role,
    profilePictureUrl,
    preferences,
    isActive,
  ];
}

// Parameters for getting users
class GetUsersParams extends UserParams {
  final String? role;
  final String? department;
  final String? team;
  final bool? isActive;
  final int? limit;
  final String? lastDocumentId;

  const GetUsersParams({
    this.role,
    this.department,
    this.team,
    this.isActive,
    this.limit,
    this.lastDocumentId,
  });

  @override
  List<Object?> get props => [
    role,
    department,
    team,
    isActive,
    limit,
    lastDocumentId,
  ];
}

// Parameters for creating a user
class CreateUserParams extends UserParams {
  final String email;
  final String name;
  final String role;
  final String? phoneNumber;
  final String? department;
  final String? team;
  final String? profilePictureUrl;
  final Map<String, dynamic>? preferences;

  const CreateUserParams({
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.department,
    this.team,
    this.profilePictureUrl,
    this.preferences,
  });

  @override
  List<Object?> get props => [
    email,
    name,
    role,
    phoneNumber,
    department,
    team,
    profilePictureUrl,
    preferences,
  ];
}

// Parameters for deleting a user
class DeleteUserParams extends UserParams {
  final String userId;

  const DeleteUserParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Parameters for searching users
class SearchUsersParams extends UserParams {
  final String query;
  final String? role;
  final String? department;
  final String? team;
  final bool? isActive;
  final int? limit;

  const SearchUsersParams({
    required this.query,
    this.role,
    this.department,
    this.team,
    this.isActive,
    this.limit,
  });

  @override
  List<Object?> get props => [query, role, department, team, isActive, limit];
}

// Parameters for getting user statistics
class GetUserStatisticsParams extends UserParams {
  final String? department;
  final String? team;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetUserStatisticsParams({
    this.department,
    this.team,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [department, team, startDate, endDate];
}

// Parameters for bulk user operations
class BulkUserParams extends UserParams {
  final List<String> userIds;
  final String operation; // 'delete', 'activate', 'deactivate', 'update_role'
  final Map<String, dynamic>? updateData;

  const BulkUserParams({
    required this.userIds,
    required this.operation,
    this.updateData,
  });

  @override
  List<Object?> get props => [userIds, operation, updateData];
}

// Parameters for exporting users
class ExportUsersParams extends UserParams {
  final List<String>? userIds;
  final String? role;
  final String? department;
  final String? team;
  final bool? isActive;
  final String format; // 'csv', 'pdf', 'excel'
  final Map<String, bool>? includeFields;

  const ExportUsersParams({
    this.userIds,
    this.role,
    this.department,
    this.team,
    this.isActive,
    required this.format,
    this.includeFields,
  });

  @override
  List<Object?> get props => [
    userIds,
    role,
    department,
    team,
    isActive,
    format,
    includeFields,
  ];
}
