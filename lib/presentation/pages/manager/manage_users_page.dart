import 'package:complaints/domain/entities/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/user.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../blocs/user/user_state.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    // Load all users
    context.read<UserBloc>().add(const LoadAllUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Manage Users'),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            currentUser = authState.user;

            // Check if current user has permission to manage users
            if (!currentUser!.canManageUsers) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 64, color: AppColors.error),
                    SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'Access Denied',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacingS),
                    Text(
                      'You do not have permission to manage users.\nOnly admins can access this feature.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return _buildUserManagement();
          }

          return const LoadingWidget();
        },
      ),
    );
  }

  Widget _buildUserManagement() {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User ${state.userEmail} has been deleted from the system.\n',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is UserRoleUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User role updated successfully for ${state.userEmail}',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
          // Reload users to get updated data
          context.read<UserBloc>().add(const LoadAllUsers());
        } else if (state is UserStatusUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User status updated successfully for ${state.userEmail}',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
          // Reload users to get updated data
          context.read<UserBloc>().add(const LoadAllUsers());
        } else if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const LoadingWidget();
          }

          if (state is UserError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<UserBloc>().add(const LoadAllUsers());
              },
            );
          }

          if (state is AllUsersLoaded) {
            return _buildUsersList(state.users);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUsersList(List<User> users) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppDimensions.spacingM),
            Text(
              'No users found',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 20,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
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
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.userEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRoleChip(user.role),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                Icon(Icons.group, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Team: ${user.team}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (user.phone != null && user.phone!.isNotEmpty) ...[
                  Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    user.phone!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showChangeRoleDialog(user),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Change Role'),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                OutlinedButton.icon(
                  onPressed: user.isActive
                      ? () => _showDeactivateDialog(user)
                      : () => _activateUser(user),
                  icon: Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    size: 16,
                  ),
                  label: Text(user.isActive ? 'Deactivate' : 'Activate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: user.isActive
                        ? AppColors.error
                        : AppColors.success,
                    side: BorderSide(
                      color: user.isActive
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                IconButton(
                  onPressed: () => _showDeleteUserDialog(user),
                  icon: const Icon(Icons.delete_forever, size: 18),
                  color: AppColors.error,
                  tooltip: 'Delete User',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    Color chipColor;
    Color backgroundColor;

    switch (role.toLowerCase()) {
      case 'admin':
        chipColor = AppColors.error;
        backgroundColor = AppColors.error.withOpacity(0.1);
        break;
      case 'manager':
        chipColor = AppColors.primary;
        backgroundColor = AppColors.primary.withOpacity(0.1);
        break;
      case 'employee':
      default:
        chipColor = AppColors.secondary;
        backgroundColor = AppColors.secondary.withOpacity(0.1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }

  void _showChangeRoleDialog(User user) {
    // Prevent changing admin role
    if (user.role.toLowerCase() == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin role cannot be changed'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    String selectedRole = user.role;
    List<String> selectedCategories = List<String>.from(
      user.managedCategories ?? [],
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Change Role for ${user.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current role: ${user.role}'),
                const SizedBox(height: AppDimensions.spacingM),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'New Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Employee',
                      child: Text('Employee'),
                    ),
                    DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                      // Clear categories if not manager
                      if (selectedRole != 'Manager') {
                        selectedCategories = [];
                      }
                    });
                  },
                ),

                // Show category selection for managers
                if (selectedRole == 'Manager') ...[
                  const SizedBox(height: AppDimensions.spacingM),
                  const Text(
                    'Managed Categories:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  const Text(
                    'Select the categories this manager will handle:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  _buildCategorySelection(selectedCategories, setState),
                  const SizedBox(height: AppDimensions.spacingS),
                  if (selectedCategories.isEmpty)
                    const Text(
                      'Note: No categories selected = manager handles ALL categories',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],

                if (selectedRole == 'Admin') ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  const Text(
                    'Warning: Admin users have full system access including user management.',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _hasChanges(user, selectedRole, selectedCategories)
                  ? () {
                      Navigator.of(context).pop();
                      _updateUserRole(
                        user,
                        selectedRole,
                        managedCategories: selectedRole == 'Manager'
                            ? selectedCategories
                            : null,
                      );
                    }
                  : null,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeactivateDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Text('Are you sure you want to deactivate ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deactivateUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(User user) {
    // Prevent deleting admin users
    if (user.role.toLowerCase() == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin users cannot be deleted for security reasons'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Prevent users from deleting themselves
    if (currentUser != null && user.userEmail == currentUser!.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot delete your own account'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to permanently delete ${user.name}?'),
            const SizedBox(height: AppDimensions.spacingM),
            const Text(
              'This action will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            const Text('• Remove the user account from the system'),
            const Text('• Mark all user data as deleted'),
            const Text('• Create a request to delete authentication account'),
            const Text('• User will no longer be able to access the app'),
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                  SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      'Authentication account deletion requires admin privileges and may be processed separately.',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _updateUserRole(
    User user,
    String newRole, {
    List<String>? managedCategories,
  }) {
    context.read<UserBloc>().add(
      UpdateUserRole(
        userEmail: user.userEmail,
        newRole: newRole,
        managedCategories: managedCategories,
      ),
    );
  }

  void _deactivateUser(User user) {
    context.read<UserBloc>().add(
      UpdateUserStatus(userEmail: user.userEmail, isActive: false),
    );
  }

  void _activateUser(User user) {
    context.read<UserBloc>().add(
      UpdateUserStatus(userEmail: user.userEmail, isActive: true),
    );
  }

  void _deleteUser(User user) {
    context.read<UserBloc>().add(DeleteUser(userEmail: user.userEmail));
  }

  // Build category selection widget for managers
  Widget _buildCategorySelection(
    List<String> selectedCategories,
    StateSetter setState,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Select All / Clear All buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedCategories.clear();
                      selectedCategories.addAll(AppConstants.taskCategories);
                    });
                  },
                  icon: const Icon(Icons.select_all, size: 16),
                  label: const Text(
                    'Select All',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedCategories.clear();
                    });
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text(
                    'Clear All',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Category checkboxes
          ...AppConstants.taskCategories
              .map(
                (category) => CheckboxListTile(
                  title: Text(category, style: const TextStyle(fontSize: 13)),
                  value: selectedCategories.contains(category),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedCategories.add(category);
                      } else {
                        selectedCategories.remove(category);
                      }
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  // Helper method to check if there are changes to enable/disable the Update button
  bool _hasChanges(
    User user,
    String selectedRole,
    List<String> selectedCategories,
  ) {
    // Check if role changed
    if (selectedRole != user.role) {
      print('Role changed: ${user.role} -> $selectedRole');
      return true;
    }

    // Check if categories changed (only relevant for managers)
    if (selectedRole == 'Manager') {
      final currentCategories = user.managedCategories ?? [];
      // Use DeepCollectionEquality to properly compare list contents
      final hasChanges = !const DeepCollectionEquality().equals(
        selectedCategories,
        currentCategories,
      );
      print('Categories comparison:');
      print('  Current: $currentCategories');
      print('  Selected: $selectedCategories');
      print('  Has changes: $hasChanges');
      return hasChanges;
    }

    return false;
  }
}
