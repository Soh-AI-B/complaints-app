import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task.dart' as entities;

class TaskModel extends entities.Task {
  const TaskModel({
    required super.taskId,
    required super.title,
    required super.description,
    required super.category,
    required super.priority,
    required super.employeeName,
    required super.employeeEmail,
    required super.dateReported,
    super.pictureUrl, // Keep for backward compatibility
    super.pictureUrls, // New field for multiple images
    required super.status,
    super.assignedTo,
    required super.dateUpdated,
    super.estimatedCompletion,
  });

  // Create from JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['task_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      employeeName: json['employee_name'] as String,
      employeeEmail: json['employee_email'] as String,
      dateReported: _parseDateTime(json['date_reported']),
      pictureUrl:
          json['picture_url'] as String?, // Keep for backward compatibility
      pictureUrls: json['picture_urls'] != null
          ? List<String>.from(json['picture_urls'] as List)
          : null,
      status: json['status'] as String,
      assignedTo: json['assigned_to'] as String?,
      dateUpdated: _parseDateTime(json['date_updated']),
      estimatedCompletion: json['estimated_completion'] != null
          ? _parseDateTime(json['estimated_completion'])
          : null,
    );
  }

  // Create from Firestore document
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      taskId: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      priority: data['priority'] as String,
      employeeName: data['employee_name'] as String,
      employeeEmail: data['employee_email'] as String,
      dateReported: (data['date_reported'] as Timestamp).toDate(),
      pictureUrl:
          data['picture_url'] as String?, // Keep for backward compatibility
      pictureUrls: data['picture_urls'] != null
          ? List<String>.from(data['picture_urls'] as List)
          : null,
      status: data['status'] as String,
      assignedTo: data['assigned_to'] as String?,
      dateUpdated: (data['date_updated'] as Timestamp).toDate(),
      estimatedCompletion: data['estimated_completion'] != null
          ? (data['estimated_completion'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'employee_name': employeeName,
      'employee_email': employeeEmail,
      'date_reported': _dateTimeToString(dateReported),
      'picture_url': pictureUrl, // Keep for backward compatibility
      'picture_urls': pictureUrls, // New field for multiple images
      'status': status,
      'assigned_to': assignedTo,
      'date_updated': _dateTimeToString(dateUpdated),
      'estimated_completion': estimatedCompletion != null
          ? _dateTimeToString(estimatedCompletion!)
          : null,
    };
  }

  // Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'employee_name': employeeName,
      'employee_email': employeeEmail,
      'date_reported': Timestamp.fromDate(dateReported),
      'picture_url': pictureUrl, // Keep for backward compatibility
      'picture_urls': pictureUrls, // New field for multiple images
      'status': status,
      'assigned_to': assignedTo,
      'date_updated': Timestamp.fromDate(dateUpdated),
      'estimated_completion': estimatedCompletion != null
          ? Timestamp.fromDate(estimatedCompletion!)
          : null,
    };
  }

  // Convert to Task entity
  entities.Task toEntity() {
    return entities.Task(
      taskId: taskId,
      title: title,
      description: description,
      category: category,
      priority: priority,
      employeeName: employeeName,
      employeeEmail: employeeEmail,
      dateReported: dateReported,
      pictureUrl: pictureUrl, // Keep for backward compatibility
      pictureUrls: pictureUrls, // New field for multiple images
      status: status,
      assignedTo: assignedTo,
      dateUpdated: dateUpdated,
      estimatedCompletion: estimatedCompletion,
    );
  }

  // Create from Task entity
  factory TaskModel.fromEntity(entities.Task task) {
    return TaskModel(
      taskId: task.taskId,
      title: task.title,
      description: task.description,
      category: task.category,
      priority: task.priority,
      employeeName: task.employeeName,
      employeeEmail: task.employeeEmail,
      dateReported: task.dateReported,
      pictureUrl: task.pictureUrl, // Keep for backward compatibility
      pictureUrls: task.pictureUrls, // New field for multiple images
      status: task.status,
      assignedTo: task.assignedTo,
      dateUpdated: task.dateUpdated,
      estimatedCompletion: task.estimatedCompletion,
    );
  }

  // Copy with method
  @override
  TaskModel copyWith({
    String? taskId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? employeeName,
    String? employeeEmail,
    DateTime? dateReported,
    String? pictureUrl,
    List<String>? pictureUrls,
    String? status,
    String? assignedTo,
    DateTime? dateUpdated,
    DateTime? estimatedCompletion,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      employeeName: employeeName ?? this.employeeName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      dateReported: dateReported ?? this.dateReported,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      pictureUrls: pictureUrls ?? this.pictureUrls,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
    );
  }

  // Helper method to parse DateTime from string
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.parse(value);
    } else if (value is Timestamp) {
      return value.toDate();
    } else {
      return DateTime.now();
    }
  }

  // Helper method to convert DateTime to string
  static String _dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
