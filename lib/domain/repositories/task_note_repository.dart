import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../entities/task.dart';

abstract class TaskNoteRepository {
  // Add a note to a task
  Future<Either<Failure, TaskNote>> addNote({
    required String taskId,
    required String note,
    required String authorName,
    required String authorEmail,
  });

  // Get all notes for a task
  Future<Either<Failure, List<TaskNote>>> getNotesForTask(String taskId);

  // Delete a note
  Future<Either<Failure, void>> deleteNote(String noteId);

  // Update a note
  Future<Either<Failure, TaskNote>> updateNote({
    required String noteId,
    required String note,
  });
}
