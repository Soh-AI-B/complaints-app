import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/task.dart' as entities;
import '../../repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<Either<Failure, entities.Task>> call({
    required String title,
    required String description,
    required String category,
    required String priority,
    required String employeeName,
    required String employeeEmail,
    String? pictureUrl, // Keep for backward compatibility
    List<String>? pictureUrls, // New field for multiple images
    DateTime? estimatedCompletion,
  }) async {
    return await repository.createTask(
      title: title,
      description: description,
      category: category,
      priority: priority,
      employeeName: employeeName,
      employeeEmail: employeeEmail,
      pictureUrl: pictureUrl, // Keep for backward compatibility
      pictureUrls: pictureUrls, // New field for multiple images
      estimatedCompletion: estimatedCompletion,
    );
  }
}
