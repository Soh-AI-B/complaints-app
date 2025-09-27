class AppRoutes {
  // Authentication Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgetPassword = '/forget-password';

  // Employee Routes
  static const String employeeHome = '/employee/home';
  static const String addComplaint = '/employee/add-complaint';
  static const String myTasks = '/employee/my-tasks';
  static const String taskDetail = '/employee/task-detail';

  // Manager Routes
  static const String managerHome = '/manager/home';
  static const String dashboard = '/manager/dashboard';
  static const String tasksList = '/manager/tasks-list';
  static const String taskManagement = '/manager/task-management';
  static const String analytics = '/manager/analytics';
  static const String manageUsers = '/manager/manage-users';

  // Admin Routes
  static const String adminSetup = '/admin/setup';
  static const String taskCleanup = '/admin/task-cleanup';

  // Common Routes
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String debugTokens = '/debug-tokens';

  // Route Parameters
  static const String taskIdParam = 'taskId';
  static const String userRoleParam = 'userRole';

  // Route with Parameters
  static String taskDetailWithId(String taskId) => '$taskDetail/$taskId';
  static String taskManagementWithId(String taskId) =>
      '$taskManagement/$taskId';
}
