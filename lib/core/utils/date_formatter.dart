import 'package:intl/intl.dart';

class DateFormatter {
  // Standard date format (yyyy-MM-dd)
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Standard datetime format (yyyy-MM-dd HH:mm:ss)
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  // Display date format (MMM dd, yyyy)
  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');

  // Display datetime format (MMM dd, yyyy HH:mm)
  static final DateFormat _displayDateTimeFormat = DateFormat(
    'MMM dd, yyyy HH:mm',
  );

  // Time format (HH:mm)
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  // Month year format (MMM yyyy)
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');

  // Day month format (dd MMM)
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM');

  // Format date for storage (yyyy-MM-dd)
  static String formatDateForStorage(DateTime date) {
    return _dateFormat.format(date);
  }

  // Format datetime for storage (yyyy-MM-dd HH:mm:ss)
  static String formatDateTimeForStorage(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  // Format date for display (MMM dd, yyyy)
  static String formatDateForDisplay(DateTime date) {
    return _displayDateFormat.format(date);
  }

  // Format datetime for display (MMM dd, yyyy HH:mm)
  static String formatDateTimeForDisplay(DateTime dateTime) {
    return _displayDateTimeFormat.format(dateTime);
  }

  // Format time for display (HH:mm)
  static String formatTimeForDisplay(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  // Format month and year (MMM yyyy)
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  // Format day and month (dd MMM)
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  // Parse date from string (yyyy-MM-dd)
  static DateTime? parseDateFromString(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      return _dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Parse datetime from string (yyyy-MM-dd HH:mm:ss)
  static DateTime? parseDateTimeFromString(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return null;
    }

    try {
      return _dateTimeFormat.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  // Get relative time (e.g., "2 hours ago", "3 days ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return '1 day ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return months == 1 ? '1 month ago' : '$months months ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return years == 1 ? '1 year ago' : '$years years ago';
      }
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Check if date is this year
  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  // Get smart date format (Today, Yesterday, or date)
  static String getSmartDateFormat(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else if (isThisWeek(date)) {
      return DateFormat('EEEE').format(date); // Day name
    } else if (isThisYear(date)) {
      return formatDayMonth(date);
    } else {
      return formatDateForDisplay(date);
    }
  }

  // Get smart datetime format with time
  static String getSmartDateTimeFormat(DateTime dateTime) {
    final dateFormat = getSmartDateFormat(dateTime);
    final timeFormat = formatTimeForDisplay(dateTime);

    if (dateFormat == 'Today' || dateFormat == 'Yesterday') {
      return '$dateFormat at $timeFormat';
    } else {
      return '$dateFormat, $timeFormat';
    }
  }

  // Get age from date
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // Get days until date
  static int getDaysUntil(DateTime futureDate) {
    final now = DateTime.now();
    final difference = futureDate.difference(now);
    return difference.inDays;
  }

  // Get start of day
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get start of week
  static DateTime getStartOfWeek(DateTime date) {
    final startOfDay = getStartOfDay(date);
    return startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
  }

  // Get end of week
  static DateTime getEndOfWeek(DateTime date) {
    final startOfWeek = getStartOfWeek(date);
    return getEndOfDay(startOfWeek.add(const Duration(days: 6)));
  }

  // Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime getEndOfMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return getEndOfDay(nextMonth.subtract(const Duration(days: 1)));
  }
}
