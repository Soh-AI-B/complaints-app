import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetUserProfileUseCase {
  final UserRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, User>> call(String email) async {
    return await repository.getUserProfile(email);
  }
}
