import 'package:flutter/material.dart';
import '../../../domain/entities/notification.dart' as entities;

class NotificationCard extends StatelessWidget {
  final entities.Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead ? null : Colors.blue[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(),
          child: Icon(_getTypeIcon(), color: Colors.white, size: 20),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: TextStyle(
                color: notification.isRead
                    ? Colors.grey[600]
                    : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(notification.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                if (!notification.isRead && onMarkAsRead != null) {
                  onMarkAsRead!();
                }
                break;
              case 'delete':
                if (onDelete != null) {
                  onDelete!();
                }
                break;
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, size: 16),
                    SizedBox(width: 8),
                    Text('Mark as read'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case 'new_task':
        return Colors.blue;
      case 'task_updated':
        return Colors.orange;
      case 'task_assigned':
        return Colors.green;
      case 'task_completed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case 'new_task':
        return Icons.add_task;
      case 'task_updated':
        return Icons.update;
      case 'task_assigned':
        return Icons.assignment_ind;
      case 'task_completed':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
