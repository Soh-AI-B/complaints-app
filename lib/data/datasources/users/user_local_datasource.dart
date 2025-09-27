import 'dart:convert';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/shared_preferences_helper.dart';
import '../../models/user_model.dart';

abstract class UserLocalDataSource {
  /// Gets cached users
  Future<List<UserModel>> getCachedUsers();

  /// Caches users locally
  Future<void> cacheUsers(List<UserModel> users);

  /// Gets a cached user by email
  Future<UserModel> getCachedUserByEmail(String email);

  /// Gets a cached user by email (nullable)
  Future<UserModel?> getCachedUser(String email);

  /// Caches a single user
  Future<void> cacheUser(UserModel user);

  /// Removes a cached user
  Future<void> removeCachedUser(String email);

  /// Removes cached users
  Future<void> clearCache();

  /// Checks if users are cached
  Future<bool> hasUsersCached();

  /// Gets cached users by role
  Future<List<UserModel>> getCachedUsersByRole(String role);

  /// Gets cached users by team
  Future<List<UserModel>> getCachedUsersByTeam(String team);

  /// Gets cached active users
  Future<List<UserModel>> getCachedActiveUsers();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  const UserLocalDataSourceImpl();

  static const String _usersKey = 'cached_users';
  static const String _userPrefix = 'cached_user_';

  @override
  Future<List<UserModel>> getCachedUsers() async {
    try {
      final usersJson = SharedPreferencesHelper.getString(_usersKey);
      if (usersJson == null) {
        throw const CacheException(message: 'No cached users found');
      }

      final usersList = json.decode(usersJson) as List<dynamic>;
      return usersList
          .map(
            (userJson) => UserModel.fromJson(userJson as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached users: $e');
    }
  }

  @override
  Future<void> cacheUsers(List<UserModel> users) async {
    try {
      final usersJson = json.encode(
        users.map((user) => user.toJson()).toList(),
      );
      await SharedPreferencesHelper.setString(_usersKey, usersJson);
    } catch (e) {
      throw CacheException(message: 'Failed to cache users: $e');
    }
  }

  @override
  Future<UserModel> getCachedUserByEmail(String email) async {
    try {
      final userJson = SharedPreferencesHelper.getString('$_userPrefix$email');
      if (userJson == null) {
        throw const CacheException(message: 'User not found in cache');
      }

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await SharedPreferencesHelper.setString(
        '$_userPrefix${user.userEmail}',
        userJson,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await SharedPreferencesHelper.remove(_usersKey);
      // Note: Individual user cache cleanup would require more sophisticated key management
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  @override
  Future<bool> hasUsersCached() async {
    try {
      final usersJson = SharedPreferencesHelper.getString(_usersKey);
      return usersJson != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<UserModel>> getCachedUsersByRole(String role) async {
    try {
      final allUsers = await getCachedUsers();
      return allUsers.where((user) => user.role == role).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached users by role: $e');
    }
  }

  @override
  Future<List<UserModel>> getCachedUsersByTeam(String team) async {
    try {
      final allUsers = await getCachedUsers();
      return allUsers.where((user) => user.team == team).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached users by team: $e');
    }
  }

  @override
  Future<List<UserModel>> getCachedActiveUsers() async {
    try {
      final allUsers = await getCachedUsers();
      return allUsers.where((user) => user.isActive).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached active users: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser(String email) async {
    try {
      final userJson = SharedPreferencesHelper.getString('$_userPrefix$email');
      if (userJson == null) {
        return null;
      }

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> removeCachedUser(String email) async {
    try {
      await SharedPreferencesHelper.remove('$_userPrefix$email');
    } catch (e) {
      throw CacheException(message: 'Failed to remove cached user: $e');
    }
  }
}
