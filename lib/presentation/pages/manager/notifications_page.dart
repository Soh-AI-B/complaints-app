import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/notifications/notification_bloc.dart';
import '../../blocs/notifications/notification_event.dart';
import '../../blocs/notifications/notification_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/tasks/task_bloc.dart';
import '../../blocs/tasks/task_event.dart';
import '../../blocs/tasks/task_state.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/notifications/notification_card.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../../injection_container.dart' as di;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationBloc>().add(
        LoadNotifications(userEmail: authState.user.email),
      );
    }
  }

  void _markAllAsRead() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationBloc>().add(
        MarkAllNotificationsAsRead(userEmail: authState.user.email),
      );
    }
  }

  void _onNotificationTap(String notificationId, bool isRead) {
    if (!isRead) {
      context.read<NotificationBloc>().add(
        MarkNotificationAsRead(notificationId: notificationId),
      );
    }
  }

  void _navigateToTask(String? taskId) async {
    if (taskId != null && taskId.isNotEmpty) {
      // Show loading indicator while fetching task
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      TaskBloc? taskBloc;
      try {
        // Create a TaskBloc instance to fetch the task
        taskBloc = di.sl<TaskBloc>();

        // Add the event to load the task by ID
        taskBloc.add(LoadTaskById(taskId: taskId));

        // Wait for the task to be loaded by listening to specific states with timeout
        await for (final taskState in taskBloc.stream.timeout(
          const Duration(seconds: 10),
          onTimeout: (sink) =>
              sink.add(const TaskError(message: 'Request timeout')),
        )) {
          if (taskState is TaskLoaded) {
            // Dismiss loading dialog
            if (mounted) {
              Navigator.of(context).pop();
            }

            // Navigate with the task object
            if (mounted) {
              Navigator.pushNamed(
                context,
                AppRoutes.taskManagement,
                arguments: taskState.task,
              );
            }

            // Close the TaskBloc to prevent memory leaks
            taskBloc.close();
            return; // Exit the method successfully
          } else if (taskState is TaskError) {
            // Dismiss loading dialog
            if (mounted) {
              Navigator.of(context).pop();
            }

            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading task: ${taskState.message}'),
                  backgroundColor: AppColors.error,
                ),
              );
            }

            // Close the TaskBloc
            taskBloc.close();
            return; // Exit the method with error
          }
          // Continue listening for TaskLoading and other states
        }
      } catch (e) {
        // Dismiss loading dialog if still showing
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading task: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        // Ensure TaskBloc is closed even if an exception occurs
        taskBloc?.close();
      }
    } else {
      // Show message if no task associated with notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No task associated with this notification'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _onMarkAsRead(String notificationId) {
    context.read<NotificationBloc>().add(
      MarkNotificationAsRead(notificationId: notificationId),
    );
  }

  void _onDeleteNotification(String notificationId) {
    context.read<NotificationBloc>().add(
      DeleteNotification(notificationId: notificationId),
    );
  }

  void _onDeleteAllNotifications() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationBloc>().add(
        DeleteAllNotifications(userEmail: authState.user.email),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text(
                    'Mark All Read',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded &&
                  state.notifications.isNotEmpty) {
                return IconButton(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: AppColors.error,
                  ),
                  onPressed: _showDeleteAllConfirmation,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is NotificationMarkedAsRead ||
              state is AllNotificationsMarkedAsRead ||
              state is NotificationDeleted ||
              state is AllNotificationsDeleted) {
            _loadNotifications();
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const LoadingWidget();
          } else if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }
            return _buildNotificationsList(state);
          } else if (state is NotificationError) {
            return _buildErrorState(state.message);
          } else {
            return const LoadingWidget();
          }
        },
      ),
    );
  }

  Widget _buildNotificationsList(NotificationsLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadNotifications();
      },
      child: Column(
        children: [
          // Header with unread count
          if (state.unreadCount > 0) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: AppColors.primary,
                    size: AppDimensions.iconS,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Text(
                    '${state.unreadCount} unread notification${state.unreadCount > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Notifications list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingS,
              ),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return NotificationCard(
                  notification: notification,
                  onTap: () {
                    // Mark as read first
                    _onNotificationTap(
                      notification.notificationId,
                      notification.isRead,
                    );
                    // Then navigate to task by passing the taskId to load the full task
                    _navigateToTask(notification.taskId);
                  },
                  onMarkAsRead: notification.isRead
                      ? null
                      : () => _onMarkAsRead(notification.notificationId),
                  onDelete: () =>
                      _showDeleteConfirmation(notification.notificationId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            'No Notifications',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'You\'re all caught up! No new notifications to show.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            'Error Loading Notifications',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String notificationId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text(
          'Are you sure you want to delete this notification? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _onDeleteNotification(notificationId);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete All Notifications'),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _onDeleteAllNotifications();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
