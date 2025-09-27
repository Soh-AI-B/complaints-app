abstract class NotificationEvent {
  const NotificationEvent();
}

class LoadNotifications extends NotificationEvent {
  final String userEmail;
  final int? limit;
  final String? lastNotificationId;

  const LoadNotifications({
    required this.userEmail,
    this.limit,
    this.lastNotificationId,
  });
}

class LoadUnreadCount extends NotificationEvent {
  final String userEmail;

  const LoadUnreadCount({required this.userEmail});
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead({required this.notificationId});
}

class MarkAllNotificationsAsRead extends NotificationEvent {
  final String userEmail;

  const MarkAllNotificationsAsRead({required this.userEmail});
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification({required this.notificationId});
}

class DeleteAllNotifications extends NotificationEvent {
  final String userEmail;

  const DeleteAllNotifications({required this.userEmail});
}

class RefreshNotifications extends NotificationEvent {
  final String userEmail;

  const RefreshNotifications({required this.userEmail});
}
