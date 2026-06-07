import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../domain/entities/user.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../blocs/user/user_state.dart';
import '../../widgets/common/app_bottom_navigation.dart';
import '../../widgets/common/custom_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const List<String> _defaultTimes = ['08:00', '12:00', '16:00'];

  bool _notificationEnabled = true;
  bool _taskReminderEnabled = true;
  bool _newTaskEnabled = true;
  List<String> _notificationTimes = List<String>.from(_defaultTimes);
  bool _isDirty = false;
  bool _hasLoadedUser = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<UserBloc>().add(
        LoadUserProfile(userEmail: authState.user.email),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentRoute =
        authState is AuthAuthenticated && authState.user.canManageTasks
        ? AppRoutes.managerHome
        : AppRoutes.employeeHome;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'Settings'),
      bottomNavigationBar: AppBottomNavigation(currentRoute: currentRoute),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserProfileLoaded && !_hasLoadedUser) {
            _syncFromUser(state.user);
          } else if (state is UserProfileUpdated) {
            _syncFromUser(state.user);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Settings saved')));
          } else if (state is UserError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is UserLoading && !_hasLoadedUser) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authState is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final canManageTasks = authState.user.canManageTasks;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Preferences'),
                const SizedBox(height: 12),
                _buildLanguagePlaceholder(),
                if (canManageTasks) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('Notifications'),
                  const SizedBox(height: 12),
                  _buildNotificationSettings(state is UserLoading),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _syncFromUser(User user) {
    setState(() {
      _notificationEnabled = user.notificationEnabled ?? true;
      _taskReminderEnabled = user.taskReminderNotificationsEnabled ?? true;
      _newTaskEnabled = user.newTaskNotificationsEnabled ?? true;
      _notificationTimes = List<String>.from(
        user.notificationTimes?.isNotEmpty == true
            ? user.notificationTimes!
            : _defaultTimes,
      )..sort();
      _isDirty = false;
      _hasLoadedUser = true;
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildLanguagePlaceholder() {
    return _settingsPanel(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: _iconBadge(Icons.language_outlined, AppColors.subColor),
          title: const Text(
            'Language',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('Coming soon'),
          trailing: const Icon(
            Icons.lock_clock,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(bool isSaving) {
    return _settingsPanel(
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: _iconBadge(
            Icons.notifications_outlined,
            AppColors.primary,
          ),
          title: const Text(
            'Enable notifications',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('Master switch for manager/admin alerts'),
          value: _notificationEnabled,
          onChanged: (value) => _markDirty(() {
            _notificationEnabled = value;
          }),
        ),
        const Divider(),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: _iconBadge(Icons.schedule_outlined, AppColors.warning),
          title: const Text(
            'Task reminders',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text(
            'Daily pending-task summaries at selected times',
          ),
          value: _notificationEnabled && _taskReminderEnabled,
          onChanged: _notificationEnabled
              ? (value) => _markDirty(() {
                  _taskReminderEnabled = value;
                })
              : null,
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: _iconBadge(Icons.assignment_add, AppColors.secondary),
          title: const Text(
            'New task alerts',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('Push alerts when a new task is created'),
          value: _notificationEnabled && _newTaskEnabled,
          onChanged: _notificationEnabled
              ? (value) => _markDirty(() {
                  _newTaskEnabled = value;
                })
              : null,
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reminder times',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            IconButton(
              tooltip: 'Add reminder time',
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primary,
              onPressed: _notificationEnabled && _taskReminderEnabled
                  ? _addReminderTime
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _notificationTimes
              .map(
                (time) => InputChip(
                  avatar: const Icon(Icons.access_time, size: 18),
                  label: Text(time),
                  onDeleted: _notificationTimes.length > 1
                      ? () => _markDirty(() {
                          _notificationTimes.remove(time);
                        })
                      : null,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Save Settings'),
            onPressed: _isDirty && !isSaving ? _saveSettings : null,
          ),
        ),
      ],
    );
  }

  Widget _settingsPanel({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _iconBadge(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }

  void _markDirty(VoidCallback update) {
    setState(() {
      update();
      _isDirty = true;
    });
  }

  Future<void> _addReminderTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );

    if (selected == null) return;

    final formatted = _formatTime(selected);
    if (_notificationTimes.contains(formatted)) return;

    _markDirty(() {
      _notificationTimes.add(formatted);
      _notificationTimes.sort();
    });
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _saveSettings() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<UserBloc>().add(
      UpdateUserProfile(
        userEmail: authState.user.email,
        notificationEnabled: _notificationEnabled,
        taskReminderNotificationsEnabled: _taskReminderEnabled,
        newTaskNotificationsEnabled: _newTaskEnabled,
        notificationTimes: _notificationTimes,
      ),
    );
  }
}
