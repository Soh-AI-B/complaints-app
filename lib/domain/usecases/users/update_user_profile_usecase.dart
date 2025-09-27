import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class UpdateUserProfileUseCase {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    String? name,
    String? phone,
    String? team,
  }) async {
    return await repository.updateUserProfile(
      email: email,
      name: name,
      phone: phone,
      team: team,
    );
  }
}
