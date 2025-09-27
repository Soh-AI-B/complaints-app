import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../../core/error/failures.dart';

class GetAllUsersParams {
  final int? limit;
  final String? lastUserId;

  const GetAllUsersParams({this.limit, this.lastUserId});
}

class GetAllUsersUseCase {
  final UserRepository repository;

  GetAllUsersUseCase(this.repository);

  Future<Either<Failure, List<User>>> call([GetAllUsersParams? params]) async {
    return await repository.getAllUsers(
      limit: params?.limit,
      lastUserId: params?.lastUserId,
    );
  }
}
