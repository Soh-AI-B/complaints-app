import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'injection_container.dart' as di;
import 'core/services/fcm_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/web_redirect_service.dart';
import 'core/services/platform_service.dart';

// Background message handler - must be registered before Firebase initialization
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register background message handler BEFORE Firebase initialization
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Firebase
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;

    // Platform-specific initialization
    if (PlatformService.isWeb) {
      // Web-specific initialization
      debugPrint('Firebase initialized for web platform');
    } else {
      // Mobile-specific initialization
      await _requestNotificationPermissions();

      // Initialize local notifications (only for native platforms)
      await LocalNotificationService.initialize();

      // Initialize FCM service (only for native platforms)
      await FCMService.initialize();
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue without Firebase - app will show appropriate error messages
  }

  // Initialize dependency injection
  await di.init(firebaseAvailable: firebaseInitialized);

  runApp(const ComplaintsApp());
}

Future<void> _requestNotificationPermissions() async {
  try {
    await Permission.notification.request();
  } catch (e) {
    debugPrint('Error requesting notification permissions: $e');
  }
}
