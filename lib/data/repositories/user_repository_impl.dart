import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/user.dart' as entities;
import '../../domain/repositories/user_repository.dart';
import '../datasources/users/user_remote_datasource.dart';
import '../datasources/users/user_local_datasource.dart';
import '../models/user_model.dart';
import '../../core/network/network_info.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, entities.User>> getUserProfile(String email) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getUserByEmail(email);
        await localDataSource.cacheUser(user);
        return Right(user.toEntity());
      } on ServerException {
        return Left(ServerFailure(message: "Server error"));
      } on NetworkException {
        return Left(NetworkFailure(message: "Network error"));
      }
    } else {
      try {
        final cachedUser = await localDataSource.getCachedUser(email);
        if (cachedUser != null) {
          return Right(cachedUser.toEntity());
        } else {
          return Left(CacheFailure(message: "Cache error"));
        }
      } on CacheException {
        return Left(CacheFailure(message: "Cache error"));
      }
    }
  }

  @override
  Future<Either<Failure, entities.User>> updateUserProfile({
    required String email,
    String? name,
    String? phone,
    String? team,
    bool? notificationEnabled,
    bool? taskReminderNotificationsEnabled,
    bool? newTaskNotificationsEnabled,
    List<String>? notificationTimes,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final updates = <String, dynamic>{};
        if (name != null) updates['name'] = name;
        if (phone != null) updates['phone'] = phone;
        if (team != null) updates['team'] = team;
        if (notificationEnabled != null) {
          updates['notification_enabled'] = notificationEnabled;
        }
        if (taskReminderNotificationsEnabled != null) {
          updates['task_reminder_notifications_enabled'] =
              taskReminderNotificationsEnabled;
        }
        if (newTaskNotificationsEnabled != null) {
          updates['new_task_notifications_enabled'] =
              newTaskNotificationsEnabled;
        }
        if (notificationTimes != null) {
          updates['notification_times'] = notificationTimes;
        }
        updates['updated_at'] = DateTime.now();

        final updatedUser = await remoteDataSource.updateUser(email, updates);
        await localDataSource.cacheUser(updatedUser);
        return Right(updatedUser.toEntity());
      } on ServerException {
        return Left(ServerFailure(message: "Server error"));
      } on NetworkException {
        return Left(NetworkFailure(message: "Network error"));
      }
    } else {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, List<entities.User>>> getAllUsers({
    int? limit,
    String? lastUserId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final users = await remoteDataSource.getAllUsers();
        await localDataSource.cacheUsers(users);
        return Right(users.map((user) => user.toEntity()).toList());
      } on ServerException {
        return Left(ServerFailure(message: "Server error"));
      } on NetworkException {
        return Left(NetworkFailure(message: "Network error"));
      }
    } else {
      try {
        final cachedUsers = await localDataSource.getCachedUsers();
        return Right(cachedUsers.map((user) => user.toEntity()).toList());
      } on CacheException {
        return Left(CacheFailure(message: "Cache error"));
      }
    }
  }

  @override
  Future<Either<Failure, List<entities.User>>> getUsersByRole({
    required String role,
    int? limit,
    String? lastUserId,
  }) async {
    try {
      final users = await remoteDataSource.getUsersByRole(role);
      return Right(users.map((user) => user.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, List<entities.User>>> getUsersByTeam({
    required String team,
    int? limit,
    String? lastUserId,
  }) async {
    try {
      final users = await remoteDataSource.getUsersByTeam(team);
      return Right(users.map((user) => user.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, List<entities.User>>> searchUsers({
    required String query,
    int? limit,
    String? lastUserId,
  }) async {
    try {
      final users = await remoteDataSource.searchUsers(query);
      return Right(users.map((user) => user.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, entities.User>> createUser({
    required String email,
    required String name,
    required String role,
    required String team,
    String? phone,
  }) async {
    try {
      final user = UserModel(
        userEmail: email,
        name: name,
        role: role,
        team: team,
        phone: phone,
        isActive: true,
        createdAt: DateTime.now(),
      );
      final createdUser = await remoteDataSource.createUser(user);
      await localDataSource.cacheUser(createdUser);
      return Right(createdUser.toEntity());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String email) async {
    try {
      await remoteDataSource.deleteUser(email);
      await localDataSource.removeCachedUser(email);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, entities.User>> updateUserStatus({
    required String email,
    required bool isActive,
  }) async {
    try {
      final updatedUser = await remoteDataSource.updateUser(email, {
        'is_active': isActive,
        'updated_at': DateTime.now(),
      });
      await localDataSource.cacheUser(updatedUser);
      return Right(updatedUser.toEntity());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getUserStatistics() async {
    try {
      final stats = await remoteDataSource.getUserStatistics();
      return Right(stats);
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getUsersCountByRole() async {
    try {
      final stats = await remoteDataSource.getUsersCountByRole();
      return Right(stats);
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getUsersCountByTeam() async {
    try {
      final stats = await remoteDataSource.getUsersCountByTeam();
      return Right(stats);
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, List<entities.User>>> getActiveUsers({
    int? limit,
    String? lastUserId,
  }) async {
    try {
      final users = await remoteDataSource.getActiveUsers();
      return Right(users.map((user) => user.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, List<entities.User>>> getInactiveUsers({
    int? limit,
    String? lastUserId,
  }) async {
    try {
      final users = await remoteDataSource.getInactiveUsers();
      return Right(users.map((user) => user.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, List<entities.User>>> getRecentUsers({
    int? limit,
    String? lastUserId,
  }) async {
    try {
      final users = await remoteDataSource.getRecentUsers();
      return Right(users.map((user) => user.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, bool>> userExists(String email) async {
    try {
      final exists = await remoteDataSource.userExists(email);
      return Right(exists);
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, List<entities.User>>> getManagers({
    int? limit,
    String? lastUserId,
  }) async {
    try {
      final users = await remoteDataSource.getManagers();
      return Right(users.map((user) => user.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, List<entities.User>>> getEmployees({
    int? limit,
    String? lastUserId,
  }) async {
    try {
      final users = await remoteDataSource.getEmployees();
      return Right(users.map((user) => user.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, List<entities.User>>> getTeamMembers({
    required String team,
    int? limit,
    String? lastUserId,
  }) async {
    try {
      final users = await remoteDataSource.getTeamMembers(team);
      return Right(users.map((user) => user.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, entities.User>> updateUserTeam({
    required String email,
    required String newTeam,
  }) async {
    try {
      final updatedUser = await remoteDataSource.updateUser(email, {
        'team': newTeam,
        'updated_at': DateTime.now(),
      });
      await localDataSource.cacheUser(updatedUser);
      return Right(updatedUser.toEntity());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, entities.User>> updateUserRole({
    required String email,
    required String newRole,
    List<String>? managedCategories,
  }) async {
    try {
      final updates = <String, dynamic>{
        'role': newRole,
        'updated_at': DateTime.now(),
      };

      // Add managedCategories if provided (for managers)
      if (managedCategories != null) {
        updates['managed_categories'] = managedCategories;
      }

      final updatedUser = await remoteDataSource.updateUser(email, updates);
      await localDataSource.cacheUser(updatedUser);
      return Right(updatedUser.toEntity());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, List<entities.User>>> bulkUpdateUsers({
    required List<String> userEmails,
    String? team,
    String? role,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{'updated_at': DateTime.now()};
      if (team != null) updates['team'] = team;
      if (role != null) updates['role'] = role;
      if (isActive != null) updates['is_active'] = isActive;

      final updatedUsers = await remoteDataSource.bulkUpdateUsers(
        userEmails,
        updates,
      );

      // Cache updated users
      for (final user in updatedUsers) {
        await localDataSource.cacheUser(user);
      }

      return Right(updatedUsers.map((user) => user.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, String>> exportUsersToCSV({
    String? role,
    String? team,
    bool? isActive,
  }) async {
    try {
      final csvData = await remoteDataSource.exportUsersToCSV(
        role: role,
        team: team,
        isActive: isActive,
      );
      return Right(csvData);
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserActivitySummary({
    required String email,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final summary = await remoteDataSource.getUserActivitySummary(
        email,
        startDate,
        endDate,
      );
      return Right(summary);
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTeamActivitySummary({
    required String team,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final summary = await remoteDataSource.getTeamActivitySummary(
        team,
        startDate,
        endDate,
      );
      return Right(summary);
    } on ServerException {
      return Left(ServerFailure(message: "Server error"));
    } on NetworkException {
      return Left(NetworkFailure(message: "Network error"));
    }
  }

  @override
  Stream<Either<Failure, List<entities.User>>> getUsersStream({
    String? role,
    String? team,
    bool? isActive,
  }) {
    return remoteDataSource
        .getUsersStream(role: role, team: team, isActive: isActive)
        .map((users) => Right(users.map((user) => user.toEntity()).toList()));
  }

  @override
  Stream<Either<Failure, entities.User>> getUserStreamByEmail(String email) {
    return remoteDataSource
        .getUserStreamByEmail(email)
        .map((user) => Right(user.toEntity()));
  }
}
