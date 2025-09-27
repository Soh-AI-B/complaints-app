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
    print('🗑️ DeleteTaskUseCase: Starting deletion for task: $taskId');
    print('🗑️ User role: $userRole');

    // Verify user has permission to delete tasks
    if (!_canDeleteTasks(userRole)) {
      print('🗑️ ❌ User does not have permission to delete tasks');
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
          print(
            '🗑️ ⚠️ Could not retrieve task details for cleanup: ${failure.message}',
          );
          // Continue with deletion even if we can't get task details
        },
        (task) {
          imageUrls =
              task.allImageUrls; // Get all images (both old and new format)
          print('🗑️ Task has ${imageUrls.length} images to clean up');
        },
      );

      // Delete the task from Firestore
      print('🗑️ Deleting task from database...');
      final deleteResult = await repository.deleteTask(taskId);

      return deleteResult.fold(
        (failure) {
          print('🗑️ ❌ Failed to delete task: ${failure.message}');
          return Left(failure);
        },
        (_) async {
          print('🗑️ ✅ Task deleted from database successfully');

          // Clean up related notifications
          print('🗑️ 🔔 Deleting related notifications...');
          final notificationResult = await notificationRepository
              .deleteNotificationsByTaskId(taskId);
          notificationResult.fold(
            (failure) => print(
              '🗑️ ⚠️ Failed to delete notifications: ${failure.message}',
            ),
            (_) => print('🗑️ ✅ Related notifications deleted successfully'),
          );

          // Clean up all associated images from Cloudinary
          if (imageUrls.isNotEmpty) {
            print('🗑️ 🖼️ Cleaning up ${imageUrls.length} images...');
            for (final imageUrl in imageUrls) {
              await _cleanupTaskImage(imageUrl);
            }
          }

          print('🗑️ ✅ Task deletion completed successfully');
          return const Right(null);
        },
      );
    } catch (e) {
      print('🗑️ ❌ Unexpected error during task deletion: $e');
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
      print('🗑️ 🖼️ Starting image cleanup for: $imageUrl');

      if (imageUrl.contains('cloudinary.com')) {
        final publicId = cloudinaryService.extractPublicId(imageUrl);
        print('🗑️ 🖼️ Extracted public ID: $publicId');

        final success = await cloudinaryService.deleteImage(publicId);
        if (success) {
          print('🗑️ 🖼️ ✅ Image deleted from Cloudinary successfully');
        } else {
          print(
            '🗑️ 🖼️ ⚠️ Image deletion from Cloudinary failed (but task was deleted)',
          );
        }
      } else {
        print('🗑️ 🖼️ ⚠️ Image URL is not from Cloudinary, skipping cleanup');
      }
    } catch (e) {
      print('🗑️ 🖼️ ❌ Error cleaning up image: $e');
      // Don't fail the entire operation if image cleanup fails
    }
  }
}

/// Authorization failure specific to permissions
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({required String message})
    : super(message: message);
}
