import 'dart:io';
import 'package:flutter/foundation.dart';
import '../constants/deployment_constants.dart';

enum AppPlatform {
  android,
  ios,
  web,
  unknown;

  bool get isMobile => this == android || this == ios;
  bool get isNative => this == android || this == ios;
  bool get shouldUseWebView => this == ios || this == web;
  bool get shouldUseNative => this == android;
}

class PlatformService {
  static AppPlatform get currentPlatform {
    if (kIsWeb) {
      return AppPlatform.web;
    } else if (Platform.isAndroid) {
      return AppPlatform.android;
    } else if (Platform.isIOS) {
      return AppPlatform.ios;
    } else {
      return AppPlatform.unknown;
    }
  }

  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  // Determine if user should be redirected to web version
  static bool shouldRedirectToWeb({
    bool forceWebFallback = false,
    bool hasDeviceIssues = false,
  }) {
    final platform = currentPlatform;

    // Always redirect web users to web version
    if (platform == AppPlatform.web) {
      return true;
    }

    // Redirect iOS users to web (since iOS development costs money)
    if (platform == AppPlatform.ios && DeploymentConstants.enableIOSRedirect) {
      return true;
    }

    // Redirect users with device issues to web
    if (hasDeviceIssues && DeploymentConstants.enableWebFallback) {
      return true;
    }

    // Force web fallback for any reason
    if (forceWebFallback) {
      return true;
    }

    // Keep Android users on native if enabled
    if (platform == AppPlatform.android &&
        DeploymentConstants.enableAndroidNative) {
      return false;
    }

    // Default fallback to web
    return false;
  }

  // Get the appropriate app URL for web version
  static String getWebAppUrl({String? baseUrl}) {
    return baseUrl ?? DeploymentConstants.webAppUrl;
  }

  // Check if device has known compatibility issues
  static Future<bool> hasDeviceCompatibilityIssues() async {
    try {
      // Check for common device issues that would benefit from web version
      final platform = currentPlatform;

      if (platform == AppPlatform.android) {
        // Check Android version for compatibility
        // You can add more specific checks here
        return false; // For now, assume Android is compatible
      }

      if (platform == AppPlatform.ios) {
        // iOS devices will use web version anyway
        return true;
      }

      return false;
    } catch (e) {
      // If we can't determine compatibility, err on the side of web
      return true;
    }
  }

  // Get user agent string for web analytics
  static String getUserAgent() {
    final platform = currentPlatform;

    switch (platform) {
      case AppPlatform.android:
        return 'Android-App';
      case AppPlatform.ios:
        return 'iOS-WebView'; // Since iOS users will use web
      case AppPlatform.web:
        return 'Web-App';
      case AppPlatform.unknown:
        return 'Unknown-Platform';
    }
  }
}
