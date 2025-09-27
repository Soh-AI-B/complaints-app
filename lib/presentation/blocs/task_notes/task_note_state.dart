import '../../../domain/entities/task.dart';
import 'package:equatable/equatable.dart';

abstract class TaskNoteState extends Equatable {
  const TaskNoteState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TaskNoteInitial extends TaskNoteState {
  const TaskNoteInitial();
}

// Loading state
class TaskNoteLoading extends TaskNoteState {
  const TaskNoteLoading();
}

// Notes loaded successfully
class TaskNotesLoaded extends TaskNoteState {
  final List<TaskNote> notes;
  final String taskId;

  const TaskNotesLoaded({required this.notes, required this.taskId});

  @override
  List<Object?> get props => [notes, taskId];
}

// Note added successfully
class TaskNoteAdded extends TaskNoteState {
  final TaskNote note;
  final List<TaskNote> allNotes;
  final String taskId;

  const TaskNoteAdded({
    required this.note,
    required this.allNotes,
    required this.taskId,
  });

  @override
  List<Object?> get props => [note, allNotes, taskId];
}

// Note deleted successfully
class TaskNoteDeleted extends TaskNoteState {
  final String noteId;
  final List<TaskNote> remainingNotes;
  final String taskId;

  const TaskNoteDeleted({
    required this.noteId,
    required this.remainingNotes,
    required this.taskId,
  });

  @override
  List<Object?> get props => [noteId, remainingNotes, taskId];
}

// Error state
class TaskNoteError extends TaskNoteState {
  final String message;

  const TaskNoteError({required this.message});

  @override
  List<Object?> get props => [message];
}
