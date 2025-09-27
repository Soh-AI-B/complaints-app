import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'web_storage_helper.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _preferences;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // String operations
  static Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    return await _preferences!.setString(key, value);
  }

  static String? getString(String key, {String? defaultValue}) {
    return _preferences?.getString(key) ?? defaultValue;
  }

  // Int operations
  static Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    return await _preferences!.setInt(key, value);
  }

  static int? getInt(String key, {int? defaultValue}) {
    return _preferences?.getInt(key) ?? defaultValue;
  }

  // Double operations
  static Future<bool> setDouble(String key, double value) async {
    await _ensureInitialized();
    return await _preferences!.setDouble(key, value);
  }

  static double? getDouble(String key, {double? defaultValue}) {
    return _preferences?.getDouble(key) ?? defaultValue;
  }

  // Bool operations
  static Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    return await _preferences!.setBool(key, value);
  }

  static bool? getBool(String key, {bool? defaultValue}) {
    return _preferences?.getBool(key) ?? defaultValue;
  }

  // List<String> operations
  static Future<bool> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    return await _preferences!.setStringList(key, value);
  }

  static List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return _preferences?.getStringList(key) ?? defaultValue;
  }

  // JSON operations
  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    await _ensureInitialized();
    final jsonString = json.encode(value);
    return await _preferences!.setString(key, jsonString);
  }

  static Map<String, dynamic>? getJson(
    String key, {
    Map<String, dynamic>? defaultValue,
  }) {
    final jsonString = _preferences?.getString(key);
    if (jsonString != null) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  // Remove operations
  static Future<bool> remove(String key) async {
    await _ensureInitialized();
    return await _preferences!.remove(key);
  }

  // Clear all
  static Future<bool> clear() async {
    await _ensureInitialized();
    return await _preferences!.clear();
  }

  // Check if key exists
  static bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }

  // Get all keys
  static Set<String> getKeys() {
    return _preferences?.getKeys() ?? <String>{};
  }

  // User-specific operations
  static Future<bool> setUserId(String userId) async {
    return await setString('user_id', userId);
  }

  static String? getUserId() {
    return getString('user_id');
  }

  static Future<bool> setUserEmail(String email) async {
    return await setString('user_email', email);
  }

  static String? getUserEmail() {
    return getString('user_email');
  }

  static Future<bool> setUserName(String name) async {
    return await setString('user_name', name);
  }

  static String? getUserName() {
    return getString('user_name');
  }

  static Future<bool> setUserRole(String role) async {
    return await setString('user_role', role);
  }

  static String? getUserRole() {
    return getString('user_role');
  }

  static Future<bool> setUserTeam(String team) async {
    return await setString('user_team', team);
  }

  static String? getUserTeam() {
    return getString('user_team');
  }

  static Future<bool> setIsLoggedIn(bool isLoggedIn) async {
    return await setBool('is_logged_in', isLoggedIn);
  }

  static bool getIsLoggedIn() {
    return getBool('is_logged_in', defaultValue: false) ?? false;
  }

  static Future<bool> setAuthToken(String token) async {
    return await setString('auth_token', token);
  }

  static String? getAuthToken() {
    return getString('auth_token');
  }

  // App settings
  static Future<bool> setThemeMode(String themeMode) async {
    return await setString('theme_mode', themeMode);
  }

  static String getThemeMode() {
    return getString('theme_mode', defaultValue: 'system') ?? 'system';
  }

  static Future<bool> setLanguage(String language) async {
    return await setString('language', language);
  }

  static String getLanguage() {
    return getString('language', defaultValue: 'en') ?? 'en';
  }

  static Future<bool> setNotificationsEnabled(bool enabled) async {
    return await setBool('notifications_enabled', enabled);
  }

  static bool getNotificationsEnabled() {
    return getBool('notifications_enabled', defaultValue: true) ?? true;
  }

  // Task filters
  static Future<bool> setLastSelectedCategory(String category) async {
    return await setString('last_selected_category', category);
  }

  static String? getLastSelectedCategory() {
    return getString('last_selected_category');
  }

  static Future<bool> setLastSelectedPriority(String priority) async {
    return await setString('last_selected_priority', priority);
  }

  static String? getLastSelectedPriority() {
    return getString('last_selected_priority');
  }

  static Future<bool> setLastSelectedStatus(String status) async {
    return await setString('last_selected_status', status);
  }

  static String? getLastSelectedStatus() {
    return getString('last_selected_status');
  }

  // Search history
  static Future<bool> addSearchHistory(String query) async {
    final history = getSearchHistory();
    if (!history.contains(query)) {
      history.insert(0, query);
      // Keep only last 10 searches
      if (history.length > 10) {
        history.removeLast();
      }
      return await setStringList('search_history', history);
    }
    return true;
  }

  static List<String> getSearchHistory() {
    return getStringList('search_history', defaultValue: []) ?? [];
  }

  static Future<bool> clearSearchHistory() async {
    return await remove('search_history');
  }

  // Cache operations
  static Future<bool> setCacheData(
    String key,
    Map<String, dynamic> data, {
    Duration? expiry,
  }) async {
    final cacheItem = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    return await setJson('cache_$key', cacheItem);
  }

  static Map<String, dynamic>? getCacheData(String key) {
    final cacheItem = getJson('cache_$key');
    if (cacheItem != null) {
      final timestamp = cacheItem['timestamp'] as int?;
      final expiry = cacheItem['expiry'] as int?;

      if (timestamp != null && expiry != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - timestamp > expiry) {
          // Cache expired
          remove('cache_$key');
          return null;
        }
      }

      return cacheItem['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  static Future<bool> clearCache() async {
    await _ensureInitialized();
    final keys = _preferences!.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith('cache_')).toList();

    for (final key in cacheKeys) {
      await _preferences!.remove(key);
    }

    return true;
  }

  // User session management (Web and Mobile compatible)
  static Future<bool> saveUserSession({
    required String userId,
    required String email,
    required String name,
    required String role,
    String? team,
    String? authToken,
  }) async {
    if (kIsWeb) {
      // Use WebStorageHelper for web
      await WebStorageHelper.saveUserSession(
        email: email,
        name: name,
        role: role,
        team: team,
        token: authToken,
      );
      return true;
    } else {
      // Use SharedPreferences for mobile
      await Future.wait([
        setUserId(userId),
        setUserEmail(email),
        setUserName(name),
        setUserRole(role),
        setIsLoggedIn(true),
        if (team != null) setUserTeam(team),
        if (authToken != null) setAuthToken(authToken),
      ]);
      return true;
    }
  }

  static Future<bool> clearUserSession() async {
    if (kIsWeb) {
      // Use WebStorageHelper for web
      await WebStorageHelper.clearUserSession();
      return true;
    } else {
      // Use SharedPreferences for mobile
      await Future.wait([
        remove('user_id'),
        remove('user_email'),
        remove('user_name'),
        remove('user_role'),
        remove('user_team'),
        remove('auth_token'),
        setIsLoggedIn(false),
      ]);
      return true;
    }
  }

  static Future<bool> getIsLoggedInAsync() async {
    if (kIsWeb) {
      return await WebStorageHelper.isUserLoggedIn();
    } else {
      return getIsLoggedIn();
    }
  }

  static Future<Map<String, String?>> getSavedUserData() async {
    if (kIsWeb) {
      return await WebStorageHelper.getSavedUserData();
    } else {
      return {
        'email': getUserEmail(),
        'name': getUserName(),
        'role': getUserRole(),
        'team': getUserTeam(),
        'token': getAuthToken(),
      };
    }
  }

  // Ensure SharedPreferences is initialized
  static Future<void> _ensureInitialized() async {
    if (_preferences == null) {
      await init();
    }
  }

  // Debug method to get all preferences
  static Map<String, dynamic> getAllPreferences() {
    if (_preferences == null) return {};

    final keys = _preferences!.getKeys();
    final Map<String, dynamic> allPrefs = {};

    for (final key in keys) {
      final value = _preferences!.get(key);
      allPrefs[key] = value;
    }

    return allPrefs;
  }
}
