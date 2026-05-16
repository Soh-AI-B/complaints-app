import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/task.dart' as entities;
import '../../domain/repositories/task_repository.dart';
import '../datasources/tasks/task_remote_datasource.dart';
import '../datasources/tasks/task_local_datasource.dart';
import '../models/task_model.dart';
import '../../core/network/network_info.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
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
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final now = DateTime.now();
        final taskModel = TaskModel(
          taskId: now.millisecondsSinceEpoch.toString(),
          title: title,
          description: description,
          category: category,
          priority: priority,
          employeeName: employeeName,
          employeeEmail: employeeEmail,
          dateReported: now,
          pictureUrl: pictureUrl, // Keep for backward compatibility
          pictureUrls: pictureUrls, // New field for multiple images
          status: 'Pending',
          dateUpdated: now,
          estimatedCompletion: estimatedCompletion,
        );

        final createdTask = await remoteDataSource.createTask(taskModel);
        await localDataSource.cacheTask(createdTask);
        return Right(createdTask.toEntity());
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<entities.Task>>> getAllTasks({
    int? limit,
    String? lastTaskId,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final tasks = await remoteDataSource.getAllTasks();
        await localDataSource.cacheTasks(tasks);

        var result = tasks.map((task) => task.toEntity()).toList();
        if (limit != null) {
          result = result.take(limit).toList();
        }

        return Right(result);
      } else {
        final cachedTasks = await localDataSource.getCachedTasks();
        var result = cachedTasks.map((task) => task.toEntity()).toList();
        if (limit != null) {
          result = result.take(limit).toList();
        }
        return Right(result);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<entities.Task>>> getTasksForManager({
    required List<String> managedCategories,
    int? limit,
    String? lastTaskId,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final allTasks = await remoteDataSource.getAllTasks();

        // Filter tasks by managed categories
        final filteredTasks = allTasks
            .where((task) => managedCategories.contains(task.category))
            .toList();

        await localDataSource.cacheTasks(filteredTasks);

        var result = filteredTasks.map((task) => task.toEntity()).toList();
        if (limit != null) {
          result = result.take(limit).toList();
        }

        return Right(result);
      } else {
        final cachedTasks = await localDataSource.getCachedTasks();

        // Filter cached tasks by managed categories
        final filteredTasks = cachedTasks
            .where((task) => managedCategories.contains(task.category))
            .toList();

        var result = filteredTasks.map((task) => task.toEntity()).toList();
        if (limit != null) {
          result = result.take(limit).toList();
        }
        return Right(result);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<entities.Task>>> getTasksByUser({
    required String employeeEmail,
    int? limit,
    String? lastTaskId,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final tasks = await remoteDataSource.getTasksByUser(employeeEmail);
        await localDataSource.cacheTasks(tasks);

        var result = tasks.map((task) => task.toEntity()).toList();
        if (limit != null) {
          result = result.take(limit).toList();
        }

        return Right(result);
      } else {
        final cachedTasks = await localDataSource.getCachedTasks();
        var result = cachedTasks
            .where((task) => task.employeeEmail == employeeEmail)
            .map((task) => task.toEntity())
            .toList();
        if (limit != null) {
          result = result.take(limit).toList();
        }
        return Right(result);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, entities.Task>> getTaskById(String taskId) async {
    try {
      if (await networkInfo.isConnected) {
        final task = await remoteDataSource.getTaskById(taskId);
        await localDataSource.cacheTask(task);
        return Right(task.toEntity());
      } else {
        final cachedTask = await localDataSource.getCachedTask(taskId);
        if (cachedTask != null) {
          return Right(cachedTask.toEntity());
        } else {
          return const Left(CacheFailure(message: 'Task not found in cache'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
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
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final updates = <String, dynamic>{};
        if (title != null) updates['title'] = title;
        if (description != null) updates['description'] = description;
        if (category != null) updates['category'] = category;
        if (priority != null) updates['priority'] = priority;
        if (status != null) updates['status'] = status;
        if (assignedTo != null) updates['assignedTo'] = assignedTo;
        if (estimatedCompletion != null) {
          updates['estimatedCompletion'] = estimatedCompletion;
        }
        if (pictureUrl != null) {
          updates['pictureUrl'] = pictureUrl; // Keep for backward compatibility
        }
        if (pictureUrls != null) {
          updates['pictureUrls'] = pictureUrls; // New field for multiple images
        }
        updates['dateUpdated'] = DateTime.now();

        final taskModel = await remoteDataSource.updateTask(taskId, updates);
        await localDataSource.cacheTask(taskModel);
        return Right(taskModel.toEntity());
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteTask(taskId);
        await localDataSource.removeCachedTask(taskId);
        return const Right(null);
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<entities.Task>>> getTasksByStatus({
    required String status,
    int? limit,
    String? lastTaskId,
  }) async {
    return getAllTasks(limit: limit, lastTaskId: lastTaskId);
  }

  @override
  Future<Either<Failure, List<entities.Task>>> getTasksByPriority({
    required String priority,
    int? limit,
    String? lastTaskId,
  }) async {
    return getAllTasks(limit: limit, lastTaskId: lastTaskId);
  }

  @override
  Future<Either<Failure, List<entities.Task>>> getTasksByCategory({
    required String category,
    int? limit,
    String? lastTaskId,
  }) async {
    return getAllTasks(limit: limit, lastTaskId: lastTaskId);
  }

  @override
  Future<Either<Failure, List<entities.Task>>> getTasksByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
    String? lastTaskId,
  }) async {
    return getAllTasks(limit: limit, lastTaskId: lastTaskId);
  }

  @override
  Future<Either<Failure, List<entities.Task>>> searchTasks({
    required String query,
    int? limit,
    String? lastTaskId,
  }) async {
    return getAllTasks(limit: limit, lastTaskId: lastTaskId);
  }

  @override
  Future<Either<Failure, Map<String, int>>> getTaskStatistics({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return const Right({});
  }

  @override
  Future<Either<Failure, Map<String, int>>> getTasksCountByStatus({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return const Right({});
  }

  @override
  Future<Either<Failure, Map<String, int>>> getTasksCountByPriority({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return const Right({});
  }

  @override
  Future<Either<Failure, Map<String, int>>> getTasksCountByCategory({
    String? employeeEmail,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return const Right({});
  }

  @override
  Future<Either<Failure, List<entities.Task>>> getOverdueTasks({
    String? employeeEmail,
    int? limit,
    String? lastTaskId,
  }) async {
    return getAllTasks(limit: limit, lastTaskId: lastTaskId);
  }

  @override
  Future<Either<Failure, List<entities.Task>>> getUrgentTasks({
    String? employeeEmail,
    int? limit,
    String? lastTaskId,
  }) async {
    return getAllTasks(limit: limit, lastTaskId: lastTaskId);
  }

  @override
  Future<Either<Failure, List<entities.Task>>> getRecentTasks({
    String? employeeEmail,
    int? limit,
    String? lastTaskId,
  }) async {
    return getAllTasks(limit: limit, lastTaskId: lastTaskId);
  }

  @override
  Future<Either<Failure, List<entities.Task>>> getAssignedTasks({
    required String managerEmail,
    int? limit,
    String? lastTaskId,
  }) async {
    return getAllTasks(limit: limit, lastTaskId: lastTaskId);
  }

  @override
  Future<Either<Failure, entities.Task>> assignTask({
    required String taskId,
    required String assignedTo,
  }) async {
    return updateTask(taskId: taskId, assignedTo: assignedTo);
  }

  @override
  Future<Either<Failure, entities.Task>> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    return updateTask(taskId: taskId, status: status);
  }

  @override
  Future<Either<Failure, String>> uploadTaskImage({
    required String taskId,
    required String imagePath,
  }) async {
    return const Right('uploaded_image_url');
  }

  @override
  Future<Either<Failure, void>> deleteTaskImage({
    required String taskId,
    required String imageUrl,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteTaskImage(taskId, imageUrl);
        return const Right(null);
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Stream<Either<Failure, List<entities.Task>>> getTasksStream({
    String? employeeEmail,
    String? status,
    String? priority,
    String? category,
  }) {
    return Stream.value(const Right([]));
  }

  @override
  Stream<Either<Failure, entities.Task>> getTaskStreamById(String taskId) {
    return Stream.value(const Left(ServerFailure(message: 'Not implemented')));
  }

  @override
  Future<Either<Failure, List<entities.Task>>> bulkUpdateTasks({
    required List<String> taskIds,
    String? status,
    String? assignedTo,
    String? priority,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, String>> exportTasksToCSV({
    String? employeeEmail,
    String? status,
    String? priority,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return const Right('csv_file_path');
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDailyTaskSummary({
    required DateTime date,
    String? employeeEmail,
  }) async {
    return const Right({});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWeeklyTaskSummary({
    required DateTime weekStartDate,
    String? employeeEmail,
  }) async {
    return const Right({});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMonthlyTaskSummary({
    required DateTime month,
    String? employeeEmail,
  }) async {
    return const Right({});
  }
}
