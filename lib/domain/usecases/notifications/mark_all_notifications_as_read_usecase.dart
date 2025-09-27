import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/notification_repository.dart';

class MarkAllNotificationsAsReadUseCase {
  final NotificationRepository repository;

  MarkAllNotificationsAsReadUseCase({required this.repository});

  Future<Either<Failure, void>> call(String userEmail) async {
    return await repository.markAllAsRead(userEmail);
  }
}
