import 'dart:developer' as developer;
import 'package:complaints/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/notifications/get_unread_notifications_count_usecase.dart';
import '../../../injection_container.dart' as di;
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/tasks/task_bloc.dart';
import '../../blocs/tasks/task_event.dart';
import '../../blocs/tasks/task_state.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/app_bottom_navigation.dart';
import '../../widgets/notifications/notification_badge.dart';
import '../../widgets/tasks/task_card.dart';
import '../../widgets/dashboard/stats_card.dart';
import '../../widgets/dashboard/quick_actions.dart';
import '../../../core/routes/app_routes.dart';

class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({super.key});

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage>
    with WidgetsBindingObserver {
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotificationCount();
    developer.log('Manager Home Page: Loading tasks...');
    _loadTasks();
  }

  // Helper method to load tasks based on user role
  void _loadTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (authState.user.isAdmin) {
        // Admins see all tasks
        developer.log('Manager Home Page: Loading all tasks for admin...');
        context.read<TaskBloc>().add(const LoadAllTasks());
      } else if (authState.user.isManager) {
        // Managers see filtered tasks by their managed categories
        developer.log(
          'Manager Home Page: Loading filtered tasks for manager...',
        );
        context.read<TaskBloc>().add(const LoadTasksForManager());
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh notification count when app comes back to foreground
      _loadNotificationCount();
    }
  }

  Future<void> _loadNotificationCount() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      try {
        final useCase = di.sl<GetUnreadNotificationsCountUseCase>();
        final result = await useCase(authState.user.email);
        final count = result.fold((failure) => 0, (count) => count);
        if (mounted) {
          setState(() {
            _notificationCount = count;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _notificationCount = 0;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Manager Dashboard',
        leading: Container(
          margin: const EdgeInsets.only(left: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                width: 50,
                height: 40,
              ),
            ],
          ),
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                return Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: NotificationBadge(
                    count: _notificationCount,
                    child: IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.notifications,
                        );
                        // Refresh count when returning from notifications page
                        if (result == true || mounted) {
                          _loadNotificationCount();
                        }
                      },
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'analytics':
                  Navigator.pushNamed(context, AppRoutes.analytics);
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(Icons.analytics_outlined, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Analytics'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(
        currentRoute: AppRoutes.managerHome,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          developer.log(
            'Manager Home Page - Auth State: ${authState.runtimeType}',
          );

          if (authState is AuthAuthenticated) {
            return RefreshIndicator(
              onRefresh: () async {
                _loadTasks();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(authState.user.name),

                    const SizedBox(height: 24),

                    // Quick Actions
                    QuickActions(
                      onViewAnalytics: () {
                        Navigator.pushNamed(context, AppRoutes.analytics);
                      },
                      onManageTasks: () {
                        Navigator.pushNamed(context, AppRoutes.tasksList);
                      },
                      onManageUsers: authState.user.canManageUsers
                          ? () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.manageUsers,
                              );
                            }
                          : null,
                    ),

                    const SizedBox(height: 24),

                    // Dashboard Stats
                    BlocBuilder<TaskBloc, TaskState>(
                      builder: (context, taskState) {
                        return _buildStatsSection(taskState);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Priority Tasks Section
                    BlocBuilder<TaskBloc, TaskState>(
                      builder: (context, taskState) {
                        return _buildPriorityTasksSection(taskState);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Recent Tasks Section
                    BlocBuilder<TaskBloc, TaskState>(
                      builder: (context, taskState) {
                        return _buildRecentTasksSection(taskState);
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (authState is AuthUnauthenticated) {
            // Navigate back to login if not authenticated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            });
            return const Center(child: CircularProgressIndicator());
          } else if (authState is AuthInitial) {
            // User was authenticated when navigated here, so this shouldn't happen
            // If it does, redirect to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            });
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Authentication issue, redirecting...'),
                ],
              ),
            );
          } else if (authState is AuthError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Authentication Error',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(authState.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRoutes.login),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.tasksList);
        },
        backgroundColor: const Color(0xFF253b74),
        icon: const Icon(Icons.assignment_outlined, color: Colors.white),
        label: const Text(
          'Manage Tasks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(String userName) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF253b74), Color(0xFF1b75bc)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Monitor and manage team complaints efficiently',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(TaskState taskState) {
    int totalTasks = 0;
    int pendingTasks = 0;
    int inProgressTasks = 0;
    int completedTasks = 0;
    int urgentTasks = 0;

    if (taskState is TasksLoaded) {
      totalTasks = taskState.tasks.length;
      pendingTasks = taskState.tasks
          .where((task) => task.status == 'Pending')
          .length;
      inProgressTasks = taskState.tasks
          .where((task) => task.status == 'In Progress')
          .length;
      completedTasks = taskState.tasks
          .where((task) => task.status == 'Completed')
          .length;
      urgentTasks = taskState.tasks
          .where((task) => task.priority == 'Urgent')
          .length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dashboard Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF253b74),
          ),
        ),
        const SizedBox(height: 16),

        // First row of stats
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Total Tasks',
                value: totalTasks.toString(),
                icon: Icons.assignment_outlined,
                color: const Color(0xFF253b74),
                onTap: () => Navigator.pushNamed(context, AppRoutes.tasksList),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Pending',
                value: pendingTasks.toString(),
                icon: Icons.pending_outlined,
                color: Colors.orange,
                onTap: () => _navigateToFilteredTasks('Pending'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Second row of stats
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'In Progress',
                value: inProgressTasks.toString(),
                icon: Icons.work_outline,
                color: Colors.blue,
                onTap: () => _navigateToFilteredTasks('In Progress'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Completed',
                value: completedTasks.toString(),
                icon: Icons.check_circle_outline,
                color: const Color(0xFF91be3f),
                onTap: () => _navigateToFilteredTasks('Completed'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Urgent tasks stats
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Urgent Tasks',
                value: urgentTasks.toString(),
                icon: Icons.priority_high,
                color: Colors.red,
                onTap: () => _navigateToFilteredTasks('', priority: 'Urgent'),
              ),
            ),
            Expanded(
              child: Container(), // Empty space for symmetry
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityTasksSection(TaskState taskState) {
    List<dynamic> urgentTasks = [];

    if (taskState is TasksLoaded) {
      urgentTasks = taskState.tasks
          .where(
            (task) => task.priority == 'Urgent' && task.status != 'Completed',
          )
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Priority Tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF253b74),
              ),
            ),
            if (urgentTasks.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${urgentTasks.length} Urgent',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (taskState is TaskLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (urgentTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Urgent Tasks',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All high-priority items are under control',
                        style: TextStyle(color: Colors.green[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: urgentTasks
                .take(3) // Show only top 3 urgent tasks
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TaskCard(
                      task: task,
                      compact: true,
                      onTap: () => _navigateToTaskDetail(task),
                      isManagerView: true,
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildRecentTasksSection(TaskState taskState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF253b74),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.tasksList);
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF1b75bc),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (taskState is TaskLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (taskState is TaskError)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600], size: 48),
                const SizedBox(height: 12),
                Text(
                  'Failed to load tasks',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  taskState.message,
                  style: TextStyle(color: Colors.red[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _loadTasks();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else if (taskState is TasksLoaded)
          taskState.tasks.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: _prioritizedTasks(taskState.tasks)
                      .take(5) // Show recent 5 tasks
                      .map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskCard(
                            task: task,
                            compact: true,
                            showImage: false,
                            onTap: () => _navigateToTaskDetail(task),
                            isManagerView: true,
                          ),
                        ),
                      )
                      .toList(),
                )
        else
          _buildEmptyState(),
      ],
    );
  }

  List<dynamic> _prioritizedTasks(List<dynamic> tasks) {
    final sorted = List<dynamic>.from(tasks)
      ..sort((a, b) {
        final aDone = a.status == 'Completed' || a.status == 'Cancelled';
        final bDone = b.status == 'Completed' || b.status == 'Cancelled';
        if (aDone != bDone) return aDone ? 1 : -1;
        if (a.priority == 'Urgent' && b.priority != 'Urgent') return -1;
        if (a.priority != 'Urgent' && b.priority == 'Urgent') return 1;
        return b.dateReported.compareTo(a.dateReported);
      });
    return sorted;
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tasks available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tasks will appear here as they are reported',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToFilteredTasks(String status, {String? priority}) {
    final arguments = <String, String?>{};

    if (status.isNotEmpty) {
      arguments['status'] = status;
    }
    if (priority != null) {
      arguments['priority'] = priority;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.tasksList,
      arguments: arguments.isNotEmpty ? arguments : null,
    );
  }

  void _navigateToTaskDetail(dynamic task) {
    Navigator.pushNamed(context, AppRoutes.taskManagement, arguments: task);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthLogoutRequested());
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
