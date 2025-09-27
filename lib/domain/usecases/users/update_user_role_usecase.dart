import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../../core/error/failures.dart';

class UpdateUserRoleParams {
  final String email;
  final String newRole;
  final List<String>? managedCategories; // New field for manager categories

  const UpdateUserRoleParams({
    required this.email,
    required this.newRole,
    this.managedCategories,
  });
}

class UpdateUserRoleUseCase {
  final UserRepository repository;

  UpdateUserRoleUseCase(this.repository);

  Future<Either<Failure, User>> call(UpdateUserRoleParams params) async {
    return await repository.updateUserRole(
      email: params.email,
      newRole: params.newRole,
      managedCategories: params.managedCategories,
    );
  }
}
