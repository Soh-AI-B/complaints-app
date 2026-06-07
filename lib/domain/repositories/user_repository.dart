import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  // Get user profile by email
  Future<Either<Failure, User>> getUserProfile(String email);

  // Update user profile
  Future<Either<Failure, User>> updateUserProfile({
    required String email,
    String? name,
    String? phone,
    String? team,
    bool? notificationEnabled,
    bool? taskReminderNotificationsEnabled,
    bool? newTaskNotificationsEnabled,
    List<String>? notificationTimes,
  });

  // Get all users (for managers)
  Future<Either<Failure, List<User>>> getAllUsers({
    int? limit,
    String? lastUserId,
  });

  // Get users by role
  Future<Either<Failure, List<User>>> getUsersByRole({
    required String role,
    int? limit,
    String? lastUserId,
  });

  // Get users by team
  Future<Either<Failure, List<User>>> getUsersByTeam({
    required String team,
    int? limit,
    String? lastUserId,
  });

  // Search users
  Future<Either<Failure, List<User>>> searchUsers({
    required String query,
    int? limit,
    String? lastUserId,
  });

  // Create user
  Future<Either<Failure, User>> createUser({
    required String email,
    required String name,
    required String role,
    required String team,
    String? phone,
  });

  // Delete user
  Future<Either<Failure, void>> deleteUser(String email);

  // Activate/Deactivate user
  Future<Either<Failure, User>> updateUserStatus({
    required String email,
    required bool isActive,
  });

  // Get user statistics
  Future<Either<Failure, Map<String, int>>> getUserStatistics();

  // Get users count by role
  Future<Either<Failure, Map<String, int>>> getUsersCountByRole();

  // Get users count by team
  Future<Either<Failure, Map<String, int>>> getUsersCountByTeam();

  // Get active users
  Future<Either<Failure, List<User>>> getActiveUsers({
    int? limit,
    String? lastUserId,
  });

  // Get inactive users
  Future<Either<Failure, List<User>>> getInactiveUsers({
    int? limit,
    String? lastUserId,
  });

  // Get recently created users
  Future<Either<Failure, List<User>>> getRecentUsers({
    int? limit,
    String? lastUserId,
  });

  // Check if user exists
  Future<Either<Failure, bool>> userExists(String email);

  // Get managers
  Future<Either<Failure, List<User>>> getManagers({
    int? limit,
    String? lastUserId,
  });

  // Get employees
  Future<Either<Failure, List<User>>> getEmployees({
    int? limit,
    String? lastUserId,
  });

  // Get team members
  Future<Either<Failure, List<User>>> getTeamMembers({
    required String team,
    int? limit,
    String? lastUserId,
  });

  // Update user team
  Future<Either<Failure, User>> updateUserTeam({
    required String email,
    required String newTeam,
  });

  // Update user role
  Future<Either<Failure, User>> updateUserRole({
    required String email,
    required String newRole,
    List<String>? managedCategories, // New parameter for manager categories
  });

  // Bulk update users
  Future<Either<Failure, List<User>>> bulkUpdateUsers({
    required List<String> userEmails,
    String? team,
    String? role,
    bool? isActive,
  });

  // Export users to CSV
  Future<Either<Failure, String>> exportUsersToCSV({
    String? role,
    String? team,
    bool? isActive,
  });

  // Get user activity summary
  Future<Either<Failure, Map<String, dynamic>>> getUserActivitySummary({
    required String email,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Get team activity summary
  Future<Either<Failure, Map<String, dynamic>>> getTeamActivitySummary({
    required String team,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Get users stream for real-time updates
  Stream<Either<Failure, List<User>>> getUsersStream({
    String? role,
    String? team,
    bool? isActive,
  });

  // Get user stream by email for real-time updates
  Stream<Either<Failure, User>> getUserStreamByEmail(String email);
}
