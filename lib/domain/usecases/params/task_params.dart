import 'package:equatable/equatable.dart';

// Base class for task parameters
abstract class TaskParams extends Equatable {
  const TaskParams();
}

// Parameters for getting tasks
class GetTasksParams extends TaskParams {
  final String? userId;
  final String? status;
  final String? priority;
  final String? category;
  final String? assignedTo;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;
  final String? lastDocumentId;

  const GetTasksParams({
    this.userId,
    this.status,
    this.priority,
    this.category,
    this.assignedTo,
    this.startDate,
    this.endDate,
    this.limit,
    this.lastDocumentId,
  });

  @override
  List<Object?> get props => [
    userId,
    status,
    priority,
    category,
    assignedTo,
    startDate,
    endDate,
    limit,
    lastDocumentId,
  ];
}

// Parameters for creating a task
class CreateTaskParams extends TaskParams {
  final String title;
  final String description;
  final String priority;
  final String category;
  final String employeeName;
  final String employeeEmail;
  final String? assignedTo;
  final DateTime? dueDate;
  final List<String>? attachments;
  final String? location;
  final String? department;

  const CreateTaskParams({
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.employeeName,
    required this.employeeEmail,
    this.assignedTo,
    this.dueDate,
    this.attachments,
    this.location,
    this.department,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    priority,
    category,
    employeeName,
    employeeEmail,
    assignedTo,
    dueDate,
    attachments,
    location,
    department,
  ];
}

// Parameters for updating a task
class UpdateTaskParams extends TaskParams {
  final String taskId;
  final String? title;
  final String? description;
  final String? priority;
  final String? status;
  final String? category;
  final String? assignedTo;
  final DateTime? dueDate;
  final List<String>? attachments;
  final String? location;
  final String? department;
  final String? resolution;
  final String? feedback;
  final double? rating;

  const UpdateTaskParams({
    required this.taskId,
    this.title,
    this.description,
    this.priority,
    this.status,
    this.category,
    this.assignedTo,
    this.dueDate,
    this.attachments,
    this.location,
    this.department,
    this.resolution,
    this.feedback,
    this.rating,
  });

  @override
  List<Object?> get props => [
    taskId,
    title,
    description,
    priority,
    status,
    category,
    assignedTo,
    dueDate,
    attachments,
    location,
    department,
    resolution,
    feedback,
    rating,
  ];
}

// Parameters for deleting a task
class DeleteTaskParams extends TaskParams {
  final String taskId;

  const DeleteTaskParams({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

// Parameters for searching tasks
class SearchTasksParams extends TaskParams {
  final String query;
  final String? userId;
  final List<String>? categories;
  final List<String>? priorities;
  final List<String>? statuses;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;

  const SearchTasksParams({
    required this.query,
    this.userId,
    this.categories,
    this.priorities,
    this.statuses,
    this.startDate,
    this.endDate,
    this.limit,
  });

  @override
  List<Object?> get props => [
    query,
    userId,
    categories,
    priorities,
    statuses,
    startDate,
    endDate,
    limit,
  ];
}

// Parameters for getting task statistics
class GetTaskStatisticsParams extends TaskParams {
  final String? userId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? department;

  const GetTaskStatisticsParams({
    this.userId,
    this.startDate,
    this.endDate,
    this.department,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate, department];
}

// Parameters for bulk task operations
class BulkTaskParams extends TaskParams {
  final List<String> taskIds;
  final String operation; // 'delete', 'update_status', 'assign'
  final Map<String, dynamic>? updateData;

  const BulkTaskParams({
    required this.taskIds,
    required this.operation,
    this.updateData,
  });

  @override
  List<Object?> get props => [taskIds, operation, updateData];
}

// Parameters for exporting tasks
class ExportTasksParams extends TaskParams {
  final String? userId;
  final List<String>? taskIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final String format; // 'csv', 'pdf', 'excel'
  final Map<String, bool>? includeFields;

  const ExportTasksParams({
    this.userId,
    this.taskIds,
    this.startDate,
    this.endDate,
    required this.format,
    this.includeFields,
  });

  @override
  List<Object?> get props => [
    userId,
    taskIds,
    startDate,
    endDate,
    format,
    includeFields,
  ];
}
