import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification.dart';

class NotificationModel {
  final String notificationId;
  final String title;
  final String message;
  final String type;
  final String recipientEmail;
  final String? taskId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  const NotificationModel({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.type,
    required this.recipientEmail,
    this.taskId,
    this.data,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
  });

  // Convert from domain entity to model
  factory NotificationModel.fromEntity(Notification notification) {
    return NotificationModel(
      notificationId: notification.notificationId,
      title: notification.title,
      message: notification.message,
      type: notification.type,
      recipientEmail: notification.recipientEmail,
      taskId: notification.taskId,
      data: notification.data,
      createdAt: notification.createdAt,
      isRead: notification.isRead,
      actionUrl: notification.actionUrl,
    );
  }

  // Convert from Firestore document to model
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      notificationId: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      recipientEmail: data['recipientEmail'] ?? '',
      taskId: data['taskId'],
      data: data['data'] != null
          ? Map<String, dynamic>.from(data['data'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      actionUrl: data['actionUrl'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'recipientEmail': recipientEmail,
      'taskId': taskId,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'actionUrl': actionUrl,
    };
  }

  // Convert to domain entity
  Notification toEntity() {
    return Notification(
      notificationId: notificationId,
      title: title,
      message: message,
      type: type,
      recipientEmail: recipientEmail,
      taskId: taskId,
      data: data,
      createdAt: createdAt,
      isRead: isRead,
      actionUrl: actionUrl,
    );
  }

  // Copy with method
  NotificationModel copyWith({
    String? notificationId,
    String? title,
    String? message,
    String? type,
    String? recipientEmail,
    String? taskId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      taskId: taskId ?? this.taskId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}
