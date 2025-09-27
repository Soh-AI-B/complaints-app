import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/notification.dart';
import '../../repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase({required this.repository});

  Future<Either<Failure, Notification>> call(String notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}
