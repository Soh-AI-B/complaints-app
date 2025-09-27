package com.example.complaints

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        // Log message details
        android.util.Log.d("FCM", "From: ${remoteMessage.from}")
        android.util.Log.d("FCM", "Message data: ${remoteMessage.data}")
        android.util.Log.d("FCM", "Message notification: ${remoteMessage.notification}")

        // DISABLED: Let Flutter handle ALL notifications to avoid duplicates
        // The Flutter app will handle both foreground and background notifications
        android.util.Log.d("FCM", "Native notification creation disabled - Flutter handles all notifications")
        
        // NOTE: For background notifications when app is killed, 
        // you may need to enable this selectively in the future
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        android.util.Log.d("FCM", "Refreshed token: $token")
        // Send token to your server if needed
    }

    private fun createNotification(
        title: String,
        body: String,
        data: Map<String, String>
    ) {
        val channelId = when (data["type"]) {
            "new_task" -> if (data["priority"] == "Urgent") "urgent_tasks" else "default"
            "task_update" -> "task_updates"
            else -> "default"
        }

        createNotificationChannel(channelId)

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            // Add any extra data from the notification
            data.forEach { (key, value) ->
                putExtra(key, value)
            }
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )

        val notificationBuilder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setContentIntent(pendingIntent)

        // Add action buttons for task notifications
        if (data["type"] == "new_task" && data["taskId"] != null) {
            val viewIntent = Intent(this, MainActivity::class.java).apply {
                putExtra("action", "view_task")
                putExtra("taskId", data["taskId"])
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val viewPendingIntent = PendingIntent.getActivity(
                this,
                1,
                viewIntent,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
            )
            notificationBuilder.addAction(
                android.R.drawable.ic_menu_view,
                "View Task",
                viewPendingIntent
            )
        }

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notificationId = System.currentTimeMillis().toInt()
        notificationManager.notify(notificationId, notificationBuilder.build())

        android.util.Log.d("FCM", "Notification created with ID: $notificationId")
    }

    private fun createNotificationChannel(channelId: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            if (notificationManager.getNotificationChannel(channelId) == null) {
                val (channelName, importance) = when (channelId) {
                    "urgent_tasks" -> "Urgent Tasks" to NotificationManager.IMPORTANCE_HIGH
                    "task_updates" -> "Task Updates" to NotificationManager.IMPORTANCE_DEFAULT
                    else -> "Default Notifications" to NotificationManager.IMPORTANCE_HIGH
                }

                val channel = NotificationChannel(channelId, channelName, importance).apply {
                    description = "Notifications for $channelName"
                    enableLights(true)
                    enableVibration(true)
                    setShowBadge(true)
                }

                notificationManager.createNotificationChannel(channel)
                android.util.Log.d("FCM", "Created notification channel: $channelId")
            }
        }
    }
}
