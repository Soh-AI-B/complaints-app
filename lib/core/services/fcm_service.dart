import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_channel_service.dart';
import 'local_notification_service.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('FCM: Handling background message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');

  // Initialize local notifications if needed and show notification
  await LocalNotificationService.initialize();
  await LocalNotificationService.showNotificationFromFirebase(message);
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  // Initialize FCM
  static Future<void> initialize() async {
    try {
      print('FCMService: Starting initialization...');

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

      print('FCMService: Permission granted: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('FCMService: User granted permission for notifications');

        // Get FCM token
        String? token = await _messaging.getToken();
        _fcmToken = token;
        print('FCMService: FCM Token: $token');

        // Setup message handlers
        await _setupMessageHandlers();

        // Subscribe to role-based topics
        await _subscribeToTopics();

        print('FCMService: Initialization completed successfully');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('FCMService: User granted provisional permission');
      } else {
        print('FCMService: User declined or has not accepted permission');
      }
    } catch (e) {
      print('FCMService: Error during initialization: $e');
    }
  }

  // Setup message handlers
  static Future<void> _setupMessageHandlers() async {
    try {
      print('FCMService: Setting up message handlers...');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages (when app is opened from notification)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle messages when app is opened from terminated state
      RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        print(
          'FCMService: App opened from terminated state with message: ${initialMessage.messageId}',
        );
        _handleNotificationTap(initialMessage);
      }

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      print('FCMService: Message handlers setup completed');
    } catch (e) {
      print('FCMService: Error setting up message handlers: $e');
    }
  }

  // Subscribe to role-based topics - ONLY AFTER USER LOGIN
  static Future<void> _subscribeToTopics() async {
    try {
      print('FCMService: Initial setup - not subscribing to any topics yet');
      print(
        'FCMService: Topics will be subscribed after user login based on role',
      );
      print(
        'FCMService: Use subscribeToUserRole() method after authentication',
      );
    } catch (e) {
      print('FCMService: ❌ Error in topic setup: $e');
    }
  }

  // Handle foreground message
  static void _handleForegroundMessage(RemoteMessage message) {
    print('🔔🔔🔔 FOREGROUND MESSAGE RECEIVED! 🔔🔔🔔');
    print('🔔 FCMService: Foreground message received');
    print('🔔 Message ID: ${message.messageId}');
    print('🔔 From: ${message.from}');
    print('🔔 Title: ${message.notification?.title}');
    print('🔔 Body: ${message.notification?.body}');
    print('🔔 Data: ${message.data}');
    print('🔔 Category: ${message.category}');
    print('🔔 CollapseKey: ${message.collapseKey}');
    print('🔔 MessageType: ${message.messageType}');
    print('🔔 SentTime: ${message.sentTime}');
    print('🔔 TTL: ${message.ttl}');

    // For testing: Print a prominent message
    print('🔔🔔🔔 NOTIFICATION RECEIVED 🔔🔔🔔');
    print('🔔 ${message.notification?.title}');
    print('🔔 ${message.notification?.body}');
    print('🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔');

    // CRITICAL FIX: Show local notification for foreground messages
    // Firebase does NOT show notifications automatically when app is in foreground
    print(
      '🔔 Calling LocalNotificationService.showNotificationFromFirebase...',
    );
    try {
      LocalNotificationService.showNotificationFromFirebase(message);
      print('🔔 ✅ LocalNotificationService called successfully');
    } catch (e) {
      print('🔔 ❌ Error calling LocalNotificationService: $e');
    }
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('🔔 FCMService: Notification tapped');
    print('🔔 Message ID: ${message.messageId}');
    print('🔔 Title: ${message.notification?.title}');
    print('🔔 Body: ${message.notification?.body}');
    print('🔔 Data: ${message.data}');
    print('🔔 NOTIFICATION WAS TAPPED! 🔔');

    // Here you can navigate to specific screens based on the notification data
    // Example: if message.data contains a route, you can navigate to it
  }

  // Get current FCM token
  static String? get fcmToken => _fcmToken;

  // Subscribe to a specific topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('FCMService: Subscribed to topic: $topic');
    } catch (e) {
      print('FCMService: Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from a specific topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('FCMService: Unsubscribed from topic: $topic');
    } catch (e) {
      print('FCMService: Error unsubscribing from topic $topic: $e');
    }
  }

  // Save FCM token to Firestore (for user-specific notifications)
  static Future<void> saveFCMTokenToFirestore(String userId) async {
    try {
      if (_fcmToken != null) {
        print('FCMService: 📝 Saving FCM token to Firestore for user: $userId');
        print('FCMService: 🔗 Token to save: $_fcmToken');

        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId);

        // Check if user document exists first
        final docSnapshot = await docRef.get();
        print('FCMService: 📋 Document exists: ${docSnapshot.exists}');

        if (docSnapshot.exists) {
          // Get current data to see what's there
          final currentData = docSnapshot.data();
          print(
            'FCMService: 📋 Current user data keys: ${currentData?.keys.toList()}',
          );

          final currentTokens = currentData?['fcmTokens'] as List<dynamic>?;
          print('FCMService: 📋 Current tokens in doc: $currentTokens');

          // Check if token already exists
          final tokenExists = currentTokens?.contains(_fcmToken) ?? false;
          print('FCMService: 📋 Token already exists: $tokenExists');

          if (!tokenExists) {
            // Document exists, just update the FCM tokens
            await docRef.update({
              'fcmTokens': FieldValue.arrayUnion([_fcmToken]),
              'lastTokenUpdate': FieldValue.serverTimestamp(),
            });
            print('FCMService: ✅ FCM token added to existing user document');

            // Verify the update worked - WAIT A MOMENT FOR CONSISTENCY
            await Future.delayed(Duration(milliseconds: 500));
            final updatedSnapshot = await docRef.get();
            final updatedData = updatedSnapshot.data();
            final updatedTokens = updatedData?['fcmTokens'] as List<dynamic>?;
            print(
              'FCMService: ✅ VERIFICATION - Final tokens in doc: $updatedTokens',
            );
            print(
              'FCMService: ✅ VERIFICATION - Token count: ${updatedTokens?.length ?? 0}',
            );
          } else {
            print(
              'FCMService: ℹ️ FCM token already exists in document - no update needed',
            );
          }
        } else {
          // Document doesn't exist - CREATE IT with FCM token
          print(
            'FCMService: 📝 User document not found, creating with FCM token...',
          );
          await docRef.set({
            'fcmTokens': [_fcmToken],
            'lastTokenUpdate': FieldValue.serverTimestamp(),
            'isActive': true,
          }, SetOptions(merge: true));
          print('FCMService: ✅ User document created with FCM token');

          // Verify the creation worked
          await Future.delayed(Duration(milliseconds: 500));
          final createdSnapshot = await docRef.get();
          final createdData = createdSnapshot.data();
          final createdTokens = createdData?['fcmTokens'] as List<dynamic>?;
          print(
            'FCMService: ✅ VERIFICATION - Created tokens in doc: $createdTokens',
          );
        }

        print('FCMService: 🔗 Token save process completed for: $_fcmToken');
      } else {
        print('FCMService: ⚠️ No FCM token available to save');
      }
    } catch (e) {
      print('FCMService: ❌ Error saving FCM token to Firestore: $e');
      print('FCMService: ❌ Error details: $e');
    }
  }

  // Remove FCM token from Firestore
  static Future<void> removeFCMTokenFromFirestore(String userId) async {
    try {
      if (_fcmToken != null) {
        // Use set with merge to ensure document exists before removing token
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmTokens': FieldValue.arrayRemove([_fcmToken]),
        }, SetOptions(merge: true));
        print(
          'FCMService: ✅ FCM token removed from Firestore for user: $userId',
        );
      }
    } catch (e) {
      print('FCMService: ❌ Error removing FCM token from Firestore: $e');
    }
  }

  // Subscribe to user role-based topics
  static Future<void> subscribeToUserRole(String role) async {
    try {
      print('🔔 FCMService: Starting role-based subscription for: $role');

      // Unsubscribe from all topics first
      print('🔔 FCMService: Unsubscribing from all topics first...');
      await _messaging.unsubscribeFromTopic('managers');
      await _messaging.unsubscribeFromTopic('admins');
      await _messaging.unsubscribeFromTopic('employees');
      print('🔔 FCMService: ✅ Unsubscribed from all topics');

      // Subscribe based on role
      switch (role.toLowerCase()) {
        case 'admin':
          print(
            '🔔 FCMService: Subscribing admin to admins + managers topics...',
          );
          await _messaging.subscribeToTopic('admins');
          await _messaging.subscribeToTopic(
            'managers',
          ); // Admins see manager notifications too
          print('🔔 FCMService: ✅ Admin subscribed to: admins, managers');
          break;
        case 'manager':
          print('🔔 FCMService: Subscribing manager to managers topic...');
          await _messaging.subscribeToTopic('managers');
          print('🔔 FCMService: ✅ Manager subscribed to: managers');
          break;
        case 'employee':
          print('🔔 FCMService: Subscribing employee to employees topic...');
          await _messaging.subscribeToTopic('employees');
          print('🔔 FCMService: ✅ Employee subscribed to: employees');
          break;
        default:
          print(
            '🔔 FCMService: ⚠️ Unknown role: $role - no topic subscription',
          );
      }

      print('🔔 FCMService: 🎉 Role-based subscription completed for: $role');
    } catch (e) {
      print('🔔 FCMService: ❌ Error in role-based subscription: $e');
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
    print('FCMService: Force re-initializing...');
    _fcmToken = null;
    await initialize();
  }

  // Test foreground message handler manually
  static void testForegroundHandler() {
    print('🧪 FCMService: Testing foreground handler manually...');

    final testMessage = RemoteMessage(
      messageId: 'manual-test-${DateTime.now().millisecondsSinceEpoch}',
      from: 'projects/complaints-712af',
      notification: const RemoteNotification(
        title: '🧪 Manual Test Message',
        body: 'This is a manually triggered test message',
      ),
      data: {
        'type': 'manual_test',
        'priority': 'High',
        'timestamp': DateTime.now().toIso8601String(),
      },
      sentTime: DateTime.now(),
    );

    print('🧪 Calling _handleForegroundMessage manually...');
    _handleForegroundMessage(testMessage);
  }
}
