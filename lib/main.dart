import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';
import 'injection_container.dart' as di;
import 'core/services/fcm_service.dart';
import 'core/services/local_notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    print('Firebase initialized successfully');

    // Request notification permissions
    await _requestNotificationPermissions();

    // Initialize local notifications FIRST
    await LocalNotificationService.initialize();
    print('Local notifications initialized successfully');

    // Initialize FCM service
    await FCMService.initialize();
    print('FCM initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    print('App will run without Firebase features');
  }

  // Initialize dependency injection with Firebase status
  await di.init(firebaseAvailable: firebaseInitialized);

  runApp(const ComplaintsApp());
}

Future<void> _requestNotificationPermissions() async {
  try {
    // Request notification permission
    PermissionStatus status = await Permission.notification.request();
    print('Notification permission status: $status');

    if (status.isGranted) {
      print('Notification permission granted');
    } else if (status.isDenied) {
      print('Notification permission denied');
    } else if (status.isPermanentlyDenied) {
      print('Notification permission permanently denied');
    }
  } catch (e) {
    print('Error requesting notification permissions: $e');
  }
}
