import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_note_repository.dart';
import '../models/task_note_model.dart';

class TaskNoteRepositoryImpl implements TaskNoteRepository {
  final FirebaseFirestore firestore;

  TaskNoteRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, TaskNote>> addNote({
    required String taskId,
    required String note,
    required String authorName,
    required String authorEmail,
  }) async {
    try {
      final noteDoc = firestore.collection('task_notes').doc();

      final taskNote = TaskNote(
        note: note,
        authorName: authorName,
        authorEmail: authorEmail,
        createdAt: DateTime.now(),
      );

      final noteModel = TaskNoteModel.fromEntity(taskNote, taskId, noteDoc.id);

      await noteDoc.set(noteModel.toFirestore());

      return Right(taskNote);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: 'Failed to add note: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add note: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TaskNote>>> getNotesForTask(String taskId) async {
    try {
      final querySnapshot = await firestore
          .collection('task_notes')
          .where('task_id', isEqualTo: taskId)
          .get();

      final notes = querySnapshot.docs
          .map((doc) => TaskNoteModel.fromFirestore(doc).toEntity())
          .toList();

      // Sort by created_at in Dart instead of Firestore to avoid index requirement
      notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return Right(notes);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: 'Failed to get notes: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get notes: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
      await firestore.collection('task_notes').doc(noteId).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(message: 'Failed to delete note: ${e.message}'),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete note: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskNote>> updateNote({
    required String noteId,
    required String note,
  }) async {
    try {
      await firestore.collection('task_notes').doc(noteId).update({
        'note': note,
      });

      final doc = await firestore.collection('task_notes').doc(noteId).get();
      final updatedNote = TaskNoteModel.fromFirestore(doc).toEntity();

      return Right(updatedNote);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(message: 'Failed to update note: ${e.message}'),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update note: $e'));
    }
  }
}
