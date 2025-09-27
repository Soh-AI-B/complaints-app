import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../core/error/exceptions.dart';
import '../../models/task_model.dart';

abstract class TaskRemoteDataSource {
  /// Gets all tasks
  Future<List<TaskModel>> getAllTasks();

  /// Gets tasks assigned to a specific user
  Future<List<TaskModel>> getTasksByAssignee(String assigneeId);

  /// Gets tasks created by a specific user
  Future<List<TaskModel>> getTasksByCreator(String creatorId);

  /// Gets tasks by user email
  Future<List<TaskModel>> getTasksByUser(String employeeEmail);

  /// Gets a specific task by ID
  Future<TaskModel> getTaskById(String taskId);

  /// Creates a new task
  Future<TaskModel> createTask(TaskModel task);

  /// Updates an existing task
  Future<TaskModel> updateTask(String taskId, Map<String, dynamic> updates);

  /// Deletes a task
  Future<void> deleteTask(String taskId);

  /// Gets tasks by status
  Future<List<TaskModel>> getTasksByStatus(String status);

  /// Gets tasks by priority
  Future<List<TaskModel>> getTasksByPriority(String priority);

  /// Gets tasks by category
  Future<List<TaskModel>> getTasksByCategory(String category);

  /// Gets tasks by date range
  Future<List<TaskModel>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Search tasks
  Future<List<TaskModel>> searchTasks(String query);

