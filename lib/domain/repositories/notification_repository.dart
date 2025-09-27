import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  // Send notification to specific user
  Future<Either<Failure, Notification>> sendNotification({
    required String title,
    required String message,
    required String type,
    required String recipientEmail,
    String? taskId,
    Map<String, dynamic>? data,
    String? actionUrl,
  });

  // Send notification to multiple users
  Future<Either<Failure, List<Notification>>> sendNotificationToMultiple({
    required String title,
    required String message,
    required String type,
    required List<String> recipientEmails,
    String? taskId,
    Map<String, dynamic>? data,
    String? actionUrl,
  });

  // Send notification to managers and admins
  Future<Either<Failure, List<Notification>>>
  sendNotificationToManagersAndAdmins({
    required String title,
    required String message,
    required String type,
    String? taskId,
    String? taskCategory, // New parameter for category filtering
    Map<String, dynamic>? data,
    String? actionUrl,
  });

  // Get notifications for a user
  Future<Either<Failure, List<Notification>>> getNotificationsForUser({
    required String userEmail,
    int? limit,
    String? lastNotificationId,
  });

  // Get unread notifications count
  Future<Either<Failure, int>> getUnreadNotificationsCount(String userEmail);

  // Mark notification as read
  Future<Either<Failure, Notification>> markAsRead(String notificationId);

  // Mark all notifications as read for user
  Future<Either<Failure, void>> markAllAsRead(String userEmail);

  // Delete notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  // Delete all notifications for a user
  Future<Either<Failure, void>> deleteAllNotifications(String userEmail);

  // Delete notifications by task ID (when task is deleted)
  Future<Either<Failure, void>> deleteNotificationsByTaskId(String taskId);

  // Get notification by ID
  Future<Either<Failure, Notification>> getNotificationById(
    String notificationId,
  );

  // Get notifications stream for real-time updates
  Stream<Either<Failure, List<Notification>>> getNotificationsStream(
    String userEmail,
  );
}
