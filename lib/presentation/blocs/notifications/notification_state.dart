import '../../../domain/entities/notification.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationsLoaded extends NotificationState {
  final List<Notification> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    this.unreadCount = 0,
  });
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});
}

class NotificationMarkedAsRead extends NotificationState {
  final Notification notification;

  const NotificationMarkedAsRead({required this.notification});
}

class AllNotificationsMarkedAsRead extends NotificationState {
  const AllNotificationsMarkedAsRead();
}

class NotificationDeleted extends NotificationState {
  final String notificationId;

  const NotificationDeleted({required this.notificationId});
}

class UnreadCountLoaded extends NotificationState {
  final int count;

  const UnreadCountLoaded({required this.count});
}

class AllNotificationsDeleted extends NotificationState {
  const AllNotificationsDeleted();
}
