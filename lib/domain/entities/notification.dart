class Notification {
  final String notificationId;
  final String title;
  final String message;
  final String type; // 'new_task', 'task_updated', 'task_assigned', etc.
  final String recipientEmail;
  final String? taskId;
  final Map<String, dynamic>? data; // Additional data
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl; // Deep link or navigation route

  const Notification({
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

  // Copy with method for creating modified copies
  Notification copyWith({
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
    return Notification(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notification &&
          runtimeType == other.runtimeType &&
          notificationId == other.notificationId;

  @override
  int get hashCode => notificationId.hashCode;

  @override
  String toString() {
    return 'Notification{'
        'notificationId: $notificationId, '
        'title: $title, '
        'message: $message, '
        'type: $type, '
        'recipientEmail: $recipientEmail, '
        'taskId: $taskId, '
        'createdAt: $createdAt, '
        'isRead: $isRead'
        '}';
  }
}
