import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/app_user.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AppUser>> call({
    required String email,
    required String password,
    required String name,
    required String role,
    required String team,
    String? phone,
  }) async {
    return await repository.register(
      email: email,
      password: password,
      name: name,
      role: role,
      team: team,
      phone: phone,
    );
  }
}
