package com.example.complaints

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "notification_channels"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "createNotificationChannels" -> {
                    createNotificationChannels()
                    result.success(null)
                }
                "createChannel" -> {
                    val channelId = call.argument<String>("channelId")
                    val channelName = call.argument<String>("channelName")
                    val channelDescription = call.argument<String>("channelDescription")
                    val importance = call.argument<String>("importance") ?: "high"
                    
                    if (channelId != null && channelName != null && channelDescription != null) {
                        createNotificationChannel(channelId, channelName, channelDescription, importance)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Default channel for general notifications
            createNotificationChannel(
                "default",
                "Default Notifications",
                "General app notifications",
                "high"
            )
            
            // High priority channel for urgent tasks
            createNotificationChannel(
                "urgent_tasks",
                "Urgent Tasks",
                "Notifications for urgent task reports",
                "high"
            )
            
            // Task updates channel
            createNotificationChannel(
                "task_updates",
                "Task Updates",
                "Notifications for task status updates",
                "default"
            )
        }
    }

    private fun createNotificationChannel(
        channelId: String,
        channelName: String,
        channelDescription: String,
        importance: String
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importanceLevel = when (importance) {
                "high" -> NotificationManager.IMPORTANCE_HIGH
                "default" -> NotificationManager.IMPORTANCE_DEFAULT
                "low" -> NotificationManager.IMPORTANCE_LOW
                else -> NotificationManager.IMPORTANCE_DEFAULT
            }

            val channel = NotificationChannel(channelId, channelName, importanceLevel).apply {
                description = channelDescription
                enableLights(true)
                enableVibration(true)
                setShowBadge(true)
            }

            val notificationManager: NotificationManager =
                getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
