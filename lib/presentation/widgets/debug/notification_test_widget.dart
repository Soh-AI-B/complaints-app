import 'package:flutter/material.dart';
import '../../../core/services/vercel_notification_service.dart';
import '../../../core/services/local_notification_service.dart';

class NotificationTestWidget extends StatelessWidget {
  const NotificationTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                print('🧪 Testing Vercel Backend Connection...');
                final service = VercelNotificationService();
                final result = await service.testConnection();

                result.fold(
                  (failure) {
                    print('❌ Connection test failed: ${failure.message}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '❌ Connection failed: ${failure.message}',
                        ),
                      ),
                    );
                  },
                  (data) {
                    print('✅ Connection test successful: $data');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Backend connection OK')),
                    );
                  },
                );
              },
              child: const Text('Test Backend Connection'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                print('🧪 Testing Topic-based Notification...');
                final service = VercelNotificationService();
                final result = await service.sendNewTaskNotification(
                  taskId: 'test-task-123',
                  taskTitle: 'Test Task From Debug',
                  employeeName: 'Test Employee',
                  priority: 'High',
                  category: 'Test',
                );

                result.fold(
                  (failure) {
                    print('❌ Topic notification failed: ${failure.message}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '❌ Topic notification failed: ${failure.message}',
                        ),
                      ),
                    );
                  },
                  (_) {
                    print('✅ Topic notification sent successfully');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Topic notification sent'),
                      ),
                    );
                  },
                );
              },
              child: const Text('Test Topic-based Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                print('🧪 Testing Manual Local Notification...');
                try {
                  // Import and use LocalNotificationService
                  await LocalNotificationService.showTestNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Local notification shown')),
                  );
                } catch (e) {
                  print('❌ Local notification error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Local notification error: $e')),
                  );
                }
              },
              child: const Text('Test Local Notification'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Debug Steps:\n'
              '1. Test backend connection first\n'
              '2. Test topic-based notification\n'
              '3. Check Vercel logs for activity\n'
              '4. Verify manager device receives notification',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
