import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/task_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../../core/services/cloudinary_service.dart';

/// Use case for deleting a task (only for managers/admins)
/// Also handles cleanup of associated images in Cloudinary and related notifications
class DeleteTaskUseCase {
  final TaskRepository repository;
  final NotificationRepository notificationRepository;
  final CloudinaryService cloudinaryService;

  DeleteTaskUseCase({
    required this.repository,
    required this.notificationRepository,
    required this.cloudinaryService,
  });

  Future<Either<Failure, void>> call({
    required String taskId,
    required String userRole,
  }) async {
    developer.log('🗑️ DeleteTaskUseCase: Starting deletion for task: $taskId');
    developer.log('🗑️ User role: $userRole');

    // Verify user has permission to delete tasks
    if (!_canDeleteTasks(userRole)) {
      developer.log('🗑️ ❌ User does not have permission to delete tasks');
      return const Left(
        AuthorizationFailure(
          message: 'Only managers and admins can delete tasks',
        ),
      );
    }

    try {
      // First, get the task to retrieve image URLs before deletion
      final taskResult = await repository.getTaskById(taskId);

      List<String> imageUrls = [];
      taskResult.fold(
        (failure) {
          developer.log(
            '🗑️ ⚠️ Could not retrieve task details for cleanup: ${failure.message}',
          );
          // Continue with deletion even if we can't get task details
        },
        (task) {
          imageUrls =
              task.allImageUrls; // Get all images (both old and new format)
          developer.log('🗑️ Task has ${imageUrls.length} images to clean up');
        },
      );

      // Delete the task from Firestore
      developer.log('🗑️ Deleting task from database...');
      final deleteResult = await repository.deleteTask(taskId);

      return deleteResult.fold(
        (failure) {
          developer.log('🗑️ ❌ Failed to delete task: ${failure.message}');
          return Left(failure);
        },
        (_) async {
          developer.log('🗑️ ✅ Task deleted from database successfully');

          // Clean up related notifications
          developer.log('🗑️ 🔔 Deleting related notifications...');
          final notificationResult = await notificationRepository
              .deleteNotificationsByTaskId(taskId);
          notificationResult.fold(
            (failure) => developer.log(
              '🗑️ ⚠️ Failed to delete notifications: ${failure.message}',
            ),
            (_) => developer.log(
              '🗑️ ✅ Related notifications deleted successfully',
            ),
          );

          // Clean up all associated images from Cloudinary
          if (imageUrls.isNotEmpty) {
            developer.log('🗑️ 🖼️ Cleaning up ${imageUrls.length} images...');
            for (final imageUrl in imageUrls) {
              await _cleanupTaskImage(imageUrl);
            }
          }

          developer.log('🗑️ ✅ Task deletion completed successfully');
          return const Right(null);
        },
      );
    } catch (e) {
      developer.log('🗑️ ❌ Unexpected error during task deletion: $e');
      return Left(ServerFailure(message: 'Failed to delete task: $e'));
    }
  }

  /// Check if user role can delete tasks
  bool _canDeleteTasks(String userRole) {
    return userRole == 'Manager' || userRole == 'Admin';
  }

  /// Clean up task image from Cloudinary storage
  Future<void> _cleanupTaskImage(String imageUrl) async {
    try {
      developer.log('🗑️ 🖼️ Starting image cleanup for: $imageUrl');

      if (imageUrl.contains('cloudinary.com')) {
        final publicId = cloudinaryService.extractPublicId(imageUrl);
        developer.log('🗑️ 🖼️ Extracted public ID: $publicId');

        final success = await cloudinaryService.deleteImage(publicId);
        if (success) {
          developer.log('🗑️ 🖼️ ✅ Image deleted from Cloudinary successfully');
        } else {
          developer.log(
            '🗑️ 🖼️ ⚠️ Image deletion from Cloudinary failed (but task was deleted)',
          );
        }
      } else {
        developer.log(
          '🗑️ 🖼️ ⚠️ Image URL is not from Cloudinary, skipping cleanup',
        );
      }
    } catch (e) {
      developer.log('🗑️ 🖼️ ❌ Error cleaning up image: $e');
      // Don't fail the entire operation if image cleanup fails
    }
  }
}

/// Authorization failure specific to permissions
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({required super.message});
}
