import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/task.dart';
import '../../repositories/task_note_repository.dart';

class GetTaskNotesUseCase {
  final TaskNoteRepository repository;

  GetTaskNotesUseCase(this.repository);

  Future<Either<Failure, List<TaskNote>>> call(String taskId) async {
    if (taskId.isEmpty) {
      return const Left(ValidationFailure(message: 'Task ID cannot be empty'));
    }

    return await repository.getNotesForTask(taskId);
  }
}
