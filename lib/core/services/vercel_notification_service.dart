import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

class VercelNotificationService {
  // Your Vercel deployment URL - update this after deploying
  static const String _baseUrl =
      'https://complaints-notifications.vercel.app/api';

  // Send push notification for new task to managers and admins
  Future<Either<Failure, void>> sendNewTaskNotification({
    required String taskId,
    required String taskTitle,
    required String employeeName,
    required String priority,
    required String category,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/send-task-notification');

      final body = {
        'taskId': taskId,
        'taskTitle': taskTitle,
        'employeeName': employeeName,
        'priority': priority,
        'category': category,
      };

      print('Sending task notification to Vercel API...');
      print('URL: $url');
      print('Body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('✅ Task notification sent successfully');
          return const Right(null);
        } else {
          print('❌ API returned success=false');
          return Left(
            ServerFailure(
              message: 'API returned error: ${responseData['error']}',
            ),
          );
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
        return Left(
          ServerFailure(
            message: 'HTTP ${response.statusCode}: ${response.body}',
          ),
        );
      }
    } catch (e) {
      print('❌ Exception sending task notification: $e');
      return Left(
        ServerFailure(message: 'Failed to send task notification: $e'),
      );
    }
  }

  // Send general push notification to topic
  Future<Either<Failure, void>> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/send-notification');

      final requestBody = {
        'topic': topic,
        'title': title,
        'body': body,
        'data': data ?? {},
      };

      print('Sending notification to topic: $topic');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('✅ Notification sent to topic: $topic');
          return const Right(null);
        } else {
          return Left(
            ServerFailure(message: 'API error: ${responseData['error']}'),
          );
        }
      } else {
        return Left(
          ServerFailure(
            message: 'HTTP ${response.statusCode}: ${response.body}',
          ),
        );
      }
    } catch (e) {
      print('❌ Exception sending notification: $e');
      return Left(ServerFailure(message: 'Failed to send notification: $e'));
    }
  }

  // Send notification directly to a specific FCM token
  Future<Either<Failure, void>> sendNotificationToToken({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/send-notification');

      final requestBody = {
        'token': token,
        'title': title,
        'body': body,
        'data': data ?? {},
      };

      print('Sending notification to token: ${token.substring(0, 20)}...');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('✅ Notification sent to token: ${token.substring(0, 20)}...');
          return const Right(null);
        } else {
          return Left(
            ServerFailure(message: 'API error: ${responseData['error']}'),
          );
        }
      } else {
        return Left(
          ServerFailure(
            message: 'HTTP ${response.statusCode}: ${response.body}',
          ),
        );
      }
    } catch (e) {
      print('❌ Exception sending notification: $e');
      return Left(ServerFailure(message: 'Failed to send notification: $e'));
    }
  }

  // Send notification to multiple manager tokens (bypasses topic subscription issues)
  Future<Either<Failure, void>> sendNotificationToManagers({
    required List<String> managerTokens,
    required String taskId,
    required String taskTitle,
    required String employeeName,
    required String priority,
    required String category,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/send-to-managers');

      final requestBody = {
        'tokens': managerTokens,
        'taskId': taskId,
        'taskTitle': taskTitle,
        'employeeName': employeeName,
        'priority': priority,
        'category': category,
      };

      print(
        'Sending task notification to ${managerTokens.length} manager tokens...',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print(
            '✅ Notification sent to ${responseData['sent']}/${responseData['total']} managers',
          );
          return const Right(null);
        } else {
          return Left(
            ServerFailure(message: 'API error: ${responseData['error']}'),
          );
        }
      } else {
        return Left(
          ServerFailure(
            message: 'HTTP ${response.statusCode}: ${response.body}',
          ),
        );
      }
    } catch (e) {
      print('❌ Exception sending notification to managers: $e');
      return Left(
        ServerFailure(message: 'Failed to send notification to managers: $e'),
      );
    }
  }

  // Test the API connection
  Future<Either<Failure, Map<String, dynamic>>> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/health');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Right(data);
      } else {
        return Left(
          ServerFailure(message: 'Health check failed: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Connection test failed: $e'));
    }
  }
}
