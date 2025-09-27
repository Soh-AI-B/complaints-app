import 'dart:convert';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/shared_preferences_helper.dart';
import '../../models/task_model.dart';

abstract class TaskLocalDataSource {
  /// Gets cached tasks
  Future<List<TaskModel>> getCachedTasks();

  /// Caches tasks locally
  Future<void> cacheTasks(List<TaskModel> tasks);

  /// Gets a cached task by ID
  Future<TaskModel> getCachedTaskById(String taskId);

  /// Gets a cached task by ID (nullable)
  Future<TaskModel?> getCachedTask(String taskId);

  /// Caches a single task
  Future<void> cacheTask(TaskModel task);

  /// Removes a cached task
  Future<void> removeCachedTask(String taskId);

  /// Removes cached tasks
  Future<void> clearCache();

  /// Checks if tasks are cached
  Future<bool> hasTasksCached();

  /// Gets cached tasks by status
  Future<List<TaskModel>> getCachedTasksByStatus(String status);

  /// Gets cached tasks by assignee
  Future<List<TaskModel>> getCachedTasksByAssignee(String assigneeId);

  /// Gets cached tasks by creator
  Future<List<TaskModel>> getCachedTasksByCreator(String creatorId);

  /// Gets cached tasks by user email
  Future<List<TaskModel>> getCachedTasksByUser(String employeeEmail);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  const TaskLocalDataSourceImpl();

  static const String _tasksKey = 'cached_tasks';
  static const String _taskPrefix = 'cached_task_';

  @override
  Future<List<TaskModel>> getCachedTasks() async {
    try {
      final tasksJson = SharedPreferencesHelper.getString(_tasksKey);
      if (tasksJson == null) {
        throw const CacheException(message: 'No cached tasks found');
      }

      final tasksList = json.decode(tasksJson) as List<dynamic>;
      return tasksList
          .map(
            (taskJson) => TaskModel.fromJson(taskJson as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached tasks: $e');
    }
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    try {
      final tasksJson = json.encode(
        tasks.map((task) => task.toJson()).toList(),
      );
      await SharedPreferencesHelper.setString(_tasksKey, tasksJson);
    } catch (e) {
      throw CacheException(message: 'Failed to cache tasks: $e');
    }
  }

  @override
  Future<TaskModel> getCachedTaskById(String taskId) async {
    try {
      final taskJson = SharedPreferencesHelper.getString('$_taskPrefix$taskId');
      if (taskJson == null) {
        throw const CacheException(message: 'Task not found in cache');
      }

      final taskMap = json.decode(taskJson) as Map<String, dynamic>;
      return TaskModel.fromJson(taskMap);
    } catch (e) {
      throw CacheException(message: 'Failed to get cached task: $e');
    }
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    try {
      final taskJson = json.encode(task.toJson());
      await SharedPreferencesHelper.setString(
        '$_taskPrefix${task.taskId}',
        taskJson,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache task: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await SharedPreferencesHelper.remove(_tasksKey);
      // Note: Individual task cache cleanup would require more sophisticated key management
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  @override
  Future<bool> hasTasksCached() async {
    try {
      final tasksJson = SharedPreferencesHelper.getString(_tasksKey);
      return tasksJson != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<TaskModel>> getCachedTasksByStatus(String status) async {
    try {
      final allTasks = await getCachedTasks();
      return allTasks.where((task) => task.status == status).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached tasks by status: $e');
    }
  }

  @override
  Future<List<TaskModel>> getCachedTasksByAssignee(String assigneeId) async {
    try {
      final allTasks = await getCachedTasks();
      return allTasks.where((task) => task.assignedTo == assigneeId).toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get cached tasks by assignee: $e',
      );
    }
  }

  @override
  Future<TaskModel?> getCachedTask(String taskId) async {
    try {
      final taskJson = SharedPreferencesHelper.getString('$_taskPrefix$taskId');
      if (taskJson == null) {
        return null;
      }

      final taskMap = json.decode(taskJson) as Map<String, dynamic>;
      return TaskModel.fromJson(taskMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> removeCachedTask(String taskId) async {
    try {
      await SharedPreferencesHelper.remove('$_taskPrefix$taskId');
    } catch (e) {
      throw CacheException(message: 'Failed to remove cached task: $e');
    }
  }

  @override
  Future<List<TaskModel>> getCachedTasksByUser(String employeeEmail) async {
    try {
      final allTasks = await getCachedTasks();
      return allTasks
          .where((task) => task.employeeEmail == employeeEmail)
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached tasks by user: $e');
    }
  }

  @override
  Future<List<TaskModel>> getCachedTasksByCreator(String creatorId) async {
    try {
      final allTasks = await getCachedTasks();
      return allTasks.where((task) => task.employeeEmail == creatorId).toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get cached tasks by creator: $e',
      );
    }
  }
}
