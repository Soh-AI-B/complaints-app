class Environment {
  // Firebase Configuration
  static const bool useFirebase =
      true; // Set to false for development without Firebase

  // Cloudinary Configuration
  static const String cloudinaryCloudName = 'dwkblixgf';
  static const String cloudinaryUploadPreset = 'complaints_preset';

  // App Configuration
  static const String appName = 'Complaints Management';
  static const String appVersion = '1.0.0';

  // Development Configuration
  static const bool enableLogging = true;
  static const bool enableAnalytics = true;
}
