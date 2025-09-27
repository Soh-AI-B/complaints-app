import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF253b74);
  static const Color secondary = Color(0xFF91be3f);
  static const Color subColor = Color(0xFF1b75bc);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Priority Colors
  static const Color priorityUrgent = Color(
    0xFFE53935,
  ); // Brighter, stronger red
  static const Color priorityHigh = Color(0xFFFFA726); // Vibrant orange
  static const Color priorityNormal = Color(0xFFFBC02D); // Clearer yellow/gold
  static const Color priorityLow = Color(0xFF43A047); // Fresher green

  // Status Colors
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusInProgress = Color(0xFF2196F3);
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFF757575);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textLight = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE0E0E0);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, subColor],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFF7CB342)],
  );

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // Chart Colors
  static const List<Color> chartColors = [
    primary,
    secondary,
    subColor,
    success,
    warning,
    error,
    info,
    Color(0xFF9C27B0),
    Color(0xFF607D8B),
    Color(0xFF795548),
  ];

  // Get color by priority
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return priorityUrgent;
      case 'high':
        return priorityHigh;
      case 'normal':
        return priorityNormal;
      case 'low':
        return priorityLow;
      default:
        return priorityNormal;
    }
  }

  // Get color by status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'in progress':
        return statusInProgress;
      case 'completed':
        return statusCompleted;
      case 'cancelled':
        return statusCancelled;
      default:
        return statusPending;
    }
  }
}
