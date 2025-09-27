import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../../../core/utils/date_formatter.dart';
import '../../blocs/tasks/task_bloc.dart';
import '../../blocs/tasks/task_event.dart';
import '../../blocs/tasks/task_state.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/full_screen_image_viewer.dart';
import '../../widgets/common/cross_file_image.dart';
import '../../widgets/tasks/category_dropdown.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/task.dart';
import '../../../data/repositories/task_note_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../../core/utils/web_compatible_image_picker.dart';
import '../../../core/utils/file_helper.dart';
import '../../../core/services/cloudinary_service.dart';

class TaskManagementPage extends StatefulWidget {
  final Task? task; // For editing existing task

  const TaskManagementPage({super.key, this.task});

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _employeeEmailController =
      TextEditingController();
  final TextEditingController _managerNotesController = TextEditingController();

  String _selectedCategory = 'Logistics';
  String _selectedPriority = 'Normal';
  String _selectedStatus = 'Pending';
  DateTime? _estimatedCompletion;
    List<CrossFile> _selectedImages = []; // Changed to support multiple images
  List<String> _currentImageUrls = []; // Changed to support multiple images

  // Employee selection - COMMENTED OUT (not needed for complaint creation)
  // List<User> _employees = [];
  // User? _selectedEmployee;
  // bool _loadingEmployees = true;

  // Image upload service
  final _cloudinaryService = CloudinaryService();
  bool _isUploading = false;

  bool get _isEditing => widget.task != null;

  final List<String> _categories = AppConstants.taskCategories;

  final List<String> _priorities = AppConstants.taskPriorities;
  final List<String> _statuses = AppConstants.taskStatuses;

  @override
  void initState() {
    super.initState();
    // _fetchEmployees(); // Removed - not needed for complaint creation
    if (_isEditing) {
      _initializeFieldsWithTaskData();
    }
  }

