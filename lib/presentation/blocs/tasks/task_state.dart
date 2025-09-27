import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart' as domain_task;

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TaskInitial extends TaskState {
  const TaskInitial();
}

// Loading state
class TaskLoading extends TaskState {
  const TaskLoading();
}

// Tasks loaded successfully
class TasksLoaded extends TaskState {
  final List<domain_task.Task> tasks;
  final bool hasMore;
  final String? lastTaskId;

  const TasksLoaded({
    required this.tasks,
    this.hasMore = false,
    this.lastTaskId,
  });

  @override
  List<Object?> get props => [tasks, hasMore, lastTaskId];
}

// Single task loaded
class TaskLoaded extends TaskState {
  final domain_task.Task task;

  const TaskLoaded({required this.task});

  @override
  List<Object?> get props => [task];
}

// Task created successfully
class TaskCreated extends TaskState {
  final domain_task.Task task;

  const TaskCreated({required this.task});

  @override
  List<Object?> get props => [task];
}

// Task updated successfully
class TaskUpdated extends TaskState {
  final domain_task.Task task;

  const TaskUpdated({required this.task});

  @override
  List<Object?> get props => [task];
}

// Task deleted successfully
class TaskDeleted extends TaskState {
  final String taskId;
  final String message;

  const TaskDeleted({
    required this.taskId,
    this.message = 'Task deleted successfully',
  });

  @override
  List<Object?> get props => [taskId, message];
}

// Auto cleanup completed
class TasksAutoCleanupCompleted extends TaskState {
  final int deletedTasksCount;
  final int deletedImagesCount;
  final List<String> errors;
  final DateTime completedAt;

  const TasksAutoCleanupCompleted({
    required this.deletedTasksCount,
    required this.deletedImagesCount,
    required this.errors,
    required this.completedAt,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccessful => deletedTasksCount > 0 && errors.isEmpty;

  @override
  List<Object?> get props => [
    deletedTasksCount,
    deletedImagesCount,
    errors,
    completedAt,
  ];
}

// Task assigned successfully
class TaskAssigned extends TaskState {
  final domain_task.Task task;

  const TaskAssigned({required this.task});

  @override
  List<Object?> get props => [task];
}

// Tasks filtered
class TasksFiltered extends TaskState {
  final List<domain_task.Task> tasks;
  final Map<String, String?> filters;

  const TasksFiltered({required this.tasks, required this.filters});

  @override
  List<Object?> get props => [tasks, filters];
}

// Tasks searched
class TasksSearched extends TaskState {
  final List<domain_task.Task> tasks;
  final String query;

  const TasksSearched({required this.tasks, required this.query});

  @override
  List<Object?> get props => [tasks, query];
}

// Error state
class TaskError extends TaskState {
  final String message;
  final String? errorCode;

  const TaskError({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

// Network error state
class TaskNetworkError extends TaskState {
  final String message;

  const TaskNetworkError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Cache error state
class TaskCacheError extends TaskState {
  final String message;

  const TaskCacheError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Loading more tasks
class TaskLoadingMore extends TaskState {
  final List<domain_task.Task> currentTasks;

  const TaskLoadingMore({required this.currentTasks});

  @override
  List<Object?> get props => [currentTasks];
}

// Refreshing tasks
class TaskRefreshing extends TaskState {
  final List<domain_task.Task> currentTasks;

  const TaskRefreshing({required this.currentTasks});

  @override
  List<Object?> get props => [currentTasks];
}
