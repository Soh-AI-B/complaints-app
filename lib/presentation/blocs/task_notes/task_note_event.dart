import 'package:equatable/equatable.dart';

abstract class TaskNoteEvent extends Equatable {
  const TaskNoteEvent();

  @override
  List<Object?> get props => [];
}

// Load notes for a task
class LoadTaskNotes extends TaskNoteEvent {
  final String taskId;

  const LoadTaskNotes({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

// Add a note to a task
class AddTaskNote extends TaskNoteEvent {
  final String taskId;
  final String note;
  final String authorName;
  final String authorEmail;

  const AddTaskNote({
    required this.taskId,
    required this.note,
    required this.authorName,
    required this.authorEmail,
  });

  @override
  List<Object?> get props => [taskId, note, authorName, authorEmail];
}

// Delete a note
class DeleteTaskNote extends TaskNoteEvent {
  final String noteId;
  final String taskId;

  const DeleteTaskNote({required this.noteId, required this.taskId});

  @override
  List<Object?> get props => [noteId, taskId];
}