  void _initializeFieldsWithTaskData() {
    final task = widget.task!;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _employeeNameController.text = task.employeeName;
    _employeeEmailController.text = task.employeeEmail;
    _managerNotesController.text = ''; // Notes are now handled separately
    _selectedCategory = task.category;
    _selectedPriority = task.priority;
    _selectedStatus = task.status;
    _estimatedCompletion = task.estimatedCompletion;

    // Initialize image URLs - support both old and new format
    _currentImageUrls.clear();
    if (task.pictureUrl != null && task.pictureUrl!.isNotEmpty) {
      _currentImageUrls.add(task.pictureUrl!);
    }
    if (task.pictureUrls != null && task.pictureUrls!.isNotEmpty) {
      _currentImageUrls.addAll(task.pictureUrls!);
    }

    // Employee selection logic removed - complaints are created by managers for themselves
    // The original employee data (task creator) is preserved in the model
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _employeeNameController.dispose();
    _employeeEmailController.dispose();
    _managerNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Complaint' : 'Create Complaint',
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
              color: AppColors.error,
            ),
          ],
        ],
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskCreated || state is TaskUpdated) {
            setState(() {
              _isUploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Complaint updated successfully'
                      : 'Complaint created successfully',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is TaskError) {
            setState(() {
              _isUploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information Section
                _buildSectionHeader('Basic Information'),
                const SizedBox(height: AppDimensions.spacingM),

                CustomTextField(
                  controller: _titleController,
                  label: 'Complaint Title',
                  hint: 'Enter complaint title',
                  validator: Validators.validateRequired,
                  maxLines: 1,
                ),

                const SizedBox(height: AppDimensions.spacingM),

                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Enter complaint description',
                  validator: Validators.validateRequired,
                  maxLines: 4,
                ),

                const SizedBox(height: AppDimensions.spacingM),

                // Category and Priority Row
                Row(
                  children: [
                    Expanded(
                      child: CategoryDropdown(
                        value: _selectedCategory,
                        categories: _categories,
                        label: 'Category',
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Priority',
                        value: _selectedPriority,
                        items: _priorities,
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingL),

                // Assignment Section - COMMENTED OUT
                // Managers now create complaints for themselves, not assign to others
                // _buildSectionHeader('Assignment'),
                // const SizedBox(height: AppDimensions.spacingM),
                // _buildEmployeeDropdown(),
                if (_isEditing) ...[
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildDropdownField(
                    label: 'Status',
                    value: _selectedStatus,
                    items: _statuses,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ],

                const SizedBox(height: AppDimensions.spacingM),

                // Estimated Completion Date
                _buildDatePickerField(),

                const SizedBox(height: AppDimensions.spacingL),

                // Manager Notes Section (only for editing)
                if (_isEditing) ...[
                  _buildSectionHeader('Manager Notes'),
                  const SizedBox(height: AppDimensions.spacingM),

                  CustomTextField(
                    controller: _managerNotesController,
                    label: 'Manager Notes',
                    hint: 'Add notes for the employee...',
                    maxLines: 3,
                  ),

                  const SizedBox(height: AppDimensions.spacingL),
                ],

                // Show Manager Notes
                if (_isEditing) ...[
                  Card(
                    margin: EdgeInsets.zero,
                    color: AppColors.background,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: AppColors.primary,
                                size: AppDimensions.iconM,
                              ),
                              const SizedBox(width: AppDimensions.spacingS),
                              Text(
                                'Previous Notes',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacingM),

                          // Notes Stream
                          StreamBuilder<List<TaskNote>>(
                            stream: _getNotesStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error loading notes: ${snapshot.error}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.error),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Text(
                                  'No previous notes yet.',
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
                                            color: AppColors.primary
                                                .withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(
                                              AppDimensions.radiusM,
                                            ),
                                            border: Border.all(
                                              color: AppColors.primary
                                                  .withOpacity(0.2),
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

                                              // Author + date row
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'By: ${note.authorName}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: AppColors
                                                              .textSecondary,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                          color: AppColors
                                                              .textSecondary,
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
                ],

                const SizedBox(height: AppDimensions.spacingM),

                // Image Section
                _buildSectionHeader('Attachments'),
                const SizedBox(height: AppDimensions.spacingM),

                _buildImageSection(),

                const SizedBox(height: AppDimensions.spacingXL),

                // Action Buttons
                BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    final isLoading = state is TaskLoading || _isUploading;

                    return Column(
                      children: [
                        CustomButton(
                          text: _isUploading
                              ? 'Uploading...'
                              : (_isEditing
                                    ? 'Update Complaint'
                                    : 'Create Complaint'),
                          onPressed: isLoading ? null : _submitForm,
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textLight,
                                  ),
                                )
                              : null,
                        ),

                        const SizedBox(height: AppDimensions.spacingM),

                        OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stream<List<TaskNote>> _getNotesStream() {
    print('Creating notes stream for task: ${widget.task!.taskId}');
    return FirebaseFirestore.instance
        .collection('task_notes')
        .where('task_id', isEqualTo: widget.task!.taskId)
        .snapshots()
        .map((snapshot) {
          print('Stream received ${snapshot.docs.length} documents');
          final notes = snapshot.docs.map((doc) {
            print('Processing document: ${doc.id}');
            final data = doc.data();
            print('Document data: $data');

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

          print('Converted to ${notes.length} TaskNote objects');
          return notes;
        });
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimated Completion Date',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _estimatedCompletion != null
                      ? '${_estimatedCompletion!.day}/${_estimatedCompletion!.month}/${_estimatedCompletion!.year}'
                      : 'Select completion date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _estimatedCompletion != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: AppDimensions.iconS,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    final totalImages = _selectedImages.length + _currentImageUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (totalImages > 0) ...[
          Text(
            'Images (${totalImages}/${AppConstants.maxImagesPerTask})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),

          // Display current images (from database)
          if (_currentImageUrls.isNotEmpty)
            _buildImageGrid(_currentImageUrls, true),

          // Display selected images (to be uploaded)
          if (_selectedImages.isNotEmpty) ...[
            if (_currentImageUrls.isNotEmpty)
              const SizedBox(height: AppDimensions.spacingM),
            _buildSelectedImageGrid(),
          ],
        ],

        // Add image button
        const SizedBox(height: AppDimensions.spacingM),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: totalImages == 0 ? 'Add Images' : 'Add More Images',
                onPressed: totalImages >= AppConstants.maxImagesPerTask
                    ? null
                    : () => _showImagePickerDialog(),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                textColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageGrid(List<String> imageUrls, bool isCurrentImages) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                FullScreenImageViewer.show(
                  context,
                  imageUrls[index],
                  title: _isEditing
                      ? 'Complaint: ${widget.task?.title ?? 'Image'}'
                      : 'New Complaint Image',
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.border,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Error',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Remove button
            if (isCurrentImages)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeCurrentImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => _showLocalImageDialog(_selectedImages[index]),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  child: CrossFileImage(
                    crossFile: _selectedImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            // Remove button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeSelectedImage(index),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocalImageDialog(CrossFile imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Image Preview'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              kIsWeb
                  ? FutureBuilder<Uint8List>(
                      future: imageFile.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Expanded(
                            child: Image.memory(
                              snapshot.data!,
                              fit: BoxFit.contain,
                            ),
                          );
                        }
                        return const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    )
                  : FutureBuilder<Uint8List>(
                      future: imageFile.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Expanded(
                            child: Image.memory(
                              snapshot.data!,
                              fit: BoxFit.contain,
                            ),
                          );
                        }
                        return const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _estimatedCompletion ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _estimatedCompletion) {
      setState(() {
        _estimatedCompletion = picked;
      });
    }
  }

  void _pickImage() async {
    // Check if we've reached the maximum number of images
    if (_selectedImages.length + _currentImageUrls.length >=
        AppConstants.maxImagesPerTask) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maximum ${AppConstants.maxImagesPerTask} images allowed per task',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final image = await WebCompatibleImagePickerHelper.pickImageFromCamera(context);
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  void _pickImageFromGallery() async {
    // Check if we've reached the maximum number of images
    if (_selectedImages.length + _currentImageUrls.length >=
        AppConstants.maxImagesPerTask) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maximum ${AppConstants.maxImagesPerTask} images allowed per task',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final image = await WebCompatibleImagePickerHelper.pickImageFromGallery(context);
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeCurrentImage(int index) {
    setState(() {
      _currentImageUrls.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        _updateTask();
      } else {
        _createTask();
      }
    }
  }

  void _createTask() async {
    // Get authenticated manager's data
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a complaint'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      List<String> imageUrls = [];

      // Upload new images if selected
      if (_selectedImages.isNotEmpty) {
        for (int i = 0; i < _selectedImages.length; i++) {
          final fileName =
              'complaint_${DateTime.now().millisecondsSinceEpoch}_$i';
          final imageUrl = await _cloudinaryService.uploadOptimizedImage(
            imageFile: _selectedImages[i],
            fileName: fileName,
            folder: 'complaints',
          );
          imageUrls.add(imageUrl);
        }
      }

      // Add existing image URLs
      imageUrls.addAll(_currentImageUrls);

      // Create complaint using manager's own data
      context.read<TaskBloc>().add(
        CreateTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          employeeName: authState.user.name, // Manager's name
          employeeEmail: authState.user.email, // Manager's email
          estimatedCompletion: _estimatedCompletion,
          pictureUrls: imageUrls.isNotEmpty ? imageUrls : null,
        ),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _updateTask() async {
    setState(() {
      _isUploading = true;
    });

    try {
      List<String> imageUrls = List.from(_currentImageUrls);

      // Upload new images if selected
      if (_selectedImages.isNotEmpty) {
        for (int i = 0; i < _selectedImages.length; i++) {
          final fileName =
              'complaint_${widget.task!.taskId}_${DateTime.now().millisecondsSinceEpoch}_$i';
          final imageUrl = await _cloudinaryService.uploadOptimizedImage(
            imageFile: _selectedImages[i],
            fileName: fileName,
            folder: 'complaints',
          );
          imageUrls.add(imageUrl);
        }
      }

      // Update the complaint without changing employee assignment (keeps original creator)
      context.read<TaskBloc>().add(
        UpdateTask(
          taskId: widget.task!.taskId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          status: _selectedStatus,
          estimatedCompletion: _estimatedCompletion,
          pictureUrls: imageUrls,
        ),
      );

      // Handle notes separately if there's a note to add
      if (_managerNotesController.text.trim().isNotEmpty) {
        _addManagerNote(_managerNotesController.text.trim());
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _addManagerNote(String note) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final repository = TaskNoteRepositoryImpl(
        firestore: FirebaseFirestore.instance,
      );

      await repository.addNote(
        taskId: widget.task!.taskId,
        note: note,
        authorName: authState.user.name,
        authorEmail: authState.user.email,
      );
    }
  }

  void _showDeleteConfirmation() {
    // Capture the blocs from the current context before showing dialog
    final taskBloc = context.read<TaskBloc>();
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Complaint'),
        content: const Text(
          'Are you sure you want to delete this complaint? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();

              // Get the current user role for authorization
              final authState = authBloc.state;
              if (authState is AuthAuthenticated) {
                taskBloc.add(
                  DeleteTask(
                    taskId: widget.task!.taskId,
                    userRole: authState.user.role,
                  ),
                );
                Navigator.of(context).pop();
              } else {
                // Show error if user is not authenticated
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You must be logged in to delete complaints'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
