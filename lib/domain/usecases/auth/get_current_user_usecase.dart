import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/app_user.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, AppUser>> call() async {
    return await repository.getCurrentUser();
  }
}
