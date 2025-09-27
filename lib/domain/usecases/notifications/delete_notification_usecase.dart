import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/notification_repository.dart';

class DeleteNotificationUseCase {
  final NotificationRepository repository;

  DeleteNotificationUseCase({required this.repository});

  Future<Either<Failure, void>> call(String notificationId) async {
    return await repository.deleteNotification(notificationId);
  }
}
