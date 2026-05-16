import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/tasks/task_bloc.dart';
import '../../blocs/tasks/task_event.dart';
import '../../blocs/tasks/task_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/dashboard/stats_card.dart';
import '../../widgets/dashboard/chart_widget.dart';
import '../../widgets/dashboard/quick_actions.dart';
import '../../widgets/notifications/notification_badge.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/usecases/notifications/get_unread_notifications_count_usecase.dart';
import '../../../injection_container.dart' as di;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedPeriod = 'This Month';
  final List<String> _periodOptions = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    context.read<TaskBloc>().add(const LoadAllTasks());
  }

  Future<int> _getNotificationCount(String userEmail) async {
    try {
      final useCase = di.sl<GetUnreadNotificationsCountUseCase>();
      final result = await useCase(userEmail);
      return result.fold((failure) => 0, (count) => count);
    } catch (e) {
      return 0;
    }
  }

  void _showNotificationSnackBar(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count > 0
              ? 'You have $count new notification${count > 1 ? 's' : ''}!'
              : 'No new notifications',
        ),
        backgroundColor: count > 0 ? Colors.blue : Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Dashboard',
        actions: [
          // Notification icon with badge
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                return FutureBuilder<int>(
                  future: _getNotificationCount(authState.user.email),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: NotificationBadge(
                        count: count,
                        child: IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {
                            _showNotificationSnackBar(count);
                          },
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDashboardData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector
              Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
                child: Row(
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          items: _periodOptions.map((String period) {
                            return DropdownMenuItem<String>(
                              value: period,
                              child: Text(period),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedPeriod = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Statistics Cards
              BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const LoadingWidget();
                  } else if (state is TasksLoaded) {
                    return _buildStatisticsSection(state.tasks);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Charts Section
              BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TasksLoaded) {
                    return _buildChartsSection(state.tasks);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Quick Actions
              QuickActions(
                onAddComplaint: () =>
                    Navigator.of(context).pushNamed(AppRoutes.taskManagement),
                onViewTasks: () =>
                    Navigator.of(context).pushNamed(AppRoutes.tasksList),
                onViewAnalytics: () =>
                    Navigator.of(context).pushNamed(AppRoutes.analytics),
                onManageTasks: () =>
                    Navigator.of(context).pushNamed(AppRoutes.taskManagement),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Recent Tasks Summary
              BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TasksLoaded) {
                    return _buildRecentTasksSection(state.tasks);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(List<Task> tasks) {
    final totalTasks = tasks.length;
    final pendingTasks = tasks.where((t) => t.status == 'Pending').length;
    final inProgressTasks = tasks
        .where((t) => t.status == 'In Progress')
        .length;
    final completedTasks = tasks.where((t) => t.status == 'Completed').length;
    final urgentTasks = tasks.where((t) => t.priority == 'Urgent').length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Total Tasks',
                value: totalTasks.toString(),
                icon: Icons.assignment,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: StatsCard(
                title: 'Pending',
                value: pendingTasks.toString(),
                icon: Icons.pending,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'In Progress',
                value: inProgressTasks.toString(),
                icon: Icons.work,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: StatsCard(
                title: 'Completed',
                value: completedTasks.toString(),
                icon: Icons.check_circle,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Urgent Tasks',
                value: urgentTasks.toString(),
                icon: Icons.priority_high,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: StatsCard(
                title: 'Completion Rate',
                value: '${_calculateCompletionRate(tasks).toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection(List<Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.spacingM),

        // Status Distribution Chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Status Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                ChartWidget(
                  data: _getStatusDistributionData(tasks),
                  chartType: ChartType.pieChart,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingM),

        // Priority Distribution Chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Priority Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                ChartWidget(
                  data: _getPriorityDistributionData(tasks),
                  chartType: ChartType.barChart,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTasksSection(List<Task> tasks) {
    final recentTasks = tasks
        .where(
          (task) => DateTime.now().difference(task.dateReported).inDays <= 7,
        )
        .take(5)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Tasks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.tasksList);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            if (recentTasks.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: AppDimensions.iconL,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Text(
                        'No recent tasks',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ...recentTasks.map((task) => _buildRecentTaskItem(task)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.getPriorityColor(task.priority),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  task.employeeName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingS,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.getStatusColor(
                task.status,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Text(
              task.status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.getStatusColor(task.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getStatusDistributionData(List<Task> tasks) {
    final statusCounts = <String, int>{};
    for (final task in tasks) {
      statusCounts[task.status] = (statusCounts[task.status] ?? 0) + 1;
    }

    return statusCounts.map((key, value) => MapEntry(key, value.toDouble()));
  }

  Map<String, double> _getPriorityDistributionData(List<Task> tasks) {
    final priorityCounts = <String, int>{};
    for (final task in tasks) {
      priorityCounts[task.priority] = (priorityCounts[task.priority] ?? 0) + 1;
    }

    return priorityCounts.map((key, value) => MapEntry(key, value.toDouble()));
  }

  double _calculateCompletionRate(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((t) => t.status == 'Completed').length;
    return (completedTasks / tasks.length) * 100;
  }
}
