import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/task.dart' as entities;
import '../../repositories/task_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../../core/services/cloudinary_service.dart';

/// Use case for automatically cleaning up completed tasks
/// Removes tasks that have been completed for a specified duration
/// Also cleans up associated images from Cloudinary and related notifications
class AutoCleanupCompletedTasksUseCase {
  final TaskRepository repository;
  final NotificationRepository notificationRepository;
  final CloudinaryService cloudinaryService;

  AutoCleanupCompletedTasksUseCase({
    required this.repository,
    required this.notificationRepository,
    required this.cloudinaryService,
  });

  /// Clean up completed tasks older than specified days
  /// Default: 30 days for completed tasks, 7 days for cancelled tasks
  Future<Either<Failure, CleanupResult>> call({
    int completedTasksRetentionDays = 2,
    int cancelledTasksRetentionDays = 1,
  }) async {
    developer.log(
      '🧹 AutoCleanupCompletedTasksUseCase: Starting cleanup process...',
    );
    developer.log(
      '🧹 Retention policy: Completed($completedTasksRetentionDays days), Cancelled($cancelledTasksRetentionDays days)',
    );

    try {
      final now = DateTime.now();
      final completedCutoffDate = now.subtract(
        Duration(days: completedTasksRetentionDays),
      );
      final cancelledCutoffDate = now.subtract(
        Duration(days: cancelledTasksRetentionDays),
      );

      developer.log(
        '🧹 Cutoff dates: Completed(${completedCutoffDate.toIso8601String()}), Cancelled(${cancelledCutoffDate.toIso8601String()})',
      );

      int deletedTasksCount = 0;
      int deletedImagesCount = 0;
      final List<String> errors = [];

      // Get completed tasks
      final completedTasksResult = await repository.getTasksByStatus(
        status: 'Completed',
      );
      await completedTasksResult.fold(
        (failure) {
          errors.add('Failed to get completed tasks: ${failure.message}');
        },
        (completedTasks) async {
          final tasksToDelete = completedTasks.where((task) {
            return task.dateUpdated.isBefore(completedCutoffDate);
          }).toList();

          developer.log(
            '🧹 Found ${tasksToDelete.length} completed tasks to delete',
          );

          for (final task in tasksToDelete) {
            final deleteResult = await _deleteTaskWithCleanup(task);
            if (deleteResult.success) {
              deletedTasksCount++;
              deletedImagesCount += deleteResult.deletedImagesCount;
            } else {
              errors.add(
                'Failed to delete task ${task.taskId}: ${deleteResult.error}',
              );
            }
          }
        },
      );

      // Get cancelled tasks
      final cancelledTasksResult = await repository.getTasksByStatus(
        status: 'Cancelled',
      );
      await cancelledTasksResult.fold(
        (failure) {
          errors.add('Failed to get cancelled tasks: ${failure.message}');
        },
        (cancelledTasks) async {
          final tasksToDelete = cancelledTasks.where((task) {
            return task.dateUpdated.isBefore(cancelledCutoffDate);
          }).toList();

          developer.log(
            '🧹 Found ${tasksToDelete.length} cancelled tasks to delete',
          );

          for (final task in tasksToDelete) {
            final deleteResult = await _deleteTaskWithCleanup(task);
            if (deleteResult.success) {
              deletedTasksCount++;
              deletedImagesCount += deleteResult.deletedImagesCount;
            } else {
              errors.add(
                'Failed to delete task ${task.taskId}: ${deleteResult.error}',
              );
            }
          }
        },
      );

      final result = CleanupResult(
        deletedTasksCount: deletedTasksCount,
        deletedImagesCount: deletedImagesCount,
        errors: errors,
        completedAt: now,
      );

      developer.log(
        '🧹 ✅ Cleanup completed: ${result.deletedTasksCount} tasks, ${result.deletedImagesCount} images deleted',
      );
      if (result.errors.isNotEmpty) {
        developer.log(
          '🧹 ⚠️ ${result.errors.length} errors occurred during cleanup',
        );
        for (final error in result.errors) {
          developer.log('🧹 ❌ $error');
        }
      }

      return Right(result);
    } catch (e) {
      developer.log('🧹 ❌ Unexpected error during cleanup: $e');
      return Left(ServerFailure(message: 'Auto-cleanup failed: $e'));
    }
  }

