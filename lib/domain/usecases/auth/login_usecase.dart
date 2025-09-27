import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/app_user.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AppUser>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}
