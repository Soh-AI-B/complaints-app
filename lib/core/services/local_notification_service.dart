import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Initialize local notifications
  static Future<void> initialize() async {
    if (_initialized) return;

    print('🔔 LocalNotificationService: Initializing...');

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
    print('🔔 LocalNotificationService: Initialized successfully');
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Request notification permission for Android 13+
      final PermissionStatus status = await Permission.notification.request();
      print('🔔 Notification permission status: $status');

      // Request exact alarm permission for scheduled notifications
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
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

    print('🔔 Notification channels created');
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = json.decode(response.payload!);
        print('🔔 Notification data: $data');

        // Handle navigation based on notification data
        // You can implement navigation logic here
      } catch (e) {
        print('🔔 Error parsing notification payload: $e');
      }
    }
  }

  // Show notification for Firebase message
  static Future<void> showNotificationFromFirebase(
    RemoteMessage message,
  ) async {
    print('🔔 === showNotificationFromFirebase CALLED ===');
    print('🔔 Initialized status: $_initialized');

    await initialize();

    final String channelId = _getChannelId(message.data);

    // Get title and body from notification payload OR data payload
    // Data payload takes priority (for data-only messages to avoid duplicates)
    final String title =
        message.data['title'] ??
        message.notification?.title ??
        'New Notification';
    final String body =
        message.data['body'] ?? message.notification?.body ?? '';

    print('🔔 === SHOWING LOCAL NOTIFICATION ===');
    print('🔔 Channel: $channelId');
    print('🔔 Title: $title');
    print('🔔 Body: $body');
    print('🔔 Data: ${message.data}');
    print(
      '🔔 Plugin initialized: ${_flutterLocalNotificationsPlugin.toString()}',
    );

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

    print('🔔 About to show notification with ID: $notificationId');
    print('🔔 Notification details: title="$title", body="$body"');

    try {
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: json.encode(message.data),
      );

      print(
        '🔔 ✅ Local notification displayed successfully with ID: $notificationId',
      );
      print(
        '🔔 ✅ Notification should now appear in your device notification panel!',
      );
    } catch (e) {
      print('🔔 ❌ ERROR showing local notification: $e');
      print('🔔 ❌ This might be a permission or initialization issue');
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

    print('🔔 Test notification shown');
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
