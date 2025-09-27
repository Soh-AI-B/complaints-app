class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailRegex).hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }

    // Check if name contains only letters and spaces
    const nameRegex = r'^[a-zA-Z\s]+$';
    if (!RegExp(nameRegex).hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    final phoneDigits = value.replaceAll(RegExp(r'[^\d]'), '');

    if (phoneDigits.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    return null;
  }

  // Task title validation
  static String? validateTaskTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Task title is required';
    }

    if (value.trim().length < 3) {
      return 'Task title must be at least 3 characters long';
    }

    if (value.trim().length > 100) {
      return 'Task title cannot exceed 100 characters';
    }

    return null;
  }

  // Task description validation
  static String? validateTaskDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Task description is required';
    }

    if (value.trim().length < 10) {
      return 'Task description must be at least 10 characters long';
    }

    if (value.trim().length > 1000) {
      return 'Task description cannot exceed 1000 characters';
    }

    return null;
  }

  // Category validation
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }

    return null;
  }

  // Priority validation
  static String? validatePriority(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a priority';
    }

    return null;
  }

  // Status validation
  static String? validateStatus(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a status';
    }

    return null;
  }

  // Team validation
  static String? validateTeam(String? value) {
    if (value == null || value.isEmpty) {
      return 'Team/Department is required';
    }

    if (value.trim().length < 2) {
      return 'Team/Department name must be at least 2 characters long';
    }

    return null;
  }

  // Role validation
  static String? validateRole(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a role';
    }

    const validRoles = ['Employee', 'Manager'];
    if (!validRoles.contains(value)) {
      return 'Invalid role selected';
    }

    return null;
  }

  // URL validation (for image URLs)
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    try {
      final uri = Uri.parse(value);
      if (!uri.isAbsolute || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return 'Please enter a valid URL';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Manager notes validation
  static String? validateManagerNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Manager notes are optional
    }

    if (value.trim().length > 500) {
      return 'Manager notes cannot exceed 500 characters';
    }

    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Please select a date';
    }

    final now = DateTime.now();
    if (value.isBefore(DateTime(now.year - 1))) {
      return 'Date cannot be more than 1 year ago';
    }

    if (value.isAfter(DateTime(now.year + 1))) {
      return 'Date cannot be more than 1 year in the future';
    }

    return null;
  }

  // Custom validation with regex
  static String? validateWithRegex(
    String? value,
    String pattern,
    String errorMessage,
  ) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!RegExp(pattern).hasMatch(value)) {
      return errorMessage;
    }

    return null;
  }

  // Minimum length validation
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'Field'} must be at least $minLength characters long';
    }

    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return '${fieldName ?? 'Field'} cannot exceed $maxLength characters';
    }

    return null;
  }
}
