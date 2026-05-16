import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/tasks/task_bloc.dart';
import '../../blocs/tasks/task_event.dart';
import '../../blocs/tasks/task_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/tasks/status_badge.dart';
import '../../widgets/tasks/priority_badge.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/task.dart';
import '../../../data/repositories/task_note_repository_impl.dart';
import '../../widgets/common/full_screen_image_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  void _loadTask() {
    context.read<TaskBloc>().add(LoadTaskById(taskId: widget.taskId));
  }

  Stream<List<TaskNote>> _getNotesStream() {
    developer.log('Creating notes stream for task: ${widget.taskId}');
    return FirebaseFirestore.instance
        .collection('task_notes')
        .where('task_id', isEqualTo: widget.taskId)
        .snapshots()
        .map((snapshot) {
          developer.log('Stream received ${snapshot.docs.length} documents');
          final notes = snapshot.docs.map((doc) {
            developer.log('Processing document: ${doc.id}');
            final data = doc.data();
            developer.log('Document data: $data');

            return TaskNote(
              note: data['note'] as String? ?? '',
              authorName: data['author_name'] as String? ?? 'Unknown',
              authorEmail: data['author_email'] as String? ?? '',
              createdAt: data['created_at'] != null
                  ? (data['created_at'] as Timestamp).toDate()
                  : DateTime.now(),
            );
          }).toList();

          // Sort by created_at in Dart to avoid Firestore index requirement
          notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          developer.log('Converted to ${notes.length} TaskNote objects');
          return notes;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Task Details',
        actions: [
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoaded || state is TaskUpdated) {
                final task = state is TaskLoaded
                    ? state.task
                    : (state as TaskUpdated).task;
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  // Only show edit button if user can manage tasks
                  if (authState.user.canManageTasks) {
                    return IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditTaskBottomSheet(task);
                      },
                    );
                  }
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const LoadingWidget();
            } else if (state is TaskError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: _loadTask,
              );
            } else if (state is TaskLoaded) {
              return _buildTaskDetails(state.task);
            } else if (state is TaskUpdated) {
              return _buildTaskDetails(state.task);
            } else {
              return const CustomErrorWidget(message: 'Task not found');
            }
          },
        ),
      ),
    );
  }

  Widget _buildTaskDetails(Task task) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Header Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      StatusBadge(status: task.status),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingM),

                  // Priority and Category
                  Row(
                    children: [
                      PriorityBadge(priority: task.priority),
                      const SizedBox(width: AppDimensions.spacingM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingS,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          task.category,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Description Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: AppColors.primary,
                        size: AppDimensions.iconM,
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  Text(
                    task.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Task Information Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: AppDimensions.iconM,
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      Text(
                        'Task Information',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  _buildInfoRow('Created by', task.employeeName),
                  _buildInfoRow('Employee Email', task.employeeEmail),
                  _buildInfoRow(
                    'Date Reported',
                    DateFormatter.formatDateForDisplay(task.dateReported),
                  ),
                  _buildInfoRow(
                    'Last Updated',
                    DateFormatter.formatDateForDisplay(task.dateUpdated),
                  ),

                  if (task.assignedTo != null)
                    _buildInfoRow('Assigned To', task.assignedTo!),

                  if (task.estimatedCompletion != null)
                    _buildInfoRow(
                      'Estimated Completion',
                      DateFormatter.formatDateForDisplay(
                        task.estimatedCompletion!,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Manager Notes Card (if available)
          const SizedBox(height: AppDimensions.spacingM),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note_alt,
                        color: AppColors.primary,
                        size: AppDimensions.iconM,
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      Text(
                        'Manager Notes',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  // Notes will be loaded separately using the new notes system
                  StreamBuilder<List<TaskNote>>(
                    stream: _getNotesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error loading notes: ${snapshot.error}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.error),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text(
                          'No manager notes yet.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                        );
                      } else {
                        final notes = snapshot.data!;
                        return Column(
                          children: notes
                              .map(
                                (note) => Container(
                                  margin: const EdgeInsets.only(
                                    bottom: AppDimensions.spacingM,
                                  ),
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(
                                    AppDimensions.paddingM,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.05,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusM,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Note text
                                      Text(
                                        note.note,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(
                                        height: AppDimensions.spacingS,
                                      ),
                                      // Author and date info
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'By: ${note.authorName}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          Text(
                                            DateFormatter.formatDateForDisplay(
                                              note.createdAt,
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Task Image (if available)
          if (task.pictureUrl != null && task.pictureUrl!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.image,
                          color: AppColors.primary,
                          size: AppDimensions.iconM,
                        ),
                        const SizedBox(width: AppDimensions.spacingS),
                        Text(
                          'Attached Image',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    GestureDetector(
                      onTap: () {
                        // Open full-screen image viewer
                        FullScreenImageViewer.show(
                          context,
                          task.pictureUrl!,
                          title: 'Task: ${task.title}',
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusM,
                              ),
                              child: Image.network(
                                task.pictureUrl!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: AppColors.border,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusM,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: AppDimensions.iconL,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(
                                          height: AppDimensions.spacingS,
                                        ),
                                        Text(
                                          'Failed to load image',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Overlay with expand icon
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Bottom padding
          const SizedBox(height: AppDimensions.spacingXL),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTaskBottomSheet(Task task) {
    final taskBloc = context.read<TaskBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (context) => BlocProvider.value(
        value: taskBloc,
        child: _EditTaskBottomSheet(task: task),
      ),
    );
  }
}

class _EditTaskBottomSheet extends StatefulWidget {
  final Task task;

  const _EditTaskBottomSheet({required this.task});

  @override
  State<_EditTaskBottomSheet> createState() => _EditTaskBottomSheetState();
}

class _EditTaskBottomSheetState extends State<_EditTaskBottomSheet> {
  late String _selectedStatus;
  late String _selectedPriority;
  final _notesController = TextEditingController();

  final List<String> _statusOptions = [
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  final List<String> _priorityOptions = ['Low', 'Normal', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task.status;
    _selectedPriority = widget.task.priority;
    _notesController.text = '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateTask() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Check if status or priority changed
      bool hasChanges = false;

      if (_selectedStatus != widget.task.status ||
          _selectedPriority != widget.task.priority) {
        context.read<TaskBloc>().add(
          UpdateTask(
            taskId: widget.task.taskId,
            status: _selectedStatus,
            priority: _selectedPriority,
          ),
        );
        hasChanges = true;
      }

      // Add manager note if provided
      if (_notesController.text.trim().isNotEmpty) {
        // Use the task note repository directly since we don't have TaskNoteBloc in context
        _addNoteDirectly(
          _notesController.text.trim(),
          authState.user.name,
          authState.user.email,
        );
        hasChanges = true;
      }

      // Show message if no changes were made
      if (!hasChanges && _notesController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No changes made'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    // Close the bottom sheet
    Navigator.of(context).pop();
  }

  Future<void> _addNoteDirectly(
    String note,
    String authorName,
    String authorEmail,
  ) async {
    developer.log('Adding note: $note by $authorName');
    final repository = TaskNoteRepositoryImpl(
      firestore: FirebaseFirestore.instance,
    );

    final result = await repository.addNote(
      taskId: widget.task.taskId,
      note: note,
      authorName: authorName,
      authorEmail: authorEmail,
    );

    result.fold(
      (failure) {
        developer.log('Failed to add note: ${failure.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add note: ${failure.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (addedNote) {
        developer.log('Note added successfully: ${addedNote.note}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // The StreamBuilder will automatically update the UI
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingL,
        right: AppDimensions.paddingL,
        top: AppDimensions.paddingL,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingL,
      ),
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
            'Update Task',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacingL),

          // Status Selection
          Text(
            'Status',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingL),

          // Priority Selection (only for managers/admins)
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated &&
                  authState.user.canManageTasks) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPriority,
                          isExpanded: true,
                          items: _priorityOptions.map((String priority) {
                            return DropdownMenuItem<String>(
                              value: priority,
                              child: Text(priority),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedPriority = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                  ],
                );
              }
              return const SizedBox.shrink(); // Hide priority section for employees
            },
          ),

          // Manager Notes
          Text(
            'Add Manager Note',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Add a note about this task...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: AppDimensions.spacingXL),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: _updateTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Update'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
