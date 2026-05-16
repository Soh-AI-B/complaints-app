import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/tasks/create_task_usecase.dart';
import '../../../domain/usecases/tasks/get_tasks_usecase.dart';
import '../../../domain/usecases/tasks/get_tasks_for_manager_usecase.dart';
import '../../../domain/usecases/tasks/get_task_by_id_usecase.dart';
import '../../../domain/usecases/tasks/update_task_usecase.dart';
import '../../../domain/usecases/tasks/delete_task_usecase.dart';
import '../../../domain/usecases/tasks/auto_cleanup_completed_tasks_usecase.dart';
import '../../../domain/usecases/notifications/send_new_task_notification_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final GetTasksForManagerUseCase getTasksForManagerUseCase;
  final GetTaskByIdUseCase getTaskByIdUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final AutoCleanupCompletedTasksUseCase autoCleanupCompletedTasksUseCase;
  final SendNewTaskNotificationUseCase sendNewTaskNotificationUseCase;

  TaskBloc({
    required this.getTasksUseCase,
    required this.getTasksForManagerUseCase,
    required this.getTaskByIdUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.autoCleanupCompletedTasksUseCase,
    required this.sendNewTaskNotificationUseCase,
  }) : super(const TaskInitial()) {
    on<LoadAllTasks>(_onLoadAllTasks);
    on<LoadTasksByUser>(_onLoadTasksByUser);
    on<LoadTasksForManager>(_onLoadTasksForManager);
    on<LoadTaskById>(_onLoadTaskById);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<AutoCleanupCompletedTasks>(_onAutoCleanupCompletedTasks);
    on<LoadTasksByStatus>(_onLoadTasksByStatus);
    on<LoadTasksByPriority>(_onLoadTasksByPriority);
    on<LoadTasksByCategory>(_onLoadTasksByCategory);
    on<RefreshTasks>(_onRefreshTasks);
  }

  Future<void> _onLoadAllTasks(
    LoadAllTasks event,
    Emitter<TaskState> emit,
  ) async {
    developer.log('TaskBloc: Loading all tasks...');
    if (state is! TasksLoaded) {
      emit(const TaskLoading());
    }

    final result = await getTasksUseCase(
      limit: event.limit,
      lastTaskId: event.lastTaskId,
    );

    result.fold(
      (failure) {
        developer.log('TaskBloc: Error loading tasks - ${failure.message}');
        emit(TaskError(message: failure.message));
      },
      (tasks) {
        developer.log('TaskBloc: Loaded ${tasks.length} tasks');
        emit(
          TasksLoaded(
            tasks: tasks,
            hasMore: tasks.length == (event.limit ?? 20),
            lastTaskId: tasks.isNotEmpty ? tasks.last.taskId : null,
          ),
        );
      },
    );
  }

  Future<void> _onLoadTasksByUser(
    LoadTasksByUser event,
    Emitter<TaskState> emit,
  ) async {
    if (state is! TasksLoaded) {
      emit(const TaskLoading());
    }

    final result = await getTasksUseCase(
      employeeEmail: event.employeeEmail,
      limit: event.limit,
      lastTaskId: event.lastTaskId,
    );

    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (tasks) => emit(
        TasksLoaded(
          tasks: tasks,
          hasMore: tasks.length == (event.limit ?? 20),
          lastTaskId: tasks.isNotEmpty ? tasks.last.taskId : null,
        ),
      ),
    );
  }

  Future<void> _onLoadTasksForManager(
    LoadTasksForManager event,
    Emitter<TaskState> emit,
  ) async {
    developer.log('TaskBloc: Loading tasks for manager (category-filtered)...');
    if (state is! TasksLoaded) {
      emit(const TaskLoading());
    }

    final result = await getTasksForManagerUseCase(
      limit: event.limit,
      lastTaskId: event.lastTaskId,
    );

    result.fold(
      (failure) {
        developer.log(
          'TaskBloc: Error loading tasks for manager - ${failure.message}',
        );
        emit(TaskError(message: failure.message));
      },
      (tasks) {
        developer.log('TaskBloc: Loaded ${tasks.length} tasks for manager');
        emit(
          TasksLoaded(
            tasks: tasks,
            hasMore: tasks.length == (event.limit ?? 20),
            lastTaskId: tasks.isNotEmpty ? tasks.last.taskId : null,
          ),
        );
      },
    );
  }

  Future<void> _onLoadTaskById(
    LoadTaskById event,
    Emitter<TaskState> emit,
  ) async {
    developer.log('TaskBloc: Loading task by ID: ${event.taskId}');
    emit(const TaskLoading());

    final result = await getTaskByIdUseCase(event.taskId);

    result.fold(
      (failure) {
        developer.log(
          'TaskBloc: Error loading task by ID - ${failure.message}',
        );
        emit(TaskError(message: failure.message));
      },
      (task) {
        developer.log('TaskBloc: Loaded task by ID: ${task.title}');
        emit(TaskLoaded(task: task));
      },
    );
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    emit(const TaskLoading());

    final result = await createTaskUseCase(
      title: event.title,
      description: event.description,
      category: event.category,
      priority: event.priority,
      employeeName: event.employeeName,
      employeeEmail: event.employeeEmail,
      pictureUrl: event.pictureUrl, // Keep for backward compatibility
      pictureUrls: event.pictureUrls, // New field for multiple images
      estimatedCompletion: event.estimatedCompletion,
    );

    await result.fold(
      (failure) async => emit(TaskError(message: failure.message)),
      (task) async {
        // Emit task created successfully
        emit(TaskCreated(task: task));

        // Send notifications to managers and admins
        try {
          developer.log(
            '🔔 TaskBloc: About to send notifications for task: ${task.taskId}',
          );
          developer.log('🔔 TaskBloc: Task title: ${task.title}');
          developer.log('🔔 TaskBloc: Employee: ${task.employeeName}');

          final notificationResult = await sendNewTaskNotificationUseCase(task);
          notificationResult.fold(
            (failure) {
              // Log notification failure but don't fail the task creation
              developer.log(
                '🔔 TaskBloc: ❌ Failed to send notifications: ${failure.message}',
              );
            },
            (notifications) {
              developer.log(
                '🔔 TaskBloc: ✅ Sent ${notifications.length} notifications for new task ${task.taskId}',
              );
            },
          );
        } catch (e) {
          // Log notification failure but don't fail the task creation
          developer.log('🔔 TaskBloc: ❌ Exception sending notifications: $e');
        }
      },
    );
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    final previousState = state;

    final result = await updateTaskUseCase(
      taskId: event.taskId,
      title: event.title,
      description: event.description,
      category: event.category,
      priority: event.priority,
      status: event.status,
      assignedTo: event.assignedTo,
      estimatedCompletion: event.estimatedCompletion,
      pictureUrl: event.pictureUrl, // Keep for backward compatibility
      pictureUrls: event.pictureUrls, // New field for multiple images
    );

    result.fold((failure) => emit(TaskError(message: failure.message)), (task) {
      if (previousState is TasksLoaded) {
        final updatedTasks = previousState.tasks
            .map(
              (currentTask) =>
                  currentTask.taskId == task.taskId ? task : currentTask,
            )
            .toList();
        emit(
          TasksLoaded(
            tasks: updatedTasks,
            hasMore: previousState.hasMore,
            lastTaskId: previousState.lastTaskId,
          ),
        );
        return;
      }
      emit(TaskUpdated(task: task));
    });
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    developer.log(
      '🗑️ TaskBloc: Delete task requested for ${event.taskId} by ${event.userRole}',
    );
    final previousState = state;

    final result = await deleteTaskUseCase(
      taskId: event.taskId,
      userRole: event.userRole,
    );

    result.fold(
      (failure) {
        developer.log('🗑️ TaskBloc: Delete failed: ${failure.message}');
        emit(TaskError(message: failure.message));
      },
      (_) {
        developer.log('🗑️ TaskBloc: Delete successful for ${event.taskId}');
        if (previousState is TasksLoaded) {
          emit(
            TasksLoaded(
              tasks: previousState.tasks
                  .where((task) => task.taskId != event.taskId)
                  .toList(),
              hasMore: previousState.hasMore,
              lastTaskId: previousState.lastTaskId,
            ),
          );
          return;
        }
        emit(
          TaskDeleted(
            taskId: event.taskId,
            message: 'Task deleted successfully',
          ),
        );
      },
    );
  }

  Future<void> _onAutoCleanupCompletedTasks(
    AutoCleanupCompletedTasks event,
    Emitter<TaskState> emit,
  ) async {
    developer.log('🧹 TaskBloc: Starting auto-cleanup of completed tasks...');
    emit(const TaskLoading());

    final result = await autoCleanupCompletedTasksUseCase(
      completedTasksRetentionDays: event.completedTasksRetentionDays ?? 30,
      cancelledTasksRetentionDays: event.cancelledTasksRetentionDays ?? 7,
    );

    result.fold(
      (failure) {
        developer.log('🧹 TaskBloc: Auto-cleanup failed: ${failure.message}');
        emit(TaskError(message: failure.message));
      },
      (cleanupResult) {
        developer.log(
          '🧹 TaskBloc: Auto-cleanup completed - ${cleanupResult.deletedTasksCount} tasks deleted',
        );
        emit(
          TasksAutoCleanupCompleted(
            deletedTasksCount: cleanupResult.deletedTasksCount,
            deletedImagesCount: cleanupResult.deletedImagesCount,
            errors: cleanupResult.errors,
            completedAt: cleanupResult.completedAt,
          ),
        );
      },
    );
  }

  Future<void> _onLoadTasksByStatus(
    LoadTasksByStatus event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    final result = await getTasksUseCase(
      status: event.status,
      limit: event.limit,
      lastTaskId: event.lastTaskId,
    );

    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (tasks) => emit(
        TasksLoaded(
          tasks: tasks,
          hasMore: tasks.length == (event.limit ?? 20),
          lastTaskId: tasks.isNotEmpty ? tasks.last.taskId : null,
        ),
      ),
    );
  }

  Future<void> _onLoadTasksByPriority(
    LoadTasksByPriority event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    final result = await getTasksUseCase(
      priority: event.priority,
      limit: event.limit,
      lastTaskId: event.lastTaskId,
    );

    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (tasks) => emit(
        TasksLoaded(
          tasks: tasks,
          hasMore: tasks.length == (event.limit ?? 20),
          lastTaskId: tasks.isNotEmpty ? tasks.last.taskId : null,
        ),
      ),
    );
  }

  Future<void> _onLoadTasksByCategory(
    LoadTasksByCategory event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());

    final result = await getTasksUseCase(
      category: event.category,
      limit: event.limit,
      lastTaskId: event.lastTaskId,
    );

    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (tasks) => emit(
        TasksLoaded(
          tasks: tasks,
          hasMore: tasks.length == (event.limit ?? 20),
          lastTaskId: tasks.isNotEmpty ? tasks.last.taskId : null,
        ),
      ),
    );
  }

  Future<void> _onRefreshTasks(
    RefreshTasks event,
    Emitter<TaskState> emit,
  ) async {
    if (state is TasksLoaded) {
      emit(TaskRefreshing(currentTasks: (state as TasksLoaded).tasks));
    } else {
      emit(const TaskLoading());
    }

    final result = await getTasksUseCase();

    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (tasks) => emit(
        TasksLoaded(
          tasks: tasks,
          hasMore: tasks.length >= 20,
          lastTaskId: tasks.isNotEmpty ? tasks.last.taskId : null,
        ),
      ),
    );
  }
}
