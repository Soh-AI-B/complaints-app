import 'dart:convert';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/shared_preferences_helper.dart';
import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  /// Gets the cached user data
  /// Returns [UserModel] if user data is cached
  /// Throws [CacheException] if no user data is cached
  Future<UserModel> getCachedUser();

  /// Caches user data locally
  /// Throws [CacheException] on failure
  Future<void> cacheUser(UserModel user);

  /// Removes cached user data
  /// Throws [CacheException] on failure
  Future<void> clearCache();

  /// Checks if user data is cached
  Future<bool> hasUserCached();

  /// Gets cached auth token if any
  Future<String?> getCachedToken();

  /// Caches auth token
  Future<void> cacheToken(String token);

  /// Clears cached auth token
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl();

  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'auth_token';

  @override
  Future<UserModel> getCachedUser() async {
    try {
      final userJson = SharedPreferencesHelper.getString(_userKey);
      if (userJson == null) {
        throw const CacheException(message: 'No cached user found');
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
      await SharedPreferencesHelper.setString(_userKey, userJson);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await SharedPreferencesHelper.remove(_userKey);
      await SharedPreferencesHelper.remove(_tokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  @override
  Future<bool> hasUserCached() async {
    try {
      final userJson = SharedPreferencesHelper.getString(_userKey);
      return userJson != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getCachedToken() async {
    try {
      return SharedPreferencesHelper.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheToken(String token) async {
    try {
      await SharedPreferencesHelper.setString(_tokenKey, token);
    } catch (e) {
      throw CacheException(message: 'Failed to cache token: $e');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await SharedPreferencesHelper.remove(_tokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear token: $e');
    }
  }
}
