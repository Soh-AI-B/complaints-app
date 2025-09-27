import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/services/vercel_notification_service.dart';

abstract class PushNotificationService {
  // Send push notification to topic (role-based)
  Future<Either<Failure, void>> sendPushNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, String>? data,
  });

  // Send push notification for new task to managers and admins
  Future<Either<Failure, void>> sendNewTaskPushNotification({
    required String taskId,
    required String taskTitle,
    required String employeeName,
    required String priority,
    required String category,
  });

  // Test API connection
  Future<Either<Failure, Map<String, dynamic>>> testConnection();
}

class PushNotificationServiceImpl implements PushNotificationService {
  final VercelNotificationService vercelService;

  PushNotificationServiceImpl({required this.vercelService});

  @override
  Future<Either<Failure, void>> sendPushNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    return await vercelService.sendNotificationToTopic(
      topic: topic,
      title: title,
      body: body,
      data: data,
    );
  }

  @override
  Future<Either<Failure, void>> sendNewTaskPushNotification({
    required String taskId,
    required String taskTitle,
    required String employeeName,
    required String priority,
    required String category,
  }) async {
    return await vercelService.sendNewTaskNotification(
      taskId: taskId,
      taskTitle: taskTitle,
      employeeName: employeeName,
      priority: priority,
      category: category,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> testConnection() async {
    return await vercelService.testConnection();
  }
}
