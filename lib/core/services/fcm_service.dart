import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_channel_service.dart';
import 'local_notification_service.dart';
import 'navigation_service.dart';
import '../routes/app_routes.dart';

// Background message handler (must be top-level function)
// This is called when app is in background or terminated state
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Initialize and show notification
    await LocalNotificationService.initialize();
    await LocalNotificationService.showNotificationFromFirebase(message);
  } catch (e) {
    // Log error but don't crash
    debugPrint('Error in background notification handler: $e');
  }
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  // Initialize FCM
  static Future<void> initialize() async {
    try {
      // Initialize notification channels first
      await NotificationChannelService.initializeNotificationChannels();

      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        String? token = await _messaging.getToken();
        _fcmToken = token;

        // Setup message handlers
        await _setupMessageHandlers();

        // Subscribe to role-based topics
        await _subscribeToTopics();
      }
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  // Setup message handlers
  static Future<void> _setupMessageHandlers() async {
    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages (when app is opened from notification)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle messages when app is opened from terminated state
      RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('Error setting up message handlers: $e');
    }
  }

  // Subscribe to role-based topics - ONLY AFTER USER LOGIN
  static Future<void> _subscribeToTopics() async {
    try {
      // Topics will be subscribed after user login based on role
      // Use subscribeToUserRole() method after authentication
    } catch (e) {
      debugPrint('Error in topic setup: $e');
    }
  }

  // Handle foreground message
  static void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification for foreground messages
    // Firebase does NOT show notifications automatically when app is in foreground
    try {
      LocalNotificationService.showNotificationFromFirebase(message);
    } catch (e) {
      debugPrint('Error displaying foreground notification: $e');
    }
  }

  // Handle notification tap when user opens the app from a notification
  static void _handleNotificationTap(RemoteMessage message) {
    final String? type = message.data['type'];
    final String? taskId = message.data['taskId'];

    // Navigate based on notification type
    switch (type) {
      case 'new_task':
      case 'task_update':
      case 'urgent_task':
        if (taskId != null && taskId.isNotEmpty) {
          NavigationService.navigateTo(AppRoutes.taskDetail, arguments: taskId);
        } else {
          NavigationService.navigateTo(AppRoutes.notifications);
        }
        break;

      default:
        NavigationService.navigateTo(AppRoutes.notifications);
        break;
    }
  }

  // Get current FCM token
  static String? get fcmToken => _fcmToken;

  // Subscribe to a specific topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from a specific topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  // Save FCM token to Firestore (for user-specific notifications)
  static Future<void> saveFCMTokenToFirestore(String userId) async {
    try {
      if (_fcmToken != null) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId);

        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          final currentData = docSnapshot.data();
          final currentTokens = currentData?['fcmTokens'] as List<dynamic>?;
          final tokenExists = currentTokens?.contains(_fcmToken) ?? false;

          if (!tokenExists) {
            await docRef.update({
              'fcmTokens': FieldValue.arrayUnion([_fcmToken]),
              'lastTokenUpdate': FieldValue.serverTimestamp(),
            });
          }
        } else {
          await docRef.set({
            'fcmTokens': [_fcmToken],
            'lastTokenUpdate': FieldValue.serverTimestamp(),
            'isActive': true,
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  // Remove FCM token from Firestore
  static Future<void> removeFCMTokenFromFirestore(String userId) async {
    try {
      if (_fcmToken != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmTokens': FieldValue.arrayRemove([_fcmToken]),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error removing FCM token: $e');
    }
  }

  // Subscribe to user role-based topics
  static Future<void> subscribeToUserRole(String role) async {
    try {
      // Unsubscribe from all topics first
      await _messaging.unsubscribeFromTopic('managers');
      await _messaging.unsubscribeFromTopic('admins');
      await _messaging.unsubscribeFromTopic('employees');

      // Subscribe based on role
      switch (role.toLowerCase()) {
        case 'admin':
          await _messaging.subscribeToTopic('admins');
          await _messaging.subscribeToTopic(
            'managers',
          ); // Admins see manager notifications too
          break;
        case 'manager':
          await _messaging.subscribeToTopic('managers');
          break;
        case 'employee':
          await _messaging.subscribeToTopic('employees');
          break;
      }
    } catch (e) {
      debugPrint('Error in role-based subscription: $e');
    }
  }

  // Store FCM token (alias for saveFCMTokenToFirestore)
  static Future<void> storeFCMToken(String userId) async {
    await saveFCMTokenToFirestore(userId);
  }

  // Get FCM service status for debugging
  static Map<String, dynamic> getServiceStatus() {
    return {
      'fcmToken': _fcmToken,
      'isInitialized': _fcmToken != null,
      'tokenLength': _fcmToken?.length ?? 0,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Force re-initialization (for debugging)
  static Future<void> reinitialize() async {
    _fcmToken = null;
    await initialize();
  }

  // Test foreground message handler manually
  static void testForegroundHandler() {
    final testMessage = RemoteMessage(
      messageId: 'manual-test-${DateTime.now().millisecondsSinceEpoch}',
      from: 'projects/complaints-712af',
      notification: const RemoteNotification(
        title: 'Test Message',
        body: 'This is a manually triggered test message',
      ),
      data: {
        'type': 'manual_test',
        'priority': 'High',
        'timestamp': DateTime.now().toIso8601String(),
      },
      sentTime: DateTime.now(),
    );

    _handleForegroundMessage(testMessage);
  }
}
