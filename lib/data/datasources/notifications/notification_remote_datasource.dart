import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/error/exceptions.dart';
import '../../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  // Create a notification
  Future<NotificationModel> createNotification(NotificationModel notification);

  // Get notifications for user
  Future<List<NotificationModel>> getNotificationsForUser({
    required String userEmail,
    int? limit,
    String? lastNotificationId,
  });

  // Get unread notifications count
  Future<int> getUnreadNotificationsCount(String userEmail);

  // Update notification
  Future<NotificationModel> updateNotification(
    String notificationId,
    Map<String, dynamic> updates,
  );

  // Delete notification
  Future<void> deleteNotification(String notificationId);

  // Delete all notifications for a user
  Future<void> deleteAllNotifications(String userEmail);

  // Delete notifications by task ID (when task is deleted)
  Future<void> deleteNotificationsByTaskId(String taskId);

  // Get notification by ID
  Future<NotificationModel> getNotificationById(String notificationId);

  // Get notifications stream
  Stream<List<NotificationModel>> getNotificationsStream(String userEmail);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationRemoteDataSourceImpl({required this.firestore});

  @override
  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    try {
      final docRef = await firestore
          .collection('notifications')
          .add(notification.toFirestore());

      final doc = await docRef.get();
      return NotificationModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to create notification: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationsForUser({
    required String userEmail,
    int? limit,
    String? lastNotificationId,
  }) async {
    try {
      Query query = firestore
          .collection('notifications')
          .where('recipientEmail', isEqualTo: userEmail)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (lastNotificationId != null) {
        final lastDoc = await firestore
            .collection('notifications')
            .doc(lastNotificationId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get notifications: $e');
    }
  }

  @override
  Future<int> getUnreadNotificationsCount(String userEmail) async {
    try {
      final snapshot = await firestore
          .collection('notifications')
          .where('recipientEmail', isEqualTo: userEmail)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get unread notifications count: $e',
      );
    }
  }

  @override
  Future<NotificationModel> updateNotification(
    String notificationId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await firestore
          .collection('notifications')
          .doc(notificationId)
          .update(updates);

      final doc = await firestore
          .collection('notifications')
          .doc(notificationId)
          .get();

      return NotificationModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to update notification: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete notification: $e');
    }
  }

  // Delete all notifications for a user
  Future<void> deleteAllNotifications(String userEmail) async {
    try {
      final snapshot = await firestore
          .collection('notifications')
          .where('recipientEmail', isEqualTo: userEmail)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw ServerException(message: 'Failed to delete all notifications: $e');
    }
  }

  // Delete notifications by task ID (when task is deleted)
  @override
  Future<void> deleteNotificationsByTaskId(String taskId) async {
    try {
      final snapshot = await firestore
          .collection('notifications')
          .where('taskId', isEqualTo: taskId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete notifications by task ID: $e',
      );
    }
  }

  @override
  Future<NotificationModel> getNotificationById(String notificationId) async {
    try {
      final doc = await firestore
          .collection('notifications')
          .doc(notificationId)
          .get();

      if (!doc.exists) {
        throw const ServerException(message: 'Notification not found');
      }

      return NotificationModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to get notification: $e');
    }
  }

  @override
  Stream<List<NotificationModel>> getNotificationsStream(String userEmail) {
    try {
      return firestore
          .collection('notifications')
          .where('recipientEmail', isEqualTo: userEmail)
          .orderBy('createdAt', descending: true)
          .limit(50) // Limit for performance
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => NotificationModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      throw ServerException(message: 'Failed to get notifications stream: $e');
    }
  }
}
