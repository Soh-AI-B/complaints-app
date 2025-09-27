import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/tasks/task_bloc.dart';
import '../../blocs/tasks/task_event.dart';
import '../../blocs/tasks/task_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/dashboard/chart_widget.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../domain/entities/task.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedPeriod = 'This Month';
  final List<String> _periodOptions = [
    'This Week',
    'This Month',
    'This Quarter',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<TaskBloc>().add(const LoadAllTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Analytics',
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadData();
            },
            itemBuilder: (context) => _periodOptions.map((period) {
              return PopupMenuItem(value: period, child: Text(period));
            }).toList(),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoading) {
                return const LoadingWidget();
              } else if (state is TasksLoaded) {
                return _buildAnalytics(state.tasks);
              } else if (state is TaskError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: AppDimensions.iconL,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      Text(
                        'Error loading analytics',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.error),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No data available'));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnalytics(List<Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppColors.primary,
                  size: AppDimensions.iconM,
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analytics Report',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _selectedPeriod,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${tasks.length} Total Tasks',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingL),

        // Task Status Distribution
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
                const SizedBox(height: AppDimensions.spacingL),
                ChartWidget(
                  data: _getStatusDistributionData(tasks),
                  chartType: ChartType.pieChart,
                  height: 250,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingL),

        // Priority Analysis
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Priority Analysis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                ChartWidget(
                  data: _getPriorityDistributionData(tasks),
                  chartType: ChartType.barChart,
                  height: 200,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingL),

        // Category Breakdown
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
                ChartWidget(
                  data: _getCategoryDistributionData(tasks),
                  chartType: ChartType.barChart,
                  height: 200,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingL),

        // Performance Metrics
        _buildPerformanceMetrics(tasks),

        const SizedBox(height: AppDimensions.spacingL),

        // Employee Performance
        _buildEmployeePerformance(tasks),
      ],
    );
  }

  Widget _buildPerformanceMetrics(List<Task> tasks) {
    final completionRate = _calculateCompletionRate(tasks);
    final averageCompletionTime = _calculateAverageCompletionTime(tasks);
    final overdueCount = _getOverdueTasksCount(tasks);
    final urgentCount = tasks.where((t) => t.priority == 'Urgent').length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.spacingM,
              mainAxisSpacing: AppDimensions.spacingM,
              childAspectRatio: 1.125,
              children: [
                _buildMetricCard(
                  'Completion Rate',
                  '${completionRate.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  AppColors.success,
                ),
                _buildMetricCard(
                  'Avg. Completion',
                  '${averageCompletionTime.toStringAsFixed(1)} days',
                  Icons.schedule,
                  AppColors.info,
                ),
                _buildMetricCard(
                  'Overdue Tasks',
                  overdueCount.toString(),
                  Icons.warning,
                  AppColors.error,
                ),
                _buildMetricCard(
                  'Urgent Tasks',
                  urgentCount.toString(),
                  Icons.priority_high,
                  AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: AppDimensions.iconM),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeePerformance(List<Task> tasks) {
    final employeeStats = _getEmployeePerformanceData(tasks);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee Performance',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            ...employeeStats.take(5).map((employee) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        employee['name']!.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee['name']!,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${employee['completed']} completed / ${employee['total']} total',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
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
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: Text(
                        '${employee['rate']}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
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

  Map<String, double> _getCategoryDistributionData(List<Task> tasks) {
    final categoryCounts = <String, int>{};
    for (final task in tasks) {
      categoryCounts[task.category] = (categoryCounts[task.category] ?? 0) + 1;
    }
    return categoryCounts.map((key, value) => MapEntry(key, value.toDouble()));
  }

  List<Map<String, String>> _getEmployeePerformanceData(List<Task> tasks) {
    final employeeStats = <String, Map<String, int>>{};

    for (final task in tasks) {
      if (!employeeStats.containsKey(task.employeeName)) {
        employeeStats[task.employeeName] = {'total': 0, 'completed': 0};
      }
      employeeStats[task.employeeName]!['total'] =
          (employeeStats[task.employeeName]!['total'] ?? 0) + 1;

      if (task.status == 'Completed') {
        employeeStats[task.employeeName]!['completed'] =
            (employeeStats[task.employeeName]!['completed'] ?? 0) + 1;
      }
    }

    final result = employeeStats.entries.map((entry) {
      final total = entry.value['total'] ?? 0;
      final completed = entry.value['completed'] ?? 0;
      final rate = total > 0 ? ((completed / total) * 100).round() : 0;

      return {
        'name': entry.key,
        'total': total.toString(),
        'completed': completed.toString(),
        'rate': rate.toString(),
      };
    }).toList();

    // Sort by completion rate
    result.sort(
      (a, b) => int.parse(b['rate']!).compareTo(int.parse(a['rate']!)),
    );

    return result;
  }

  double _calculateCompletionRate(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((t) => t.status == 'Completed').length;
    return (completedTasks / tasks.length) * 100;
  }

  double _calculateAverageCompletionTime(List<Task> tasks) {
    final completedTasks = tasks.where((t) => t.status == 'Completed').toList();
    if (completedTasks.isEmpty) return 0.0;

    double totalDays = 0;
    for (final task in completedTasks) {
      totalDays += task.dateUpdated.difference(task.dateReported).inDays;
    }

    return totalDays / completedTasks.length;
  }

  int _getOverdueTasksCount(List<Task> tasks) {
    return tasks.where((task) => task.isOverdue).length;
  }
}
