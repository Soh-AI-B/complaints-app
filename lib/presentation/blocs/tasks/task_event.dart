import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

// Load all tasks
class LoadAllTasks extends TaskEvent {
  final int? limit;
  final String? lastTaskId;

  const LoadAllTasks({this.limit, this.lastTaskId});

  @override
  List<Object?> get props => [limit, lastTaskId];
}

// Load tasks by user
class LoadTasksByUser extends TaskEvent {
  final String employeeEmail;
  final int? limit;
  final String? lastTaskId;

  const LoadTasksByUser({
    required this.employeeEmail,
    this.limit,
    this.lastTaskId,
  });

  @override
  List<Object?> get props => [employeeEmail, limit, lastTaskId];
}

// Load tasks for manager (filtered by managed categories)
class LoadTasksForManager extends TaskEvent {
  final int? limit;
  final String? lastTaskId;

  const LoadTasksForManager({this.limit, this.lastTaskId});

  @override
  List<Object?> get props => [limit, lastTaskId];
}

// Load task by ID
class LoadTaskById extends TaskEvent {
  final String taskId;

  const LoadTaskById({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

// Create new task
class CreateTask extends TaskEvent {
  final String title;
  final String description;
  final String category;
  final String priority;
  final String employeeName;
  final String employeeEmail;
  final String? pictureUrl; // Keep for backward compatibility
  final List<String>? pictureUrls; // New field for multiple images
  final DateTime? estimatedCompletion;

  const CreateTask({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.employeeName,
    required this.employeeEmail,
    this.pictureUrl, // Keep for backward compatibility
    this.pictureUrls, // New field for multiple images
    this.estimatedCompletion,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    category,
    priority,
    employeeName,
    employeeEmail,
    pictureUrl,
    pictureUrls,
    estimatedCompletion,
  ];
}

// Update task
class UpdateTask extends TaskEvent {
  final String taskId;
  final String? title;
  final String? description;
  final String? category;
  final String? priority;
  final String? status;
  final String? assignedTo;
  final DateTime? estimatedCompletion;
  final String? pictureUrl; // Keep for backward compatibility
  final List<String>? pictureUrls; // New field for multiple images

  const UpdateTask({
    required this.taskId,
    this.title,
    this.description,
    this.category,
    this.priority,
    this.status,
    this.assignedTo,
    this.estimatedCompletion,
    this.pictureUrl, // Keep for backward compatibility
    this.pictureUrls, // New field for multiple images
  });

  @override
  List<Object?> get props => [
    taskId,
    title,
    description,
    category,
    priority,
    status,
    assignedTo,
    estimatedCompletion,
    pictureUrl,
    pictureUrls,
  ];
}

// Delete task
class DeleteTask extends TaskEvent {
  final String taskId;
  final String userRole; // Add user role for authorization

  const DeleteTask({required this.taskId, required this.userRole});

  @override
  List<Object?> get props => [taskId, userRole];
}

// Auto cleanup completed tasks
class AutoCleanupCompletedTasks extends TaskEvent {
  final int? completedTasksRetentionDays;
  final int? cancelledTasksRetentionDays;

  const AutoCleanupCompletedTasks({
    this.completedTasksRetentionDays,
    this.cancelledTasksRetentionDays,
  });

  @override
  List<Object?> get props => [
    completedTasksRetentionDays,
    cancelledTasksRetentionDays,
  ];
}

// Load tasks by status
class LoadTasksByStatus extends TaskEvent {
  final String status;
  final int? limit;
  final String? lastTaskId;

  const LoadTasksByStatus({required this.status, this.limit, this.lastTaskId});

  @override
  List<Object?> get props => [status, limit, lastTaskId];
}

// Load tasks by priority
class LoadTasksByPriority extends TaskEvent {
  final String priority;
  final int? limit;
  final String? lastTaskId;

  const LoadTasksByPriority({
    required this.priority,
    this.limit,
    this.lastTaskId,
  });

  @override
  List<Object?> get props => [priority, limit, lastTaskId];
}

// Load tasks by category
class LoadTasksByCategory extends TaskEvent {
  final String category;
  final int? limit;
  final String? lastTaskId;

  const LoadTasksByCategory({
    required this.category,
    this.limit,
    this.lastTaskId,
  });

  @override
  List<Object?> get props => [category, limit, lastTaskId];
}

// Assign task
class AssignTask extends TaskEvent {
  final String taskId;
  final String assigneeId;

  const AssignTask({required this.taskId, required this.assigneeId});

  @override
  List<Object?> get props => [taskId, assigneeId];
}

// Filter tasks
class FilterTasks extends TaskEvent {
  final String? status;
  final String? priority;
  final String? category;
  final String? assigneeId;

  const FilterTasks({
    this.status,
    this.priority,
    this.category,
    this.assigneeId,
  });

  @override
  List<Object?> get props => [status, priority, category, assigneeId];
}

// Search tasks
class SearchTasks extends TaskEvent {
  final String query;

  const SearchTasks({required this.query});

  @override
  List<Object?> get props => [query];
}

// Clear search
class ClearTaskSearch extends TaskEvent {
  const ClearTaskSearch();
}

// Refresh tasks
class RefreshTasks extends TaskEvent {
  const RefreshTasks();
}
