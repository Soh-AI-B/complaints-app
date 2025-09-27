import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/task.dart' as entities;
import '../../repositories/task_repository.dart';

class GetTaskByIdUseCase {
  final TaskRepository repository;

  GetTaskByIdUseCase(this.repository);

  Future<Either<Failure, entities.Task>> call(String taskId) async {
    return await repository.getTaskById(taskId);
  }
}
