import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/task_notes/add_task_note_usecase.dart';
import '../../../domain/usecases/task_notes/get_task_notes_usecase.dart';
import 'task_note_event.dart';
import 'task_note_state.dart';

class TaskNoteBloc extends Bloc<TaskNoteEvent, TaskNoteState> {
  final GetTaskNotesUseCase getTaskNotesUseCase;
  final AddTaskNoteUseCase addTaskNoteUseCase;

  TaskNoteBloc({
    required this.getTaskNotesUseCase,
    required this.addTaskNoteUseCase,
  }) : super(const TaskNoteInitial()) {
    on<LoadTaskNotes>(_onLoadTaskNotes);
    on<AddTaskNote>(_onAddTaskNote);
  }

  Future<void> _onLoadTaskNotes(
    LoadTaskNotes event,
    Emitter<TaskNoteState> emit,
  ) async {
    emit(const TaskNoteLoading());

    final result = await getTaskNotesUseCase(event.taskId);

    result.fold(
      (failure) => emit(TaskNoteError(message: failure.message)),
      (notes) => emit(TaskNotesLoaded(notes: notes, taskId: event.taskId)),
    );
  }

  Future<void> _onAddTaskNote(
    AddTaskNote event,
    Emitter<TaskNoteState> emit,
  ) async {
    emit(const TaskNoteLoading());

    final result = await addTaskNoteUseCase(
      taskId: event.taskId,
      note: event.note,
      authorName: event.authorName,
      authorEmail: event.authorEmail,
    );

    await result.fold(
      (failure) async => emit(TaskNoteError(message: failure.message)),
      (newNote) async {
        // Reload all notes to get the updated list
        final notesResult = await getTaskNotesUseCase(event.taskId);
        notesResult.fold(
          (failure) => emit(TaskNoteError(message: failure.message)),
          (allNotes) => emit(
            TaskNoteAdded(
              note: newNote,
              allNotes: allNotes,
              taskId: event.taskId,
            ),
          ),
        );
      },
    );
  }
}
