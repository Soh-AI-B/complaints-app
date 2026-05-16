import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloudinary_service.dart';

class TaskCleanupService {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinaryService;

  // Cleanup completed tasks after 90 days by default
  static const int defaultCleanupDays = 90;

  TaskCleanupService({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinaryService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cloudinaryService = cloudinaryService ?? CloudinaryService();

  /// Clean up completed tasks older than specified days
  Future<Map<String, int>> cleanupOldTasks({
    int daysOld = defaultCleanupDays,
    List<String> statusesToCleanup = const ['Completed', 'Cancelled'],
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final results = <String, int>{
        'tasksDeleted': 0,
        'imagesDeleted': 0,
        'errors': 0,
      };

      // Query tasks to cleanup
      final tasksQuery = await _firestore
          .collection('tasks')
          .where('status', whereIn: statusesToCleanup)
          .where('date_updated', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      developer.log('Found ${tasksQuery.docs.length} tasks to cleanup');

      for (final taskDoc in tasksQuery.docs) {
        try {
          final taskData = taskDoc.data();

          // Delete associated images if they exist
          // Handle both single image (legacy) and multiple images (new format)
          final List<String> imageUrls = [];

          // Add legacy single image if exists
          if (taskData['picture_url'] != null &&
              taskData['picture_url'].toString().isNotEmpty) {
            imageUrls.add(taskData['picture_url'].toString());
          }

          // Add multiple images if they exist
          if (taskData['picture_urls'] != null &&
              taskData['picture_urls'] is List) {
            final List<dynamic> pictureUrlsList = taskData['picture_urls'];
            for (final url in pictureUrlsList) {
              if (url != null && url.toString().isNotEmpty) {
                imageUrls.add(url.toString());
              }
            }
          }

          // Delete all images associated with this task
          for (final imageUrl in imageUrls) {
            if (imageUrl.contains('cloudinary.com')) {
              try {
                final publicId = _cloudinaryService.extractPublicId(imageUrl);
                final deleted = await _cloudinaryService.deleteImage(publicId);
                if (deleted) {
                  results['imagesDeleted'] = results['imagesDeleted']! + 1;
                }
              } catch (e) {
                developer.log(
                  'Failed to delete image $imageUrl for task ${taskDoc.id}: $e',
                );
                results['errors'] = results['errors']! + 1;
              }
            }
          }

          // Delete the task document
          await taskDoc.reference.delete();
          results['tasksDeleted'] = results['tasksDeleted']! + 1;

          developer.log(
            'Cleaned up task: ${taskDoc.id} (deleted ${imageUrls.length} images)',
          );
        } catch (e) {
          developer.log('Error cleaning up task ${taskDoc.id}: $e');
          results['errors'] = results['errors']! + 1;
        }
      }

      return results;
    } catch (e) {
      developer.log('Error during cleanup process: $e');
      throw Exception('Cleanup failed: $e');
    }
  }

  /// Get tasks that would be cleaned up (preview mode)
  Future<List<Map<String, dynamic>>> getTasksToCleanup({
    int daysOld = defaultCleanupDays,
    List<String> statusesToCleanup = const ['Completed', 'Cancelled'],
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      final tasksQuery = await _firestore
          .collection('tasks')
          .where('status', whereIn: statusesToCleanup)
          .where('date_updated', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      return tasksQuery.docs.map((doc) {
        final data = doc.data();

        // Check if task has any images (legacy or new format)
        bool hasImages = false;
        int imageCount = 0;

        // Check legacy single image
        if (data['picture_url'] != null &&
            data['picture_url'].toString().isNotEmpty) {
          hasImages = true;
          imageCount++;
        }

        // Check multiple images
        if (data['picture_urls'] != null && data['picture_urls'] is List) {
          final List<dynamic> pictureUrlsList = data['picture_urls'];
          for (final url in pictureUrlsList) {
            if (url != null && url.toString().isNotEmpty) {
              hasImages = true;
              imageCount++;
            }
          }
        }

        return {
          'id': doc.id,
          'title': data['title'] ?? 'Unknown',
          'status': data['status'] ?? 'Unknown',
          'date_updated': data['date_updated']?.toDate(),
          'has_image': hasImages,
          'image_count': imageCount,
        };
      }).toList();
    } catch (e) {
      developer.log('Error getting tasks to cleanup: $e');
      return [];
    }
  }

  /// Schedule automatic cleanup (call this periodically)
  Future<void> scheduleCleanup() async {
    try {
      developer.log('Starting scheduled cleanup...');

      final results = await cleanupOldTasks();

      developer.log('Cleanup completed:');
      developer.log('- Tasks deleted: ${results['tasksDeleted']}');
      developer.log('- Images deleted: ${results['imagesDeleted']}');
      developer.log('- Errors: ${results['errors']}');

      // Log cleanup activity
      await _logCleanupActivity(results);
    } catch (e) {
      developer.log('Scheduled cleanup failed: $e');
    }
  }

  /// Log cleanup activity to Firestore
  Future<void> _logCleanupActivity(Map<String, int> results) async {
    try {
      await _firestore.collection('cleanup_logs').add({
        'timestamp': FieldValue.serverTimestamp(),
        'tasks_deleted': results['tasksDeleted'],
        'images_deleted': results['imagesDeleted'],
        'errors': results['errors'],
        'cleanup_type': 'automatic',
      });
    } catch (e) {
      developer.log('Failed to log cleanup activity: $e');
    }
  }

  /// Clean up orphaned images (images not referenced by any task)
  Future<int> cleanupOrphanedImages() async {
    try {
      int cleanedCount = 0;

      // Get all tasks with images (both legacy and new format)
      final allTasks = await _firestore.collection('tasks').get();

      final referencedImages = <String>{};

      for (final doc in allTasks.docs) {
        final data = doc.data();

        // Check legacy single image
        final singleImageUrl = data['picture_url'];
        if (singleImageUrl != null && singleImageUrl.toString().isNotEmpty) {
          try {
            final publicId = _cloudinaryService.extractPublicId(singleImageUrl);
            referencedImages.add(publicId);
          } catch (e) {
            // Skip invalid URLs
          }
        }

        // Check multiple images
        if (data['picture_urls'] != null && data['picture_urls'] is List) {
          final List<dynamic> pictureUrlsList = data['picture_urls'];
          for (final url in pictureUrlsList) {
            if (url != null && url.toString().isNotEmpty) {
              try {
                final publicId = _cloudinaryService.extractPublicId(url);
                referencedImages.add(publicId);
              } catch (e) {
                // Skip invalid URLs
              }
            }
          }
        }
      }

      developer.log('Found ${referencedImages.length} referenced images');

      // Note: To fully implement orphaned image cleanup, you would need:
      // 1. Cloudinary Admin API access to list all images
      // 2. Compare with referenced images
      // 3. Delete unreferenced images
      // For now, we'll just return the count of referenced images

      return cleanedCount;
    } catch (e) {
      developer.log('Error cleaning up orphaned images: $e');
      return 0;
    }
  }

  /// Get storage usage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final allTasks = await _firestore.collection('tasks').get();

      int totalTasks = allTasks.docs.length;
      int tasksWithImages = 0;
      int totalImages = 0;
      final statusCounts = <String, int>{};

      for (final doc in allTasks.docs) {
        final data = doc.data();

        bool taskHasImages = false;
        int taskImageCount = 0;

        // Count legacy single image
        if (data['picture_url'] != null &&
            data['picture_url'].toString().isNotEmpty) {
          taskHasImages = true;
          taskImageCount++;
        }

        // Count multiple images
        if (data['picture_urls'] != null && data['picture_urls'] is List) {
          final List<dynamic> pictureUrlsList = data['picture_urls'];
          for (final url in pictureUrlsList) {
            if (url != null && url.toString().isNotEmpty) {
              taskHasImages = true;
              taskImageCount++;
            }
          }
        }

        if (taskHasImages) {
          tasksWithImages++;
        }
        totalImages += taskImageCount;

        final status = data['status'] ?? 'Unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      return {
        'total_tasks': totalTasks,
        'tasks_with_images': tasksWithImages,
        'total_images': totalImages,
        'average_images_per_task': totalTasks > 0
            ? (totalImages / totalTasks).toStringAsFixed(2)
            : '0.0',
        'status_breakdown': statusCounts,
        'storage_efficiency': tasksWithImages > 0
            ? (tasksWithImages / totalTasks * 100).toStringAsFixed(1)
            : '0.0',
      };
    } catch (e) {
      developer.log('Error getting storage stats: $e');
      return {};
    }
  }
}
