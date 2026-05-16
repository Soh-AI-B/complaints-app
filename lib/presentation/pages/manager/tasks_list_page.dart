import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/tasks/task_bloc.dart';
import '../../blocs/tasks/task_event.dart';
import '../../blocs/tasks/task_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/app_bottom_navigation.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/tasks/task_card.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/routes/app_routes.dart';
import '../../../domain/entities/task.dart';

class TasksListPage extends StatefulWidget {
  final String? initialStatus;
  final String? initialPriority;

  const TasksListPage({super.key, this.initialStatus, this.initialPriority});

  @override
  State<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'Pending';
  String _selectedPriority = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _statusOptions = [
    'Pending',
    'In Progress',
    'All',
    'Completed',
    'Cancelled',
  ];
  final List<String> _priorityOptions = ['All'] + AppConstants.taskPriorities;
  final List<String> _categoryOptions = ['All'] + AppConstants.taskCategories;

  @override
  void initState() {
    super.initState();

    // Initialize filters based on passed parameters
    if (widget.initialStatus != null && widget.initialStatus!.isNotEmpty) {
      _selectedStatus = widget.initialStatus!;
    }
    if (widget.initialPriority != null) {
      _selectedPriority = widget.initialPriority!;
    }

    // Set tab controller index based on status
    int tabIndex = 0;
    if (_selectedStatus == 'In Progress') {
      tabIndex = 1;
    } else if (_selectedStatus == 'All') {
      tabIndex = 2;
    } else if (_selectedStatus == 'Completed') {
      tabIndex = 3;
    }

    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: tabIndex,
    );
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    context.read<TaskBloc>().add(const LoadAllTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'All Tasks',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTasks),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.taskManagement);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textLight),
      ),
      bottomNavigationBar: const AppBottomNavigation(
        currentRoute: AppRoutes.tasksList,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'In Progress'),
                Tab(text: 'All'),
                Tab(text: 'Completed'),
              ],
              onTap: (index) {
                setState(() {
                  _selectedStatus = _statusOptions[index];
                });
              },
            ),
          ),

          // Tasks List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadTasks();
              },
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
                    developer.log('📋 TasksListPage: BlocBuilder state = ${state.runtimeType}, tasks=${state is TasksLoaded ? state.tasks.length : 'N/A'}');
                    if (state is TaskLoading) {
                      developer.log('📋 TasksListPage: Loading...');
                      return const LoadingWidget();
                    } else if (state is TasksLoaded) {
                      developer.log('📋 TasksListPage: Loaded ${state.tasks.length} tasks, filtering with status=$_selectedStatus');
                      final filteredTasks = _filterTasks(state.tasks);
                      developer.log('📋 TasksListPage: After filter: ${filteredTasks.length} tasks');
                      return _buildTasksList(filteredTasks);
                    } else if (state is TaskError) {
                      developer.log('📋 TasksListPage: Error - ${state.message}');
                      return CustomErrorWidget(
                        message: state.message,
                        onRetry: _loadTasks,
                      );
                    } else {
                      developer.log('📋 TasksListPage: Initial/Unknown state');
                      return const EmptyStateWidget(
                        title: 'No Tasks',
                        message: 'No tasks found',
                        icon: Icons.assignment_outlined,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          title: 'No Tasks Found',
          message: _getEmptyMessage(),
          icon: Icons.assignment_outlined,
          actionText: 'Create Task',
          onAction: () {
            Navigator.of(context).pushNamed(AppRoutes.taskManagement);
          },
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.taskManagement, arguments: task);
          },
          onStatusChanged: (newStatus) {
            context.read<TaskBloc>().add(
              UpdateTask(taskId: task.taskId, status: newStatus),
            );
          },
          isManagerView: true,
        );
      },
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    List<Task> filteredTasks = tasks;

    // Filter by status
    if (_selectedStatus != 'All') {
      filteredTasks = filteredTasks
          .where((task) => task.status == _selectedStatus)
          .toList();
    }

    // Filter by priority
    if (_selectedPriority != 'All') {
      filteredTasks = filteredTasks
          .where((task) => task.priority == _selectedPriority)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks
          .where(
            (task) =>
                task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                task.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                task.employeeName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filteredTasks = filteredTasks
          .where((task) => task.category == _selectedCategory)
          .toList();
    }

    filteredTasks.sort((a, b) {
      final aDone = a.status == 'Completed' || a.status == 'Cancelled';
      final bDone = b.status == 'Completed' || b.status == 'Cancelled';
      if (aDone != bDone) return aDone ? 1 : -1;
      if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
      if (a.isOverdue != b.isOverdue) return a.isOverdue ? -1 : 1;
      return b.dateReported.compareTo(a.dateReported);
    });

    return filteredTasks;
  }

  String _getEmptyMessage() {
    if (_selectedStatus != 'All') {
      return 'No ${_selectedStatus.toLowerCase()} tasks found';
    }
    if (_selectedPriority != 'All') {
      return 'No ${_selectedPriority.toLowerCase()} priority tasks found';
    }
    if (_selectedCategory != 'All') {
      return 'No ${_selectedCategory.toLowerCase()} category tasks found';
    }
    if (_searchQuery.isNotEmpty) {
      return 'No tasks found matching "$_searchQuery"';
    }
    return 'No tasks found';
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusL),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppDimensions.paddingL,
            AppDimensions.paddingL,
            AppDimensions.paddingL,
            MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Tasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by title, description, or employee...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onSubmitted: (value) {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: AppDimensions.spacingL),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textSecondary,
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Search'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusL),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Filter Tasks',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.spacingL),

                            // Status Filter
                            Text(
                              'Status',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
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
                                      _selectedStatus = status;
                                    });
                                  },
                                  selectedColor: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  checkmarkColor: AppColors.primary,
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: AppDimensions.spacingL),

                            // Priority Filter
                            Text(
                              'Priority',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: AppDimensions.spacingS),
                            Wrap(
                              spacing: AppDimensions.spacingS,
                              children: _priorityOptions.map((priority) {
                                final isSelected =
                                    _selectedPriority == priority;
                                return FilterChip(
                                  label: Text(priority),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      _selectedPriority = priority;
                                    });
                                  },
                                  selectedColor: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  checkmarkColor: AppColors.primary,
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: AppDimensions.spacingL),

                            // Category Filter
                            Text(
                              'Category',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: AppDimensions.spacingS),
                            Wrap(
                              spacing: AppDimensions.spacingS,
                              children: _categoryOptions.map((category) {
                                final isSelected =
                                    _selectedCategory == category;
                                return FilterChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                  selectedColor: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  checkmarkColor: AppColors.primary,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppDimensions.spacingL),
                          ],
                        ),
                      ),
                    ),

                    // Actions fixed at bottom
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedStatus = 'All';
                                _selectedPriority = 'All';
                                _selectedCategory = 'All';
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {}); // 🔥 update parent filter state
                              Navigator.of(context).pop();
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
