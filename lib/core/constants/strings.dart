class AppStrings {
  // App Info
  static const String appName = 'Complaints Manager';
  static const String appDescription =
      'Manage logistics complaints and tasks efficiently';

  // Authentication
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Full Name';
  static const String phone = 'Phone Number';
  static const String team = 'Team/Department';
  static const String role = 'Role';
  static const String selectRole = 'Select Role';
  static const String employee = 'Employee';
  static const String manager = 'Manager';
  static const String forgotPassword = 'Forgot Password?';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account? Login';
  static const String dontHaveAccount = "Don't have an account? Register";
  static const String welcomeBack = 'Welcome Back!';
  static const String createNewAccount = 'Create New Account';

  // Home Screen
  static const String dashboard = 'Dashboard';
  static const String home = 'Home';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';

  // Tasks/Complaints
  static const String tasks = 'Tasks';
  static const String myTasks = 'My Tasks';
  static const String allTasks = 'All Tasks';
  static const String addComplaint = 'Add Complaint';
  static const String createTask = 'Create Task';
  static const String editTask = 'Edit Task';
  static const String taskDetails = 'Task Details';
  static const String title = 'Title';
  static const String description = 'Description';
  static const String category = 'Category';
  static const String priority = 'Priority';
  static const String status = 'Status';
  static const String assignedTo = 'Assigned To';
  static const String dateReported = 'Date Reported';
  static const String dateUpdated = 'Last Updated';
  static const String estimatedCompletion = 'Estimated Completion';
  static const String managerNotes = 'Manager Notes';
  static const String attachImage = 'Attach Image';
  static const String selectCategory = 'Select Category';
  static const String selectPriority = 'Select Priority';
  static const String selectStatus = 'Select Status';

  // Status Values
  static const String pending = 'Pending';
  static const String inProgress = 'In Progress';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';

  // Priority Values
  static const String urgent = 'Urgent';
  static const String normal = 'Normal';
  static const String low = 'Low';

  // Categories
  static const String logistics = 'Logistics';
  static const String maintenance = 'Maintenance';
  static const String tools = 'Tools';
  static const String transportation = 'Transportation';
  static const String safety = 'Safety';
  static const String equipment = 'Equipment';
  static const String itSupport = 'IT Support';
  static const String documentation = 'Documentation';
  static const String other = 'Other';

  // Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String update = 'Update';
  static const String submit = 'Submit';
  static const String retry = 'Retry';
  static const String refresh = 'Refresh';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String clear = 'Clear';
  static const String apply = 'Apply';
  static const String close = 'Close';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';

  // Messages
  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String noTasks = 'No tasks found';
  static const String noInternet = 'No internet connection';
  static const String tryAgain = 'Please try again';
  static const String somethingWentWrong = 'Something went wrong';
  static const String success = 'Success';
  static const String error = 'Error';
  static const String warning = 'Warning';
  static const String info = 'Info';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String registrationSuccess = 'Registration successful';
  static const String taskCreated = 'Task created successfully';
  static const String taskUpdated = 'Task updated successfully';
  static const String taskDeleted = 'Task deleted successfully';
  static const String profileUpdated = 'Profile updated successfully';

  // Error Messages
  static const String loginFailed = 'Login failed';
  static const String registrationFailed = 'Registration failed';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String passwordsNotMatch = 'Passwords do not match';
  static const String fieldRequired = 'This field is required';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String taskCreateFailed = 'Failed to create task';
  static const String taskUpdateFailed = 'Failed to update task';
  static const String taskDeleteFailed = 'Failed to delete task';
  static const String imageUploadFailed = 'Failed to upload image';
  static const String imageTooLarge = 'Image size must be less than 5MB';
  static const String invalidImageType =
      'Please select a valid image (JPG, PNG)';

  // Analytics
  static const String analytics = 'Analytics';
  static const String totalTasks = 'Total Tasks';
  static const String completedTasks = 'Completed Tasks';
  static const String pendingTasks = 'Pending Tasks';
  static const String inProgressTasks = 'In Progress Tasks';
  static const String urgentTasks = 'Urgent Tasks';
  static const String thisMonth = 'This Month';
  static const String thisWeek = 'This Week';
  static const String today = 'Today';
  static const String tasksByCategory = 'Tasks by Category';
  static const String tasksByPriority = 'Tasks by Priority';
  static const String tasksByStatus = 'Tasks by Status';

  // Filters
  static const String filterByStatus = 'Filter by Status';
  static const String filterByPriority = 'Filter by Priority';
  static const String filterByCategory = 'Filter by Category';
  static const String filterByDate = 'Filter by Date';
  static const String allStatuses = 'All Statuses';
  static const String allPriorities = 'All Priorities';
  static const String allCategories = 'All Categories';

  // Confirmation Messages
  static const String confirmLogout = 'Are you sure you want to logout?';
  static const String confirmDelete =
      'Are you sure you want to delete this task?';
  static const String confirmCancel =
      'Are you sure you want to cancel this task?';

  // Permissions
  static const String cameraPermission = 'Camera Permission';
  static const String storagePermission = 'Storage Permission';
  static const String permissionDenied = 'Permission denied';
  static const String permissionRequired =
      'This permission is required to continue';
  static const String grantPermission = 'Grant Permission';
}