  /// Delete a single task and clean up its associated image
  Future<TaskDeleteResult> _deleteTaskWithCleanup(entities.Task task) async {
    try {
      developer.log('🧹 Deleting task: ${task.taskId} (${task.title})');

      // Delete the task from database
      final deleteResult = await repository.deleteTask(task.taskId);

      return await deleteResult.fold(
        (failure) async {
          return TaskDeleteResult(
            success: false,
            error: failure.message,
            imageDeleted: false,
          );
        },
        (_) async {
          int deletedImagesCount = 0;

          // Clean up related notifications
          developer.log(
            '🧹 🔔 Cleaning up notifications for task ${task.taskId}',
          );
          final notificationResult = await notificationRepository
              .deleteNotificationsByTaskId(task.taskId);
          notificationResult.fold(
            (failure) => developer.log(
              '🧹 ⚠️ Failed to delete notifications: ${failure.message}',
            ),
            (_) => developer.log('🧹 ✅ Notifications deleted successfully'),
          );

          // Clean up all associated images (both old and new format)
          final imageUrls = task.allImageUrls;
          if (imageUrls.isNotEmpty) {
            developer.log(
              '🧹 🖼️ Found ${imageUrls.length} images to clean up for task ${task.taskId}',
            );
            for (final imageUrl in imageUrls) {
              final deleted = await _cleanupTaskImage(imageUrl);
              if (deleted) deletedImagesCount++;
            }
          }

          return TaskDeleteResult(
            success: true,
            error: null,
            imageDeleted: deletedImagesCount > 0,
            deletedImagesCount: deletedImagesCount,
          );
        },
      );
    } catch (e) {
      return TaskDeleteResult(
        success: false,
        error: e.toString(),
        imageDeleted: false,
      );
    }
  }

  /// Clean up task image from Cloudinary storage
  Future<bool> _cleanupTaskImage(String imageUrl) async {
    try {
      developer.log('🧹 🖼️ Cleaning up image: $imageUrl');

      if (imageUrl.contains('cloudinary.com')) {
        final publicId = cloudinaryService.extractPublicId(imageUrl);
        final success = await cloudinaryService.deleteImage(publicId);

        if (success) {
          developer.log('🧹 🖼️ ✅ Image deleted successfully');
        } else {
          developer.log('🧹 🖼️ ⚠️ Image deletion failed');
        }

        return success;
      } else {
        developer.log('🧹 🖼️ ⚠️ Not a Cloudinary URL, skipping');
        return false;
      }
    } catch (e) {
      developer.log('🧹 🖼️ ❌ Error cleaning up image: $e');
      return false;
    }
  }
}

/// Result of the auto-cleanup operation
class CleanupResult {
  final int deletedTasksCount;
  final int deletedImagesCount;
  final List<String> errors;
  final DateTime completedAt;

  const CleanupResult({
    required this.deletedTasksCount,
    required this.deletedImagesCount,
    required this.errors,
    required this.completedAt,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccessful => deletedTasksCount > 0 && errors.isEmpty;

  @override
  String toString() {
    return 'CleanupResult{tasks: $deletedTasksCount, images: $deletedImagesCount, errors: ${errors.length}}';
  }
}

/// Result of deleting a single task
class TaskDeleteResult {
  final bool success;
  final String? error;
  final bool imageDeleted;
  final int deletedImagesCount;

  const TaskDeleteResult({
    required this.success,
    required this.error,
    required this.imageDeleted,
    this.deletedImagesCount = 0,
  });
}
