import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/task.dart' as entities;
import '../../repositories/task_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';

class GetTasksForManagerUseCase {
  final TaskRepository taskRepository;
  final AuthRepository authRepository;
  final UserRepository userRepository;

  GetTasksForManagerUseCase({
    required this.taskRepository,
    required this.authRepository,
    required this.userRepository,
  });

  Future<Either<Failure, List<entities.Task>>> call({
    int? limit,
    String? lastTaskId,
  }) async {
    try {
      // Get current user to check their role and managed categories
      final currentUserResult = await authRepository.getCurrentUser();

      return await currentUserResult.fold((failure) => Left(failure), (
        currentUser,
      ) async {
        // If user is admin, return all tasks (no filtering)
        if (currentUser.isAdmin) {
          return await taskRepository.getAllTasks(
            limit: limit,
            lastTaskId: lastTaskId,
          );
        }

        // If user is not a manager, return failure
        if (!currentUser.isManager) {
          return Left(
            ServerFailure(message: 'Access denied. User is not a manager.'),
          );
        }

        // Get full user details with managed categories
        final userResult = await userRepository.getUserProfile(
          currentUser.email,
        );

        return await userResult.fold((failure) => Left(failure), (user) async {
          // Get effective managed categories for the manager
          final managedCategories = user.effectiveManagedCategories;

          // Get tasks filtered by manager's categories
          return await taskRepository.getTasksForManager(
            managedCategories: managedCategories,
            limit: limit,
            lastTaskId: lastTaskId,
          );
        });
      });
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get tasks for manager: ${e.toString()}',
        ),
      );
    }
  }
}
