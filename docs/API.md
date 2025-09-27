# API Documentation

## Overview

This document describes the API architecture and available endpoints for the Complaints Manager application.

## Architecture

The application uses Firebase as the backend service, providing:
- Authentication via Firebase Auth
- Data storage via Cloud Firestore
- File storage via Firebase Storage
- Push notifications via Firebase Cloud Messaging

## Authentication

### Login
Authenticate user with email and password.

```dart
Future<Either<Failure, AppUser>> login({
  required String email,
  required String password,
});
```

**Parameters:**
- `email`: User's email address
- `password`: User's password

**Returns:**
- `Success`: AppUser object with authentication token
- `Failure`: Authentication error details

### Register
Create a new user account.

```dart
Future<Either<Failure, AppUser>> register({
  required String email,
  required String password,
  required String name,
  required String role,
  required String team,
  String? phone,
});
```

**Parameters:**
- `email`: User's email address
- `password`: User's password
- `name`: User's full name
- `role`: User role (Employee, Manager, Admin)
- `team`: User's team/department
- `phone`: Optional phone number

### Logout
Sign out the current user.

```dart
Future<Either<Failure, void>> logout();
```

## Task Management

### Create Task
Create a new complaint/task.

```dart
Future<Either<Failure, Task>> createTask(Task task);
```

**Parameters:**
- `task`: Task entity with all required fields

**Task Entity:**
```dart
class Task {
  final String taskId;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String employeeName;
  final String employeeEmail;
  final DateTime dateReported;
  final List<String> pictureUrls;
  final String? managerNotes;
  final String? assignedTo;
  final DateTime? estimatedCompletion;
}
```

### Get Tasks
Retrieve tasks based on filters.

```dart
Future<Either<Failure, List<Task>>> getTasks({
  String? status,
  String? priority,
  String? category,
  String? employeeEmail,
  int? limit,
  String? lastTaskId,
});
```

**Parameters:**
- `status`: Filter by task status
- `priority`: Filter by priority level
- `category`: Filter by category
- `employeeEmail`: Filter by employee
- `limit`: Maximum number of tasks to return
- `lastTaskId`: For pagination

### Get Tasks for Manager
Retrieve tasks filtered by manager's assigned categories.

```dart
Future<Either<Failure, List<Task>>> getTasksForManager({
  List<String> managedCategories,
  int? limit,
  String? lastTaskId,
});
```

### Update Task
Update an existing task.

```dart
Future<Either<Failure, Task>> updateTask(Task task);
```

### Delete Task
Delete a task and its associated data.

```dart
Future<Either<Failure, void>> deleteTask(String taskId);
```

## User Management

### Get User Profile
Retrieve user profile information.

```dart
Future<Either<Failure, User>> getUserProfile(String email);
```

### Update User Profile
Update user profile information.

```dart
Future<Either<Failure, User>> updateUserProfile({
  required String email,
  String? name,
  String? phone,
  String? team,
});
```

### Get All Users
Retrieve all users (Admin only).

```dart
Future<Either<Failure, List<User>>> getAllUsers({
  int? limit,
  String? lastUserId,
});
```

### Update User Role
Update user role and managed categories.

```dart
Future<Either<Failure, User>> updateUserRole({
  required String email,
  required String newRole,
  List<String>? managedCategories,
});
```

### Update User Status
Activate or deactivate a user.

```dart
Future<Either<Failure, User>> updateUserStatus({
  required String email,
  required bool isActive,
});
```

## Notifications

### Get Notifications
Retrieve user notifications.

```dart
Future<Either<Failure, List<TaskNotification>>> getNotifications({
  required String userEmail,
  int? limit,
  String? lastNotificationId,
});
```

### Mark Notification as Read
Mark a specific notification as read.

```dart
Future<Either<Failure, void>> markNotificationAsRead({
  required String notificationId,
});
```

### Get Unread Notifications Count
Get count of unread notifications for a user.

```dart
Future<Either<Failure, int>> getUnreadNotificationsCount(String userEmail);
```

## File Upload

### Upload Image
Upload task images to cloud storage.

```dart
Future<Either<Failure, List<String>>> uploadTaskImages({
  required String taskId,
  required List<File> images,
});
```

**Parameters:**
- `taskId`: Associated task ID
- `images`: List of image files

**Returns:**
- `Success`: List of uploaded image URLs
- `Failure`: Upload error details

## Error Handling

All API methods return `Either<Failure, T>` where:
- `Left(Failure)`: Error occurred
- `Right(T)`: Success with data

### Failure Types

```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}
```

## Real-time Updates

The application supports real-time updates through Firebase:

### Task Updates
Tasks are automatically synchronized across all connected clients.

### Notifications
Push notifications are sent for:
- New task assignments
- Task status changes
- Manager notes updates
- System announcements

### Subscription Topics
- `employees`: All employees
- `managers`: All managers
- `admins`: All administrators
- `all_users`: All users

## Rate Limiting

Firebase applies standard rate limiting:
- Firestore: 1 million operations per day (free tier)
- Authentication: 10,000 verifications per day (free tier)
- Storage: 1GB storage, 10GB transfer per day (free tier)

## Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Tasks are accessible to authenticated users
    match /tasks/{taskId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.employeeEmail == request.auth.token.email);
    }
    
    // Notifications for authenticated users
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null &&
        resource.data.userEmail == request.auth.token.email;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /tasks/{taskId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Testing

### API Testing
Use the following endpoints for testing:

```dart
// Test user credentials
final testEmployee = {
  'email': 'employee@test.com',
  'password': 'testpass123',
  'role': 'Employee'
};

final testManager = {
  'email': 'manager@test.com',
  'password': 'testpass123',
  'role': 'Manager'
};

final testAdmin = {
  'email': 'admin@test.com',
  'password': 'testpass123',
  'role': 'Admin'
};
```

### Error Testing
Test error scenarios:
- Invalid credentials
- Network connectivity issues
- Insufficient permissions
- Invalid data formats

## Migration Guide

When updating the API, follow these steps:

1. **Version your changes**: Use semantic versioning
2. **Backward compatibility**: Maintain for at least one major version
3. **Migration scripts**: Provide data migration utilities
4. **Documentation**: Update all relevant documentation
5. **Testing**: Comprehensive testing before release

## Support

For API-related issues:
- Check Firebase console for service status
- Review Firestore security rules
- Validate authentication tokens
- Monitor network connectivity