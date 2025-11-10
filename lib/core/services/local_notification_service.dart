import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '../routes/app_routes.dart';
import 'navigation_service.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Initialize local notifications
  static Future<void> initialize() async {
    if (_initialized) return;

    // Request notification permissions first
    await _requestPermissions();

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@android:drawable/ic_dialog_info');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Combined initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    _initialized = true;
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        // Request notification permission for Android 13+
        await Permission.notification.request();

        // Request exact alarm permission for scheduled notifications
        if (await Permission.scheduleExactAlarm.isDenied) {
          await Permission.scheduleExactAlarm.request();
        }
      } catch (e) {
        // In background/terminated state, there's no Activity context
        // This is expected - permissions should already be granted from foreground
        // Continue silently
      }
    }
  }

  // Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    // Default channel
    const AndroidNotificationChannel defaultChannel =
        AndroidNotificationChannel(
          'default',
          'Default Notifications',
          description: 'Default notification channel for general alerts',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          showBadge: true,
        );

    // Urgent tasks channel
    const AndroidNotificationChannel urgentChannel = AndroidNotificationChannel(
      'urgent_tasks',
      'Urgent Tasks',
      description: 'High priority notifications for urgent task reports',
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    // Task updates channel
    const AndroidNotificationChannel updatesChannel =
        AndroidNotificationChannel(
          'task_updates',
          'Task Updates',
          description: 'Notifications for task status updates',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          showBadge: true,
        );

    // Create the channels
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(defaultChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(urgentChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(updatesChannel);
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == null) return;

    try {
      final Map<String, dynamic> data = json.decode(response.payload!);
      _handleNotificationNavigation(data);
    } catch (e) {
      debugPrint('Error parsing notification payload: $e');
    }
  }

  // Handle navigation based on notification data
  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    final String? type = data['type'];
    final String? taskId = data['taskId'];

    switch (type) {
      case 'new_task':
      case 'task_update':
      case 'urgent_task':
        // Navigate to task detail page if taskId exists
        if (taskId != null && taskId.isNotEmpty) {
          _navigateToTaskDetail(taskId);
        } else {
          // If no taskId, go to notifications page
          _navigateToNotifications();
        }
        break;

      default:
        // For other notification types, navigate to notifications page
        _navigateToNotifications();
        break;
    }
  }

  // Navigate to task detail page
  static void _navigateToTaskDetail(String taskId) {
    try {
      NavigationService.navigateTo(AppRoutes.taskDetail, arguments: taskId);
    } catch (e) {
      debugPrint('Error navigating to task detail: $e');
    }
  }

  // Navigate to notifications page
  static void _navigateToNotifications() {
    try {
      NavigationService.navigateTo(AppRoutes.notifications);
    } catch (e) {
      debugPrint('Error navigating to notifications: $e');
    }
  }

  // Show notification for Firebase message
  static Future<void> showNotificationFromFirebase(
    RemoteMessage message,
  ) async {
    await initialize();

    final String channelId = _getChannelId(message.data);

    // Get title and body from data payload FIRST (for data-only messages)
    // Fallback to notification payload if data fields are missing
    final String title =
        message.data['title']?.toString() ??
        message.notification?.title ??
        'New Notification';
    final String body =
        message.data['body']?.toString() ??
        message.notification?.body ??
        'You have a new notification';

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          channelDescription:
              'Notification channel for ${_getChannelName(channelId)}',
          importance: channelId == 'urgent_tasks'
              ? Importance.max
              : Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          enableLights: true,
          autoCancel: true,
          icon: '@android:drawable/ic_dialog_info',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
      100000,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: json.encode(message.data),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
      rethrow;
    }
  }

  // Get appropriate channel ID based on message data
  static String _getChannelId(Map<String, dynamic> data) {
    final String type = data['type'] ?? '';
    final String priority = data['priority'] ?? '';

    if (type == 'new_task' && priority == 'Urgent') {
      return 'urgent_tasks';
    } else if (type == 'task_update') {
      return 'task_updates';
    } else {
      return 'default';
    }
  }

  // Get channel name from channel ID
  static String _getChannelName(String channelId) {
    switch (channelId) {
      case 'urgent_tasks':
        return 'Urgent Tasks';
      case 'task_updates':
        return 'Task Updates';
      default:
        return 'Default Notifications';
    }
  }

  // Show a simple test notification
  static Future<void> showTestNotification() async {
    await initialize();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'default',
          'Default Notifications',
          channelDescription: 'Test notification',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          enableLights: true,
          autoCancel: true,
          icon: '@android:drawable/ic_dialog_info',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification to verify the system is working',
      platformChannelSpecifics,
      payload: json.encode({
        'type': 'test',
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final bool? enabled = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();
      return enabled ?? false;
    }
    return true; // iOS permissions are handled differently
  }
}
