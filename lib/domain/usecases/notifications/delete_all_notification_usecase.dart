import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/notification_repository.dart';

class DeleteAllNotificationsUseCase {
  final NotificationRepository repository;

  DeleteAllNotificationsUseCase({required this.repository});

  Future<Either<Failure, void>> call(String userEmail) async {
    return await repository.deleteAllNotifications(userEmail);
  }
}
