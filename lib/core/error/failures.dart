import 'package:equatable/equatable.dart';
import 'exceptions.dart';

// Base failure class
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// Server failure
class ServerFailure extends Failure {
  final int? statusCode;
  final dynamic data;

  const ServerFailure({required String message, this.statusCode, this.data})
    : super(message: message, code: statusCode);

  @override
  List<Object?> get props => [message, statusCode, data];
}

// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

// Authentication failure
class AuthenticationFailure extends Failure {
  final String? authCode;

  const AuthenticationFailure({required String message, this.authCode})
    : super(message: message);

  @override
  List<Object?> get props => [message, authCode];
}

// Validation failure
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({required String message, this.fieldErrors})
    : super(message: message);

  @override
  List<Object?> get props => [message, fieldErrors];
}

// File failure
class FileFailure extends Failure {
  final String? filePath;

  const FileFailure({required String message, this.filePath})
    : super(message: message);

  @override
  List<Object?> get props => [message, filePath];
}

// Permission failure
class PermissionFailure extends Failure {
  final String? permission;

  const PermissionFailure({required String message, this.permission})
    : super(message: message);

  @override
  List<Object?> get props => [message, permission];
}

// Storage failure
class StorageFailure extends Failure {
  final String? storageCode;

  const StorageFailure({required String message, this.storageCode})
    : super(message: message);

  @override
  List<Object?> get props => [message, storageCode];
}

// Task failure
class TaskFailure extends Failure {
  final String? taskId;

  const TaskFailure({required String message, this.taskId})
    : super(message: message);

  @override
  List<Object?> get props => [message, taskId];
}

// User failure
class UserFailure extends Failure {
  final String? userId;

  const UserFailure({required String message, this.userId})
    : super(message: message);

  @override
  List<Object?> get props => [message, userId];
}

// Database failure
class DatabaseFailure extends Failure {
  final String? query;

  const DatabaseFailure({required String message, this.query})
    : super(message: message);

  @override
  List<Object?> get props => [message, query];
}

// Configuration failure
class ConfigurationFailure extends Failure {
  final String? configuration;

  const ConfigurationFailure({required String message, this.configuration})
    : super(message: message);

  @override
  List<Object?> get props => [message, configuration];
}

// Timeout failure
class TimeoutFailure extends Failure {
  final Duration? timeout;

  const TimeoutFailure({required String message, this.timeout})
    : super(message: message);

  @override
  List<Object?> get props => [message, timeout];
}

// Unknown failure
class UnknownFailure extends Failure {
  final dynamic originalError;

  const UnknownFailure({required String message, this.originalError})
    : super(message: message);

  @override
  List<Object?> get props => [message, originalError];
}

// Failure utilities
class FailureUtils {
  // Convert exception to failure
  static Failure exceptionToFailure(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(
        message: exception.message,
        statusCode: exception.statusCode,
        data: exception.data,
      );
    } else if (exception is CacheException) {
      return CacheFailure(message: exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    } else if (exception is AuthenticationException) {
      return AuthenticationFailure(
        message: exception.message,
        authCode: exception.code,
      );
    } else if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        fieldErrors: exception.fieldErrors,
      );
    } else if (exception is FileException) {
      return FileFailure(
        message: exception.message,
        filePath: exception.filePath,
      );
    } else if (exception is PermissionException) {
      return PermissionFailure(
        message: exception.message,
        permission: exception.permission,
      );
    } else if (exception is StorageException) {
      return StorageFailure(
        message: exception.message,
        storageCode: exception.code,
      );
    } else if (exception is TaskException) {
      return TaskFailure(message: exception.message, taskId: exception.taskId);
    } else if (exception is UserException) {
      return UserFailure(message: exception.message, userId: exception.userId);
    } else if (exception is DatabaseException) {
      return DatabaseFailure(
        message: exception.message,
        query: exception.query,
      );
    } else if (exception is ConfigurationException) {
      return ConfigurationFailure(
        message: exception.message,
        configuration: exception.configuration,
      );
    } else if (exception is TimeoutException) {
      return TimeoutFailure(
        message: exception.message,
        timeout: exception.timeout,
      );
    } else {
      return UnknownFailure(
        message: 'An unknown error occurred: ${exception.toString()}',
        originalError: exception,
      );
    }
  }

  // Get user-friendly message
  static String getUserFriendlyMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Please check your internet connection and try again.';
      case AuthenticationFailure:
        return 'Authentication failed. Please login again.';
      case ValidationFailure:
        return failure.message;
      case FileFailure:
        return 'File operation failed. Please try again.';
      case PermissionFailure:
        return 'Permission required. Please grant the necessary permissions.';
      case StorageFailure:
        return 'Storage operation failed. Please try again.';
      case TaskFailure:
        return 'Task operation failed. Please try again.';
      case UserFailure:
        return 'User operation failed. Please try again.';
      case DatabaseFailure:
        return 'Database operation failed. Please try again.';
      case TimeoutFailure:
        return 'Operation timed out. Please try again.';
      case ServerFailure:
        final serverFailure = failure as ServerFailure;
        if (serverFailure.statusCode != null) {
          switch (serverFailure.statusCode) {
            case 400:
              return 'Bad request. Please check your input.';
            case 401:
              return 'Unauthorized. Please login again.';
            case 403:
              return 'Access forbidden. You don\'t have permission.';
            case 404:
              return 'Resource not found.';
            case 500:
              return 'Server error. Please try again later.';
            case 503:
              return 'Service unavailable. Please try again later.';
            default:
              return failure.message;
          }
        }
        return failure.message;
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

// Exception to Failure extension
extension ExceptionExtension on Exception {
  Failure toFailure() => FailureUtils.exceptionToFailure(this);
}
