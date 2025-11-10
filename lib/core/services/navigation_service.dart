import 'package:flutter/material.dart';

/// Global navigation service for handling navigation from anywhere in the app
/// Used primarily for notification tap handling
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get the current context
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate to a named route
  static Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and replace the current route
  static Future<dynamic>? navigateToAndReplace(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and clear all previous routes
  static Future<dynamic>? navigateToAndClearStack(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Go back to the previous screen
  static void goBack({dynamic result}) {
    navigatorKey.currentState?.pop(result);
  }

  /// Check if we can go back
  static bool canGoBack() {
    return navigatorKey.currentState?.canPop() ?? false;
  }
}
