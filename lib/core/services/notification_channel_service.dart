import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to handle Android notification channels
class NotificationChannelService {
  static const MethodChannel _channel = MethodChannel('notification_channels');

  /// Initialize notification channels for Android
  static Future<void> initializeNotificationChannels() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      await _channel.invokeMethod('createNotificationChannels');
    } catch (e) {
      debugPrint('Failed to create notification channels: $e');
    }
  }

  /// Create a specific notification channel
  static Future<void> createChannel({
    required String channelId,
    required String channelName,
    required String channelDescription,
    String importance = 'high',
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      await _channel.invokeMethod('createChannel', {
        'channelId': channelId,
        'channelName': channelName,
        'channelDescription': channelDescription,
        'importance': importance,
      });
    } catch (e) {
      debugPrint('Failed to create channel $channelId: $e');
    }
  }
}
