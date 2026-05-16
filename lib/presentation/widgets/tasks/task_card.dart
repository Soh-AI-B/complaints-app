import 'package:complaints/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/task.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/tasks/task_bloc.dart';
import '../../blocs/tasks/task_event.dart';
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
    final statusColor = AppColors.getStatusColor(task.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      elevation: 1,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        side: BorderSide(color: statusColor.withValues(alpha: 0.18)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppDimensions.radiusM),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(
                    compact ? AppDimensions.paddingM : AppDimensions.paddingL,
                  ),
                  child: compact
                      ? _buildCompactContent(context)
                      : _buildFullContent(context),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildCompactContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(context, compact: true),
        const SizedBox(height: AppDimensions.spacingS),
        _buildMetaWrap(context),
      ],
    );
  }

  Widget _buildFullContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(context),
        const SizedBox(height: AppDimensions.spacingS),
        _buildMetaWrap(context),
        if (task.description.trim().isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            task.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (showImage && task.hasImage) ...[
          const SizedBox(height: AppDimensions.spacingM),
          _buildImagePreview(context),
        ],
        const SizedBox(height: AppDimensions.spacingM),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context, {bool compact = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style:
                    (compact
                            ? Theme.of(context).textTheme.bodyMedium
                            : Theme.of(context).textTheme.titleMedium)
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isManagerView) ...[
                const SizedBox(height: 4),
                Text(
                  task.employeeName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        if (showActions && isManagerView)
          _buildOverflowMenu(context)
        else
          StatusBadge(status: task.status, compact: compact),
      ],
    );
  }

  Widget _buildMetaWrap(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingS,
      runSpacing: AppDimensions.spacingS,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        StatusBadge(status: task.status, compact: true),
        PriorityBadge(priority: task.priority, compact: true),
        _InfoChip(icon: Icons.category_outlined, label: task.category),
        if (task.isOverdue)
          const _InfoChip(
            icon: Icons.warning_amber_rounded,
            label: 'Overdue',
            color: AppColors.error,
          ),
        if (task.imageCount > 0)
          _InfoChip(icon: Icons.photo_outlined, label: '${task.imageCount}'),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    final imageUrl = task.allImageUrls.first;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              cacheWidth: 700,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.background,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textSecondary,
                  ),
                );
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: AppColors.background,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
          ),
          if (task.imageCount > 1)
            Positioned(
              right: 8,
              bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '+${task.imageCount - 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final canComplete =
        onStatusChanged != null &&
        task.status != 'Completed' &&
        task.status != 'Cancelled';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 380;
        final dateInfo = _buildDateInfo(context);
        final action = canComplete
            ? FilledButton.icon(
                onPressed: () => onStatusChanged?.call('Completed'),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Complete'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.textLight,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              )
            : null;

        if (isTight || action == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dateInfo,
              if (action != null) ...[
                const SizedBox(height: AppDimensions.spacingS),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: dateInfo),
            const SizedBox(width: AppDimensions.spacingM),
            action,
          ],
        );
      },
    );
  }

  Widget _buildDateInfo(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);

    return Wrap(
      spacing: AppDimensions.spacingM,
      runSpacing: 4,
      children: [
        _IconText(
          icon: Icons.schedule,
          label: DateFormatter.formatDateForDisplay(task.dateReported),
          style: textStyle,
        ),
        if (task.estimatedCompletion != null)
          _IconText(
            icon: Icons.event_available_outlined,
            label:
                'Due ${DateFormatter.formatDateForDisplay(task.estimatedCompletion!)}',
            color: _getEstimatedDateColor(),
            style: textStyle?.copyWith(
              color: _getEstimatedDateColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildOverflowMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Task actions',
      onSelected: (value) {
        if (value == 'status' && onStatusChanged != null) {
          _showStatusChangeDialog(context);
        } else if (value == 'complete' && onStatusChanged != null) {
          onStatusChanged?.call('Completed');
        } else if (value == 'edit') {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.taskManagement, arguments: task);
        } else if (value == 'delete') {
          _showDeleteConfirmation(context);
        }
      },
      itemBuilder: (context) => [
        if (task.status != 'Completed' && onStatusChanged != null)
          const PopupMenuItem(
            value: 'complete',
            child: ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Mark Completed'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
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
            title: Text('Delete Task', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Color _getEstimatedDateColor() {
    if (task.estimatedCompletion == null) return AppColors.textSecondary;

    final daysUntilDue = task.estimatedCompletion!
        .difference(DateTime.now())
        .inDays;
    if (daysUntilDue < 0) return AppColors.error;
    if (daysUntilDue <= 1) return AppColors.warning;
    return AppColors.success;
  }

  void _showStatusChangeDialog(BuildContext context) {
    final statusOptions = AppConstants.taskStatuses;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: SingleChildScrollView(
          child: Column(
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
    final authState = authBloc.state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required to delete tasks'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    taskBloc.add(
      DeleteTask(taskId: task.taskId, userRole: authState.user.role),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: effectiveColor),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: effectiveColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final TextStyle? style;

  const _IconText({
    required this.icon,
    required this.label,
    this.color,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconS, color: effectiveColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
