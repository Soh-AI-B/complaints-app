import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/tasks/task_bloc.dart';
import '../../blocs/tasks/task_event.dart';
import '../../blocs/tasks/task_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';

class TaskCleanupPage extends StatefulWidget {
  const TaskCleanupPage({super.key});

  @override
  State<TaskCleanupPage> createState() => _TaskCleanupPageState();
}

class _TaskCleanupPageState extends State<TaskCleanupPage> {
  int _completedRetentionDays = 30;
  int _cancelledRetentionDays = 7;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // Listen to TaskBloc states
    context.read<TaskBloc>().stream.listen((state) {
      if (mounted) {
        if (state is TasksAutoCleanupCompleted) {
          _handleCleanupCompleted(state);
        } else if (state is TaskError) {
          _handleCleanupError(state.message);
        } else if (state is TaskLoading) {
          setState(() => _isRunning = true);
        }
      }
    });
  }

  void _handleCleanupCompleted(TasksAutoCleanupCompleted state) {
    setState(() => _isRunning = false);

    final hasErrors = state.hasErrors;
    final message = hasErrors
        ? 'Cleanup completed with errors:\n${state.deletedTasksCount} tasks deleted, ${state.deletedImagesCount} images cleaned.\n\nErrors occurred: ${state.errors.join(', ')}'
        : 'Cleanup completed successfully!\n${state.deletedTasksCount} tasks deleted, ${state.deletedImagesCount} images cleaned.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Icon(
          hasErrors ? Icons.warning : Icons.check_circle,
          color: hasErrors ? AppColors.warning : AppColors.success,
          size: 48,
        ),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleCleanupError(String errorMessage) {
    setState(() => _isRunning = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cleanup failed: $errorMessage'),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Task Cleanup Settings'),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated || !authState.user.isAdmin) {
            return _buildUnauthorizedView();
          }

          return _buildCleanupSettings();
        },
      ),
    );
  }

  Widget _buildUnauthorizedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            'Admin Access Required',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'Only administrators can access task cleanup settings.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXL),
          CustomButton(
            text: 'Go Back',
            onPressed: () => Navigator.of(context).pop(),
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCleanupSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_delete,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Automatic Task Cleanup',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: AppDimensions.spacingXS),
                            Text(
                              'Automatically delete old completed/cancelled tasks and their associated images to save storage space.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXL),

          // Retention Settings
          Text(
            'Retention Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),

          // Completed Tasks Retention
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: AppDimensions.spacingM),
                      Text(
                        'Completed Tasks',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    'Tasks will be automatically deleted $_completedRetentionDays days after completion.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Row(
                    children: [
                      Text(
                        'Retention Period: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _completedRetentionDays.toDouble(),
                          min: 1,
                          max: 365,
                          divisions: 36,
                          label: '$_completedRetentionDays days',
                          onChanged: (value) {
                            setState(() {
                              _completedRetentionDays = value.round();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '$_completedRetentionDays days',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // Cancelled Tasks Retention
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cancel, color: AppColors.error),
                      const SizedBox(width: AppDimensions.spacingM),
                      Text(
                        'Cancelled Tasks',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    'Cancelled tasks will be automatically deleted $_cancelledRetentionDays days after cancellation.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Row(
                    children: [
                      Text(
                        'Retention Period: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _cancelledRetentionDays.toDouble(),
                          min: 1,
                          max: 90,
                          divisions: 17,
                          label: '$_cancelledRetentionDays days',
                          onChanged: (value) {
                            setState(() {
                              _cancelledRetentionDays = value.round();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '$_cancelledRetentionDays days',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXL),

          // Actions
          Card(
            color: AppColors.warning.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: AppColors.warning),
                      const SizedBox(width: AppDimensions.spacingM),
                      Text(
                        'Manual Cleanup',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    'This will immediately delete all completed and cancelled tasks older than the specified retention periods. This action cannot be undone.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  SizedBox(
                    width: double.infinity,
                    child: _isRunning
                        ? const LoadingWidget()
                        : CustomButton(
                            text: 'Run Cleanup Now',
                            onPressed: _showRunCleanupConfirmation,
                            isOutlined: true,
                            icon: Icons.cleaning_services,
                          ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXL),
        ],
      ),
    );
  }

  void _showRunCleanupConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning),
            const SizedBox(width: AppDimensions.spacingM),
            const Text('Confirm Cleanup'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text('• Completed tasks older than $_completedRetentionDays days'),
            Text('• Cancelled tasks older than $_cancelledRetentionDays days'),
            Text('• All associated images from Cloudinary storage'),
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.delete_forever, color: AppColors.error, size: 20),
                  const SizedBox(width: AppDimensions.spacingS),
                  const Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _runCleanup();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete Tasks'),
          ),
        ],
      ),
    );
  }

  void _runCleanup() {
    setState(() => _isRunning = true);

    context.read<TaskBloc>().add(
      AutoCleanupCompletedTasks(
        completedTasksRetentionDays: _completedRetentionDays,
        cancelledTasksRetentionDays: _cancelledRetentionDays,
      ),
    );
  }
}
