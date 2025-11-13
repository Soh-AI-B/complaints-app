import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'platform_service.dart';
import '../constants/deployment_constants.dart';

class WebRedirectService {
  static String get _webAppUrl => DeploymentConstants.webAppUrl;

  // Check if redirect is needed and handle it
  static Future<bool> checkAndHandleRedirect(
    BuildContext context, {
    bool forceWebFallback = false,
    bool hasDeviceIssues = false,
  }) async {
    final shouldRedirect = PlatformService.shouldRedirectToWeb(
      forceWebFallback: forceWebFallback,
      hasDeviceIssues: hasDeviceIssues,
    );

    if (shouldRedirect) {
      await _showWebRedirectDialog(context);
      return true;
    }

    return false;
  }

  // Show dialog asking user if they want to use web version
  static Future<void> _showWebRedirectDialog(BuildContext context) async {
    final platform = PlatformService.currentPlatform;

    String title;
    String message;

    switch (platform) {
      case AppPlatform.ios:
        title = 'iOS Web Version Available';
        message =
            'For the best experience, we recommend using our web version. Would you like to continue with the web app?';
        break;
      case AppPlatform.web:
        title = 'Web Version';
        message = 'You are using the web version of our app.';
        break;
      default:
        title = 'Web Version Available';
        message =
            'We detected some compatibility issues. Would you like to try our web version instead?';
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (platform != AppPlatform.web) ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Continue with App'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Use Web Version'),
              ),
            ] else ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continue'),
              ),
            ],
          ],
        );
      },
    );

    if (result == true) {
      await _redirectToWebApp();
    }
  }

  // Launch web app in external browser
  static Future<void> _redirectToWebApp() async {
    final url = Uri.parse(_webAppUrl);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Opens in external browser
        );
      } else {
        throw 'Could not launch $_webAppUrl';
      }
    } catch (e) {
      debugPrint('Error launching web app: $e');
      // Fallback: you could show an error dialog or try alternative methods
    }
  }

  // Get web app URL for sharing or other purposes
  static String getWebAppUrl() {
    return _webAppUrl;
  }

  // Check if we're already on web
  static bool isAlreadyOnWeb() {
    return PlatformService.isWeb;
  }
}
