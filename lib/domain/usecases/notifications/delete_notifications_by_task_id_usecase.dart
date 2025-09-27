import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/notification_repository.dart';

/// Use case for deleting notifications by task ID
/// This is used when a task is deleted to clean up related notifications
class DeleteNotificationsByTaskIdUseCase {
  final NotificationRepository repository;

  DeleteNotificationsByTaskIdUseCase({required this.repository});

  Future<Either<Failure, void>> call({required String taskId}) async {
    return await repository.deleteNotificationsByTaskId(taskId);
  }
}
