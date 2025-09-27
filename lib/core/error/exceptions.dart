// Custom exceptions for the application

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ServerException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  final String? code;

  const AuthenticationException({required this.message, this.code});

  @override
  String toString() => 'AuthenticationException: $message (Code: $code)';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  const ValidationException({required this.message, this.fieldErrors});

  @override
  String toString() => 'ValidationException: $message';
}

class FileException implements Exception {
  final String message;
  final String? filePath;

  const FileException({required this.message, this.filePath});

  @override
  String toString() => 'FileException: $message (File: $filePath)';
}

class PermissionException implements Exception {
  final String message;
  final String? permission;

  const PermissionException({required this.message, this.permission});

  @override
  String toString() =>
      'PermissionException: $message (Permission: $permission)';
}

class StorageException implements Exception {
  final String message;
  final String? code;

  const StorageException({required this.message, this.code});

  @override
  String toString() => 'StorageException: $message (Code: $code)';
}

class TaskException implements Exception {
  final String message;
  final String? taskId;

  const TaskException({required this.message, this.taskId});

  @override
  String toString() => 'TaskException: $message (Task ID: $taskId)';
}

class UserException implements Exception {
  final String message;
  final String? userId;

  const UserException({required this.message, this.userId});

  @override
  String toString() => 'UserException: $message (User ID: $userId)';
}

class DatabaseException implements Exception {
  final String message;
  final String? query;

  const DatabaseException({required this.message, this.query});

  @override
  String toString() => 'DatabaseException: $message (Query: $query)';
}

class ConfigurationException implements Exception {
  final String message;
  final String? configuration;

  const ConfigurationException({required this.message, this.configuration});

  @override
  String toString() =>
      'ConfigurationException: $message (Config: $configuration)';
}

class TimeoutException implements Exception {
  final String message;
  final Duration? timeout;

  const TimeoutException({required this.message, this.timeout});

  @override
  String toString() => 'TimeoutException: $message (Timeout: $timeout)';
}

class UnknownException implements Exception {
  final String message;
  final dynamic originalException;
  final StackTrace? stackTrace;

  const UnknownException({
    required this.message,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() =>
      'UnknownException: $message (Original: $originalException)';
}
