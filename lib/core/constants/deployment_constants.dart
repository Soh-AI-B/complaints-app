// Deployment configuration constants
// Update these values based on your deployment setup

class DeploymentConstants {
  // Web app URL - update this with your actual Vercel deployment URL
  static const String webAppUrl =
      'https://web-f4kdnyufr-sohaibmousselmal-ensiaedudzs-projects.vercel.app';

  // Backend API base URL (separate backend deployment)
  static const String apiBaseUrl =
      'https://vercel-backend-guun38dj8-sohaibmousselmal-ensiaedudzs-projects.vercel.app';

  // Firebase project configuration
  static const String firebaseProjectId = 'complaints-712af';

  // Environment
  static const bool isProduction = true; // Set to false for development

  // Platform-specific settings
  static const bool enableIOSRedirect = true; // Redirect iOS users to web
  static const bool enableWebFallback =
      true; // Allow web fallback for device issues
  static const bool enableAndroidNative =
      true; // Keep Android users on native app

  // Build information
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Feature flags
  static const bool enableNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;

  // API endpoints
  static const String sendNotificationEndpoint = '/api/send-notification';
  static const String sendTaskNotificationEndpoint =
      '/api/send-task-notification';
  static const String sendToManagersEndpoint = '/api/send-to-managers';
  static const String healthCheckEndpoint = '/api/health';

  // Get full API URL
  static String getApiUrl(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }
}
