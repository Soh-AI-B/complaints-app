import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/notification.dart';
import '../../entities/task.dart' as entities;
import '../../repositories/notification_repository.dart';

class SendNewTaskNotificationUseCase {
  final NotificationRepository repository;

  SendNewTaskNotificationUseCase(this.repository);

  Future<Either<Failure, List<Notification>>> call(entities.Task task) async {
    print(
      '🔔 SendNewTaskNotificationUseCase: Starting for task ${task.taskId}',
    );
    print('🔔 Task details: ${task.title} by ${task.employeeName}');

    final title = 'New Task Created';
    final message =
        'A new task "${task.title}" has been reported by ${task.employeeName}';

    final data = {
      'taskTitle': task.title, // Add this missing field!
      'priority': task.priority,
      'category': task.category,
      'employeeName': task.employeeName,
      'employeeEmail': task.employeeEmail,
    };

    print('🔔 Sending notification with data: $data');

    return await repository.sendNotificationToManagersAndAdmins(
      title: title,
      message: message,
      type: 'new_task',
      taskId: task.taskId,
      taskCategory: task.category, // Pass task category for filtering
      data: data,
      actionUrl: '/task-detail/${task.taskId}',
    );
  }
}
