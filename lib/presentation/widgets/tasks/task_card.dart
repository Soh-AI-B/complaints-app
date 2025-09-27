import 'package:complaints/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../../domain/entities/task.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/app_user.dart';
import '../../blocs/tasks/task_bloc.dart';
import '../../blocs/tasks/task_event.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'priority_badge.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final Function(String)? onStatusChanged;
  final bool isManagerView;
  final bool showActions;
  final bool compact;
  final bool showImage;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChanged,
    this.isManagerView = false,
    this.showActions = true,
    this.compact = false,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      elevation: 2,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: EdgeInsets.all(
            compact ? AppDimensions.paddingM : AppDimensions.paddingL,
          ),
          child: compact
              ? _buildCompactContent(context)
              : _buildFullContent(context),
        ),
      ),
    );
  }

  Widget _buildCompactContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(status: task.status, compact: true),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            PriorityBadge(priority: task.priority, compact: true),
            const SizedBox(width: 8),
            Text(
              task.category,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            Text(
              DateFormatter.formatDateForDisplay(task.dateReported),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFullContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingXS),
                  if (isManagerView) ...[
                    Text(
                      'By: ${task.employeeName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                  ],
                  Text(
                    task.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Column(
              children: [
                PriorityBadge(priority: task.priority),
                const SizedBox(height: AppDimensions.spacingXS),
                StatusBadge(status: task.status),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacingM),

        // Description
        if (task.description.isNotEmpty) ...[
          Text(
            task.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacingM),
        ],

        // Footer Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Date Information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: AppDimensions.iconS,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Created: ${DateFormatter.formatDateForDisplay(task.dateReported)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (task.estimatedCompletion != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: AppDimensions.iconS,
                        color: _getEstimatedDateColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${DateFormatter.formatDateForDisplay(task.estimatedCompletion!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getEstimatedDateColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // Actions
            if (showActions && isManagerView) ...[
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'status' && onStatusChanged != null) {
                    _showStatusChangeDialog(context);
                  } else if (value == 'edit') {
                    // Navigate to edit page
                    Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.taskManagement, arguments: task);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'status',
                    child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Change Status'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit Task'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        'Delete Task',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),

        // Image Thumbnail
        if (task.pictureUrl != null && task.pictureUrl!.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingM),
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              child: Image.network(
                task.pictureUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.background,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: AppColors.textSecondary,
                        size: AppDimensions.iconM,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.background,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],

        // if multiple images show the first three as small thumbnails
        if (task.pictureUrls != null &&
            task.pictureUrls!.isNotEmpty &&
            showImage) ...[
          const SizedBox(height: AppDimensions.spacingM),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: task.pictureUrls!.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final imageUrl = task.pictureUrls![index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: AppColors.background,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: AppColors.textSecondary,
                            size: AppDimensions.iconS,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 100,
                        height: 100,
                        color: AppColors.background,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Color _getEstimatedDateColor() {
    if (task.estimatedCompletion == null) return AppColors.textSecondary;

    final now = DateTime.now();
    final daysUntilDue = task.estimatedCompletion!.difference(now).inDays;

    if (daysUntilDue < 0) {
      return AppColors.error; // Overdue
    } else if (daysUntilDue <= 1) {
      return AppColors.warning; // Due soon
    } else {
      return AppColors.success; // On track
    }
  }

  void _showStatusChangeDialog(BuildContext context) {
    final statusOptions = AppConstants.taskStatuses;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statusOptions.map((status) {
            return ListTile(
              title: Text(status),
              leading: StatusBadge(status: status),
              onTap: () {
                Navigator.of(context).pop();
                onStatusChanged?.call(status);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    // Capture the blocs from the current context before showing dialog
    final taskBloc = context.read<TaskBloc>();
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task? This action cannot be undone and will also remove any associated images.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteTask(context, taskBloc, authBloc);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(BuildContext context, TaskBloc taskBloc, AuthBloc authBloc) {
    // Get current user role from AuthBloc
    final authState = authBloc.state;

    String userRole = '';
    if (authState is AuthAuthenticated) {
      userRole = authState.user.role;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required to delete tasks'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Dispatch delete task event
    taskBloc.add(DeleteTask(taskId: task.taskId, userRole: userRole));
  }
}
