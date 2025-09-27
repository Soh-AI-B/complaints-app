import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task.dart';

class TaskNoteModel {
  final String noteId;
  final String taskId;
  final String note;
  final String authorName;
  final String authorEmail;
  final DateTime createdAt;

  const TaskNoteModel({
    required this.noteId,
    required this.taskId,
    required this.note,
    required this.authorName,
    required this.authorEmail,
    required this.createdAt,
  });

  // Create from TaskNote entity
  factory TaskNoteModel.fromEntity(
    TaskNote taskNote,
    String taskId,
    String noteId,
  ) {
    return TaskNoteModel(
      noteId: noteId,
      taskId: taskId,
      note: taskNote.note,
      authorName: taskNote.authorName,
      authorEmail: taskNote.authorEmail,
      createdAt: taskNote.createdAt,
    );
  }

  // Convert to TaskNote entity
  TaskNote toEntity() {
    return TaskNote(
      note: note,
      authorName: authorName,
      authorEmail: authorEmail,
      createdAt: createdAt,
    );
  }

  // Create from Firestore document
  factory TaskNoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskNoteModel(
      noteId: doc.id,
      taskId: data['task_id'] as String,
      note: data['note'] as String,
      authorName: data['author_name'] as String,
      authorEmail: data['author_email'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'task_id': taskId,
      'note': note,
      'author_name': authorName,
      'author_email': authorEmail,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Create from JSON
  factory TaskNoteModel.fromJson(Map<String, dynamic> json) {
    return TaskNoteModel(
      noteId: json['note_id'] as String,
      taskId: json['task_id'] as String,
      note: json['note'] as String,
      authorName: json['author_name'] as String,
      authorEmail: json['author_email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'note_id': noteId,
      'task_id': taskId,
      'note': note,
      'author_name': authorName,
      'author_email': authorEmail,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
