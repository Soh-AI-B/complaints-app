import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/task.dart';
import '../../repositories/task_note_repository.dart';

class AddTaskNoteUseCase {
  final TaskNoteRepository repository;

  AddTaskNoteUseCase(this.repository);

  Future<Either<Failure, TaskNote>> call({
    required String taskId,
    required String note,
    required String authorName,
    required String authorEmail,
  }) async {
    if (note.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Note cannot be empty'));
    }

    return await repository.addNote(
      taskId: taskId,
      note: note.trim(),
      authorName: authorName,
      authorEmail: authorEmail,
    );
  }
}
