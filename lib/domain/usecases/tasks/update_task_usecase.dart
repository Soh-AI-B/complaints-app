import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/task.dart' as entities;
import '../../repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<Either<Failure, entities.Task>> call({
    required String taskId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? assignedTo,
    DateTime? estimatedCompletion,
    String? pictureUrl, // Keep for backward compatibility
    List<String>? pictureUrls, // New field for multiple images
  }) async {
    return await repository.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      category: category,
      priority: priority,
      status: status,
      assignedTo: assignedTo,
      estimatedCompletion: estimatedCompletion,
      pictureUrl: pictureUrl, // Keep for backward compatibility
      pictureUrls: pictureUrls, // New field for multiple images
    );
  }
}
