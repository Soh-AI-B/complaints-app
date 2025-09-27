import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository repository;

  DeleteUserUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) async {
    return await repository.deleteUser(email);
  }
}
