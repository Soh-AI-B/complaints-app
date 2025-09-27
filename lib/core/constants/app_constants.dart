class AppConstants {
  static const String appName = 'Complaints Manager';
  static const String appVersion = '1.0.0';

  // API Constants
  static const String baseUrl = 'https://firestore.googleapis.com/v1/projects/';
  static const String firestoreUrl = 'https://firestore.googleapis.com/v1/';

  // SharedPreferences Keys
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyUserRole = 'user_role';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyThemeMode = 'theme_mode';

  // Task Status
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';

  // Task Priority
  static const String priorityUrgent = 'Urgent';
  static const String priorityHigh = 'High';
  static const String priorityNormal = 'Normal';
  static const String priorityLow = 'Low';

  // User Roles
  static const String roleEmployee = 'Employee';
  static const String roleManager = 'Manager';

  // Categories
  static const List<String> taskCategories = [
    'Logistics',
    'Maintenance',
    'Tools',
    'Transportation',
    'Safety',
    'Equipment',
    'IT Support',
    'Documentation',
    'Other',
  ];

  // Priority Levels
  static const List<String> taskPriorities = [
    AppConstants.priorityLow,
    AppConstants.priorityNormal,
    AppConstants.priorityHigh,
    AppConstants.priorityUrgent,
  ];

  // Status Options
  static const List<String> taskStatuses = [
    AppConstants.statusPending,
    AppConstants.statusInProgress,
    AppConstants.statusCompleted,
    AppConstants.statusCancelled,
  ];
  // Image Upload
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxImagesPerTask = 2; // Maximum 2 images per task
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';
}
