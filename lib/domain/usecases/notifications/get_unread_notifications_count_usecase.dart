import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/notification_repository.dart';

class GetUnreadNotificationsCountUseCase {
  final NotificationRepository repository;

  GetUnreadNotificationsCountUseCase(this.repository);

  Future<Either<Failure, int>> call(String userEmail) async {
    if (userEmail.isEmpty) {
      return const Left(
        ValidationFailure(message: 'User email cannot be empty'),
      );
    }

    return await repository.getUnreadNotificationsCount(userEmail);
  }
}
