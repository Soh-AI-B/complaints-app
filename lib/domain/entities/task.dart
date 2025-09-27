import 'package:equatable/equatable.dart';

// Class to represent a manager/admin note
class TaskNote extends Equatable {
  final String note;
  final String authorName;
  final String authorEmail;
  final DateTime createdAt;

  const TaskNote({
    required this.note,
    required this.authorName,
    required this.authorEmail,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [note, authorName, authorEmail, createdAt];

  @override
  String toString() {
    return 'TaskNote{note: $note, author: $authorName, createdAt: $createdAt}';
  }
}

class Task extends Equatable {
  final String taskId;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String employeeName;
  final String employeeEmail;
  final DateTime dateReported;
  final String? pictureUrl; // Keep for backward compatibility
  final List<String>? pictureUrls; // New field for multiple images
  final String status;
  final String? assignedTo;
  final DateTime dateUpdated;
  final DateTime? estimatedCompletion;

  const Task({
    required this.taskId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.employeeName,
    required this.employeeEmail,
    required this.dateReported,
    this.pictureUrl, // Keep for backward compatibility
    this.pictureUrls, // New field for multiple images
    required this.status,
    this.assignedTo,
    required this.dateUpdated,
    this.estimatedCompletion,
  });

  // Copy with method for creating modified copies
  Task copyWith({
    String? taskId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? employeeName,
    String? employeeEmail,
    DateTime? dateReported,
    String? pictureUrl,
    List<String>? pictureUrls,
    String? status,
    String? assignedTo,
    DateTime? dateUpdated,
    DateTime? estimatedCompletion,
  }) {
    return Task(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      employeeName: employeeName ?? this.employeeName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      dateReported: dateReported ?? this.dateReported,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      pictureUrls: pictureUrls ?? this.pictureUrls,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
    );
  }

  // Check if task is overdue
  bool get isOverdue {
    if (estimatedCompletion == null || status == 'Completed') {
      return false;
    }
    return DateTime.now().isAfter(estimatedCompletion!);
  }

  // Check if task is urgent
  bool get isUrgent => priority == 'Urgent';

  // Check if task is completed
  bool get isCompleted => status == 'Completed';

  // Check if task is pending
  bool get isPending => status == 'Pending';

  // Check if task is in progress
  bool get isInProgress => status == 'In Progress';

  // Check if task is cancelled
  bool get isCancelled => status == 'Cancelled';

  // Get days since reported
  int get daysSinceReported {
    return DateTime.now().difference(dateReported).inDays;
  }

  // Get days until estimated completion
  int? get daysUntilCompletion {
    if (estimatedCompletion == null) return null;
    final difference = estimatedCompletion!.difference(DateTime.now());
    return difference.inDays;
  }

  // Check if task has image(s)
  bool get hasImage =>
      (pictureUrl != null && pictureUrl!.isNotEmpty) ||
      (pictureUrls != null && pictureUrls!.isNotEmpty);

  // Get all image URLs (combining both old and new formats)
  List<String> get allImageUrls {
    final List<String> urls = [];

    // Add single image URL if exists (backward compatibility)
    if (pictureUrl != null && pictureUrl!.isNotEmpty) {
      urls.add(pictureUrl!);
    }

    // Add multiple image URLs if exists
    if (pictureUrls != null) {
      urls.addAll(pictureUrls!);
    }

    return urls;
  }

  // Get number of images
  int get imageCount => allImageUrls.length;

  // Check if task is assigned
  bool get isAssigned => assignedTo != null && assignedTo!.isNotEmpty;

  @override
  List<Object?> get props => [
    taskId,
    title,
    description,
    category,
    priority,
    employeeName,
    employeeEmail,
    dateReported,
    pictureUrl,
    pictureUrls,
    status,
    assignedTo,
    dateUpdated,
    estimatedCompletion,
  ];

  @override
  String toString() {
    return 'Task{taskId: $taskId, title: $title, status: $status, priority: $priority, category: $category}';
  }
}
