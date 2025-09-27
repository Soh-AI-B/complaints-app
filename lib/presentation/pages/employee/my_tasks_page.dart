import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/tasks/task_bloc.dart';
import '../../blocs/tasks/task_event.dart';
import '../../blocs/tasks/task_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/tasks/task_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../../domain/entities/task.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled',
  ];
  final List<String> _priorityOptions = ['All', 'Urgent', 'Normal', 'Low'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TaskBloc>().add(
        LoadTasksByUser(employeeEmail: authState.user.email),
      );
    }
  }

  void _refreshTasks() {
    _loadTasks();
  }

  List<Task> _filterTasks(List<Task> tasks, String status) {
    var filteredTasks = tasks;

    // Filter by tab status
    if (status != 'All') {
      filteredTasks = filteredTasks
          .where((task) => task.status == status)
          .toList();
    }

    // Filter by selected status
    if (_selectedStatus != 'All') {
      filteredTasks = filteredTasks
          .where((task) => task.status == _selectedStatus)
          .toList();
    }

    // Filter by selected priority
    if (_selectedPriority != 'All') {
      filteredTasks = filteredTasks
          .where((task) => task.priority == _selectedPriority)
          .toList();
    }

    return filteredTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Tasks',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshTasks),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'In Progress'),
                Tab(text: 'Completed'),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: BlocListener<TaskBloc, TaskState>(
              listener: (context, state) {
                // Reload tasks when a task is updated, deleted, or created
                if (state is TaskUpdated ||
                    state is TaskDeleted ||
                    state is TaskCreated) {
                  _loadTasks();
                }
              },
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const LoadingWidget();
                  } else if (state is TaskError) {
                    return CustomErrorWidget(
                      message: state.message,
                      onRetry: _refreshTasks,
                    );
                  } else if (state is TasksLoaded) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTaskList(_filterTasks(state.tasks, 'All')),
                        _buildTaskList(_filterTasks(state.tasks, 'Pending')),
                        _buildTaskList(
                          _filterTasks(state.tasks, 'In Progress'),
                        ),
                        _buildTaskList(_filterTasks(state.tasks, 'Completed')),
                      ],
                    );
                  } else {
                    return const Center(child: Text('No tasks available'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add_complaint').then((_) {
            _refreshTasks();
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'No tasks found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'Tasks you create will appear here',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _refreshTasks();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
            child: TaskCard(
              task: task,
              onTap: () {
                Navigator.of(context)
                    .pushNamed(AppRoutes.taskDetail, arguments: task.taskId)
                    .then((_) {
                      _refreshTasks();
                    });
              },
            ),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  Text(
                    'Filter Tasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // Status Filter
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Wrap(
                    spacing: AppDimensions.spacingS,
                    children: _statusOptions.map((status) {
                      final isSelected = _selectedStatus == status;
                      return FilterChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedStatus = selected ? status : 'All';
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppDimensions.spacingL),

                  // Priority Filter
                  Text(
                    'Priority',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Wrap(
                    spacing: AppDimensions.spacingS,
                    children: _priorityOptions.map((priority) {
                      final isSelected = _selectedPriority == priority;
                      return FilterChip(
                        label: Text(priority),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedPriority = selected ? priority : 'All';
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppDimensions.spacingXL),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedStatus = 'All';
                              _selectedPriority = 'All';
                            });
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Apply filters
                            });
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),

                  // Bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
