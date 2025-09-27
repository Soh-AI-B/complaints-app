import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/task.dart' as entities;
import '../../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<Either<Failure, List<entities.Task>>> call({
    String? employeeEmail,
    String? status,
    String? priority,
    String? category,
    int? limit,
    String? lastTaskId,
  }) async {
    if (employeeEmail != null) {
      return await repository.getTasksByUser(
        employeeEmail: employeeEmail,
        limit: limit,
        lastTaskId: lastTaskId,
      );
    } else if (status != null) {
      return await repository.getTasksByStatus(
        status: status,
        limit: limit,
        lastTaskId: lastTaskId,
      );
    } else if (priority != null) {
      return await repository.getTasksByPriority(
        priority: priority,
        limit: limit,
        lastTaskId: lastTaskId,
      );
    } else if (category != null) {
      return await repository.getTasksByCategory(
        category: category,
        limit: limit,
        lastTaskId: lastTaskId,
      );
    } else {
      return await repository.getAllTasks(limit: limit, lastTaskId: lastTaskId);
    }
  }
}
