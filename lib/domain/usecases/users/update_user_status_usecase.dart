import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../../core/error/failures.dart';

class UpdateUserStatusParams {
  final String email;
  final bool isActive;

  const UpdateUserStatusParams({required this.email, required this.isActive});
}

class UpdateUserStatusUseCase {
  final UserRepository repository;

  UpdateUserStatusUseCase(this.repository);

  Future<Either<Failure, User>> call(UpdateUserStatusParams params) async {
    return await repository.updateUserStatus(
      email: params.email,
      isActive: params.isActive,
    );
  }
}