  /// Get task statistics
  Future<Map<String, int>> getTaskStatistics({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get tasks count by status
  Future<Map<String, int>> getTasksCountByStatus({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get tasks count by priority
  Future<Map<String, int>> getTasksCountByPriority({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get tasks count by category
  Future<Map<String, int>> getTasksCountByCategory({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get overdue tasks
  Future<List<TaskModel>> getOverdueTasks(String? employeeEmail);

  /// Get urgent tasks
  Future<List<TaskModel>> getUrgentTasks(String? employeeEmail);

  /// Get recent tasks
  Future<List<TaskModel>> getRecentTasks(String? employeeEmail);

  /// Get assigned tasks
  Future<List<TaskModel>> getAssignedTasks(String managerEmail);

  /// Upload task image
  Future<String> uploadTaskImage(String taskId, String imagePath);

  /// Delete task image
  Future<void> deleteTaskImage(String taskId, String imageUrl);

  /// Get tasks stream
  Stream<List<TaskModel>> getTasksStream({
    String? employeeEmail,
    String? status,
    String? priority,
    String? category,
  });

  /// Get task stream by ID
  Stream<TaskModel> getTaskStreamById(String taskId);

  /// Bulk update tasks
  Future<List<TaskModel>> bulkUpdateTasks(
    List<String> taskIds,
    Map<String, dynamic> updates,
  );

  /// Export tasks to CSV
  Future<String> exportTasksToCSV({
    String? employeeEmail,
    String? status,
    String? priority,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get daily task summary
  Future<Map<String, dynamic>> getDailyTaskSummary(
    DateTime date,
    String? employeeEmail,
  );

  /// Get weekly task summary
  Future<Map<String, dynamic>> getWeeklyTaskSummary(
    DateTime weekStartDate,
    String? employeeEmail,
  );

  /// Get monthly task summary
  Future<Map<String, dynamic>> getMonthlyTaskSummary(
    DateTime month,
    String? employeeEmail,
  );
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  const TaskRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final snapshot = await firestore.collection('tasks').get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get all tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByAssignee(String assigneeId) async {
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where('assigned_to', isEqualTo: assigneeId)
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get tasks by assignee: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByCreator(String creatorId) async {
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where('created_by', isEqualTo: creatorId)
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get tasks by creator: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByUser(String employeeEmail) async {
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where('employee_email', isEqualTo: employeeEmail)
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get tasks by user: $e');
    }
  }

  @override
  Future<TaskModel> getTaskById(String taskId) async {
    try {
      final doc = await firestore.collection('tasks').doc(taskId).get();
      if (!doc.exists) {
        throw const ServerException(message: 'Task not found');
      }
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to get task: $e');
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final docRef = await firestore
          .collection('tasks')
          .add(task.toFirestore());
      final doc = await docRef.get();
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to create task: $e');
    }
  }

  @override
  Future<TaskModel> updateTask(
    String taskId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = FieldValue.serverTimestamp();
      await firestore.collection('tasks').doc(taskId).update(updates);

      final doc = await firestore.collection('tasks').doc(taskId).get();
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete task: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(String status) async {
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where('status', isEqualTo: status)
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get tasks by status: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByPriority(String priority) async {
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where('priority', isEqualTo: priority)
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get tasks by priority: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByCategory(String category) async {
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get tasks by category: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where(
            'date_reported',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where(
            'date_reported',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          )
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get tasks by date range: $e');
    }
  }

  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search tasks: $e');
    }
  }

  @override
  Future<Map<String, int>> getTaskStatistics({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = firestore.collection('tasks');

      if (employeeEmail != null) {
        query = query.where('employee_email', isEqualTo: employeeEmail);
      }
      if (startDate != null) {
        query = query.where(
          'date_reported',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'date_reported',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.get();
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();

      return {
        'total': tasks.length,
        'pending': tasks.where((task) => task.status == 'Pending').length,
        'inProgress': tasks
            .where((task) => task.status == 'In Progress')
            .length,
        'completed': tasks.where((task) => task.status == 'Completed').length,
        'rejected': tasks.where((task) => task.status == 'Rejected').length,
      };
    } catch (e) {
      throw ServerException(message: 'Failed to get task statistics: $e');
    }
  }

  @override
  Future<Map<String, int>> getTasksCountByStatus({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = firestore.collection('tasks');

      if (employeeEmail != null) {
        query = query.where('employee_email', isEqualTo: employeeEmail);
      }
      if (startDate != null) {
        query = query.where(
          'date_reported',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'date_reported',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.get();
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();

      final Map<String, int> statusCount = {};
      for (final task in tasks) {
        statusCount[task.status] = (statusCount[task.status] ?? 0) + 1;
      }

      return statusCount;
    } catch (e) {
      throw ServerException(message: 'Failed to get tasks count by status: $e');
    }
  }

  @override
  Future<Map<String, int>> getTasksCountByPriority({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = firestore.collection('tasks');

      if (employeeEmail != null) {
        query = query.where('employee_email', isEqualTo: employeeEmail);
      }
      if (startDate != null) {
        query = query.where(
          'date_reported',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'date_reported',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.get();
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();

      final Map<String, int> priorityCount = {};
      for (final task in tasks) {
        priorityCount[task.priority] = (priorityCount[task.priority] ?? 0) + 1;
      }

      return priorityCount;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tasks count by priority: $e',
      );
    }
  }

  @override
  Future<Map<String, int>> getTasksCountByCategory({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = firestore.collection('tasks');

      if (employeeEmail != null) {
        query = query.where('employee_email', isEqualTo: employeeEmail);
      }
      if (startDate != null) {
        query = query.where(
          'date_reported',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'date_reported',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.get();
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();

      final Map<String, int> categoryCount = {};
      for (final task in tasks) {
        categoryCount[task.category] = (categoryCount[task.category] ?? 0) + 1;
      }

      return categoryCount;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tasks count by category: $e',
      );
    }
  }

  @override
  Future<List<TaskModel>> getOverdueTasks(String? employeeEmail) async {
    try {
      Query query = firestore
          .collection('tasks')
          .where('estimated_completion', isLessThan: Timestamp.now())
          .where('status', whereIn: ['Pending', 'In Progress']);

      if (employeeEmail != null) {
        query = query.where('employee_email', isEqualTo: employeeEmail);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get overdue tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getUrgentTasks(String? employeeEmail) async {
    try {
      Query query = firestore
          .collection('tasks')
          .where('priority', isEqualTo: 'Urgent')
          .where('status', whereIn: ['Pending', 'In Progress']);

      if (employeeEmail != null) {
        query = query.where('employee_email', isEqualTo: employeeEmail);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get urgent tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getRecentTasks(String? employeeEmail) async {
    try {
      Query query = firestore
          .collection('tasks')
          .orderBy('date_reported', descending: true)
          .limit(20);

      if (employeeEmail != null) {
        query = query.where('employee_email', isEqualTo: employeeEmail);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get recent tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getAssignedTasks(String managerEmail) async {
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where('assigned_to', isEqualTo: managerEmail)
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get assigned tasks: $e');
    }
  }

  @override
  Future<String> uploadTaskImage(String taskId, String imagePath) async {
    try {
      final file = File(imagePath);
      final ref = storage.ref().child('task_images').child('$taskId.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw ServerException(message: 'Failed to upload task image: $e');
    }
  }

  @override
  Future<void> deleteTaskImage(String taskId, String imageUrl) async {
    try {
      print(
        '🖼️ TaskRemoteDataSource: Deleting image for task $taskId: $imageUrl',
      );

      if (imageUrl.contains('cloudinary.com')) {
        // For Cloudinary images, we rely on the CloudinaryService
        // The actual deletion is handled by the use case layer
        print(
          '🖼️ Cloudinary image detected - deletion handled by service layer',
        );
      } else {
        // For Firebase Storage images (legacy support)
        final ref = storage.refFromURL(imageUrl);
        await ref.delete();
        print('🖼️ Firebase Storage image deleted');
      }
    } catch (e) {
      print('🖼️ Error deleting image: $e');
      throw ServerException(message: 'Failed to delete task image: $e');
    }
  }

  @override
  Stream<List<TaskModel>> getTasksStream({
    String? employeeEmail,
    String? status,
    String? priority,
    String? category,
  }) {
    try {
      Query query = firestore.collection('tasks');

      if (employeeEmail != null) {
        query = query.where('employee_email', isEqualTo: employeeEmail);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      if (priority != null) {
        query = query.where('priority', isEqualTo: priority);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      return query.snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList(),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to get tasks stream: $e');
    }
  }

  @override
  Stream<TaskModel> getTaskStreamById(String taskId) {
    try {
      return firestore
          .collection('tasks')
          .doc(taskId)
          .snapshots()
          .map((doc) => TaskModel.fromFirestore(doc));
    } catch (e) {
      throw ServerException(message: 'Failed to get task stream: $e');
    }
  }

  @override
  Future<List<TaskModel>> bulkUpdateTasks(
    List<String> taskIds,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = FieldValue.serverTimestamp();
      final batch = firestore.batch();

      for (final taskId in taskIds) {
        final taskRef = firestore.collection('tasks').doc(taskId);
        batch.update(taskRef, updates);
      }

      await batch.commit();

      // Get updated tasks
      final updatedTasks = <TaskModel>[];
      for (final taskId in taskIds) {
        final doc = await firestore.collection('tasks').doc(taskId).get();
        if (doc.exists) {
          updatedTasks.add(TaskModel.fromFirestore(doc));
        }
      }

      return updatedTasks;
    } catch (e) {
      throw ServerException(message: 'Failed to bulk update tasks: $e');
    }
  }

  @override
  Future<String> exportTasksToCSV({
    String? employeeEmail,
    String? status,
    String? priority,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = firestore.collection('tasks');

      if (employeeEmail != null) {
        query = query.where('employee_email', isEqualTo: employeeEmail);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      if (priority != null) {
        query = query.where('priority', isEqualTo: priority);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (startDate != null) {
        query = query.where(
          'date_reported',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'date_reported',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.get();
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();

      // Create CSV content
      String csvContent =
          'ID,Title,Description,Category,Priority,Status,Employee Name,Employee Email,Date Reported,Date Updated\n';

      for (final task in tasks) {
        csvContent +=
            '${task.taskId},${task.title},${task.description},${task.category},${task.priority},${task.status},${task.employeeName},${task.employeeEmail},${task.dateReported},${task.dateUpdated}\n';
      }

      return csvContent;
    } catch (e) {
      throw ServerException(message: 'Failed to export tasks to CSV: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDailyTaskSummary(
    DateTime date,
    String? employeeEmail,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      Query query = firestore
          .collection('tasks')
          .where(
            'date_reported',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('date_reported', isLessThan: Timestamp.fromDate(endOfDay));

      if (employeeEmail != null) {
        query = query.where('employee_email', isEqualTo: employeeEmail);
      }

      final snapshot = await query.get();
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();

      return {
        'date': date.toIso8601String(),
        'total_tasks': tasks.length,
        'pending': tasks.where((task) => task.status == 'Pending').length,
        'in_progress': tasks
            .where((task) => task.status == 'In Progress')
            .length,
        'completed': tasks.where((task) => task.status == 'Completed').length,
        'rejected': tasks.where((task) => task.status == 'Rejected').length,
      };
    } catch (e) {
      throw ServerException(message: 'Failed to get daily task summary: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getWeeklyTaskSummary(
    DateTime weekStartDate,
    String? employeeEmail,
  ) async {
    try {
      final weekEndDate = weekStartDate.add(const Duration(days: 7));

      Query query = firestore
          .collection('tasks')
          .where(
            'date_reported',
            isGreaterThanOrEqualTo: Timestamp.fromDate(weekStartDate),
          )
          .where('date_reported', isLessThan: Timestamp.fromDate(weekEndDate));

      if (employeeEmail != null) {
        query = query.where('employee_email', isEqualTo: employeeEmail);
      }

      final snapshot = await query.get();
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();

      return {
        'week_start': weekStartDate.toIso8601String(),
        'week_end': weekEndDate.toIso8601String(),
        'total_tasks': tasks.length,
        'pending': tasks.where((task) => task.status == 'Pending').length,
        'in_progress': tasks
            .where((task) => task.status == 'In Progress')
            .length,
        'completed': tasks.where((task) => task.status == 'Completed').length,
        'rejected': tasks.where((task) => task.status == 'Rejected').length,
      };
    } catch (e) {
      throw ServerException(message: 'Failed to get weekly task summary: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getMonthlyTaskSummary(
    DateTime month,
    String? employeeEmail,
  ) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 1);

      Query query = firestore
          .collection('tasks')
          .where(
            'date_reported',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where('date_reported', isLessThan: Timestamp.fromDate(endOfMonth));

      if (employeeEmail != null) {
        query = query.where('employee_email', isEqualTo: employeeEmail);
      }

      final snapshot = await query.get();
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();

      return {
        'month': month.toIso8601String(),
        'total_tasks': tasks.length,
        'pending': tasks.where((task) => task.status == 'Pending').length,
        'in_progress': tasks
            .where((task) => task.status == 'In Progress')
            .length,
        'completed': tasks.where((task) => task.status == 'Completed').length,
        'rejected': tasks.where((task) => task.status == 'Rejected').length,
      };
    } catch (e) {
      throw ServerException(message: 'Failed to get monthly task summary: $e');
    }
  }
}
