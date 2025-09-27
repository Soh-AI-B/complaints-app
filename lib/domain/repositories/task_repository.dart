import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/task.dart' as entities;

abstract class TaskRepository {
  // Create a new task
  Future<Either<Failure, entities.Task>> createTask({
    required String title,
    required String description,
    required String category,
    required String priority,
    required String employeeName,
    required String employeeEmail,
    String? pictureUrl, // Keep for backward compatibility
    List<String>? pictureUrls, // New field for multiple images
    DateTime? estimatedCompletion,
  });

  // Get all tasks
  Future<Either<Failure, List<entities.Task>>> getAllTasks({
    int? limit,
    String? lastTaskId,
  });

  // Get tasks for manager (filtered by managed categories)
  Future<Either<Failure, List<entities.Task>>> getTasksForManager({
    required List<String> managedCategories,
    int? limit,
    String? lastTaskId,
  });

  // Get tasks by user (employee's own tasks)
  Future<Either<Failure, List<entities.Task>>> getTasksByUser({
    required String employeeEmail,
    int? limit,
    String? lastTaskId,
  });

  // Get task by ID
  Future<Either<Failure, entities.Task>> getTaskById(String taskId);

  // Update task
  Future<Either<Failure, entities.Task>> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? assignedTo,
    DateTime? estimatedCompletion,
    String? pictureUrl, // Keep for backward compatibility
    List<String>? pictureUrls, // New field for multiple images
  });

  // Delete task
  Future<Either<Failure, void>> deleteTask(String taskId);

  // Get tasks by status
  Future<Either<Failure, List<entities.Task>>> getTasksByStatus({
    required String status,
    int? limit,
    String? lastTaskId,
  });

  // Get tasks by priority
  Future<Either<Failure, List<entities.Task>>> getTasksByPriority({
    required String priority,
    int? limit,
    String? lastTaskId,
  });

  // Get tasks by category
  Future<Either<Failure, List<entities.Task>>> getTasksByCategory({
    required String category,
    int? limit,
    String? lastTaskId,
  });

  // Get tasks by date range
  Future<Either<Failure, List<entities.Task>>> getTasksByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
    String? lastTaskId,
  });

  // Search tasks
  Future<Either<Failure, List<entities.Task>>> searchTasks({
    required String query,
    int? limit,
    String? lastTaskId,
  });

  // Get task statistics
  Future<Either<Failure, Map<String, int>>> getTaskStatistics({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Get tasks count by status
  Future<Either<Failure, Map<String, int>>> getTasksCountByStatus({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Get tasks count by priority
  Future<Either<Failure, Map<String, int>>> getTasksCountByPriority({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Get tasks count by category
  Future<Either<Failure, Map<String, int>>> getTasksCountByCategory({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Get overdue tasks
  Future<Either<Failure, List<entities.Task>>> getOverdueTasks({
    String? employeeEmail,
    int? limit,
    String? lastTaskId,
  });

  // Get urgent tasks
  Future<Either<Failure, List<entities.Task>>> getUrgentTasks({
    String? employeeEmail,
    int? limit,
    String? lastTaskId,
  });

  // Get recent tasks
  Future<Either<Failure, List<entities.Task>>> getRecentTasks({
    String? employeeEmail,
    int? limit,
    String? lastTaskId,
  });

  // Get tasks assigned to manager
  Future<Either<Failure, List<entities.Task>>> getAssignedTasks({
    required String managerEmail,
    int? limit,
    String? lastTaskId,
  });

  // Assign task to manager
  Future<Either<Failure, entities.Task>> assignTask({
    required String taskId,
    required String assignedTo,
  });

  // Update task status
  Future<Either<Failure, entities.Task>> updateTaskStatus({
    required String taskId,
    required String status,
  });

  // Upload task image
  Future<Either<Failure, String>> uploadTaskImage({
    required String taskId,
    required String imagePath,
  });

  // Delete task image
  Future<Either<Failure, void>> deleteTaskImage({
    required String taskId,
    required String imageUrl,
  });

  // Get tasks stream for real-time updates
  Stream<Either<Failure, List<entities.Task>>> getTasksStream({
    String? employeeEmail,
    String? status,
    String? priority,
    String? category,
  });

  // Get task stream by ID for real-time updates
  Stream<Either<Failure, entities.Task>> getTaskStreamById(String taskId);

  // Bulk update tasks
  Future<Either<Failure, List<entities.Task>>> bulkUpdateTasks({
    required List<String> taskIds,
    String? status,
    String? assignedTo,
    String? priority,
  });

  // Export tasks to CSV
  Future<Either<Failure, String>> exportTasksToCSV({
    String? employeeEmail,
    String? status,
    String? priority,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Get daily task summary
  Future<Either<Failure, Map<String, dynamic>>> getDailyTaskSummary({
    required DateTime date,
    String? employeeEmail,
  });

  // Get weekly task summary
  Future<Either<Failure, Map<String, dynamic>>> getWeeklyTaskSummary({
    required DateTime weekStartDate,
    String? employeeEmail,
  });

  // Get monthly task summary
  Future<Either<Failure, Map<String, dynamic>>> getMonthlyTaskSummary({
    required DateTime month,
    String? employeeEmail,
  });
}
