import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/notification.dart';
import '../../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase({required this.repository});

  Future<Either<Failure, List<Notification>>> call({
    required String userEmail,
    int? limit,
    String? lastNotificationId,
  }) async {
    return await repository.getNotificationsForUser(
      userEmail: userEmail,
      limit: limit,
      lastNotificationId: lastNotificationId,
    );
  }
}
