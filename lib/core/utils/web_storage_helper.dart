import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' if (dart.library.io) 'dart:io' as html;

/// Web-compatible local storage helper that persists user session data
class WebStorageHelper {
  static const String _userTokenKey = 'user_token';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';
  static const String _userTeamKey = 'user_team';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Save user session data
  static Future<void> saveUserSession({
    required String email,
    required String name,
    required String role,
    String? team,
    String? token,
  }) async {
    if (kIsWeb) {
      // For web, use localStorage
      html.window.localStorage[_userEmailKey] = email;
      html.window.localStorage[_userNameKey] = name;
      html.window.localStorage[_userRoleKey] = role;
      html.window.localStorage[_isLoggedInKey] = 'true';
      
      if (team != null) {
        html.window.localStorage[_userTeamKey] = team;
      }
      if (token != null) {
        html.window.localStorage[_userTokenKey] = token;
      }
    } else {
      // For mobile, use SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_userNameKey, name);
      await prefs.setString(_userRoleKey, role);
      await prefs.setBool(_isLoggedInKey, true);
      
      if (team != null) {
        await prefs.setString(_userTeamKey, team);
      }
      if (token != null) {
        await prefs.setString(_userTokenKey, token);
      }
    }
  }

  /// Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    if (kIsWeb) {
      return html.window.localStorage[_isLoggedInKey] == 'true';
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    }
  }

  /// Get saved user data
  static Future<Map<String, String?>> getSavedUserData() async {
    if (kIsWeb) {
      return {
        'email': html.window.localStorage[_userEmailKey],
        'name': html.window.localStorage[_userNameKey],
        'role': html.window.localStorage[_userRoleKey],
        'team': html.window.localStorage[_userTeamKey],
        'token': html.window.localStorage[_userTokenKey],
      };
    } else {
      final prefs = await SharedPreferences.getInstance();
      return {
        'email': prefs.getString(_userEmailKey),
        'name': prefs.getString(_userNameKey),
        'role': prefs.getString(_userRoleKey),
        'team': prefs.getString(_userTeamKey),
        'token': prefs.getString(_userTokenKey),
      };
    }
  }

  /// Clear user session data (logout)
  static Future<void> clearUserSession() async {
    if (kIsWeb) {
      html.window.localStorage.remove(_userTokenKey);
      html.window.localStorage.remove(_userEmailKey);
      html.window.localStorage.remove(_userNameKey);
      html.window.localStorage.remove(_userRoleKey);
      html.window.localStorage.remove(_userTeamKey);
      html.window.localStorage.remove(_isLoggedInKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userTokenKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_userTeamKey);
      await prefs.remove(_isLoggedInKey);
    }
  }

  /// Save app settings/preferences
  static Future<void> saveSetting(String key, String value) async {
    if (kIsWeb) {
      html.window.localStorage[key] = value;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }

  /// Get app setting/preference
  static Future<String?> getSetting(String key) async {
    if (kIsWeb) {
      return html.window.localStorage[key];
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }

  /// Clear all app data
  static Future<void> clearAllData() async {
    if (kIsWeb) {
      html.window.localStorage.clear();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }
}