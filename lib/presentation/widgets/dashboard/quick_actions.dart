import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback? onAddComplaint;
  final VoidCallback? onViewTasks;
  final VoidCallback? onViewAnalytics;
  final VoidCallback? onManageTasks;
  final VoidCallback? onManageUsers;

  const QuickActions({
    super.key,
    this.onAddComplaint,
    this.onViewTasks,
    this.onViewAnalytics,
    this.onManageTasks,
    this.onManageUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF253b74),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (onAddComplaint != null)
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.add_circle_outline,
                  title: 'Add Complaint',
                  subtitle: 'Report new issue',
                  color: const Color(0xFF91be3f),
                  onTap: onAddComplaint!,
                ),
              ),
            if (onAddComplaint != null && onViewTasks != null)
              const SizedBox(width: 12),
            if (onViewTasks != null)
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.assignment_outlined,
                  title: 'My Tasks',
                  subtitle: 'View all tasks',
                  color: const Color(0xFF1b75bc),
                  onTap: onViewTasks!,
                ),
              ),
          ],
        ),
        if (onViewAnalytics != null || onManageTasks != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (onViewAnalytics != null)
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.analytics_outlined,
                    title: 'Analytics',
                    subtitle: 'View reports',
                    color: const Color(0xFF253b74),
                    onTap: onViewAnalytics!,
                  ),
                ),
              if (onViewAnalytics != null && onManageTasks != null)
                const SizedBox(width: 12),
              if (onManageTasks != null)
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.manage_accounts_outlined,
                    title: 'Manage Tasks',
                    subtitle: 'Assign & update',
                    color: Colors.orange,
                    onTap: onManageTasks!,
                  ),
                ),
            ],
          ),
        ],
        if (onManageUsers != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.people_outline,
                  title: 'Manage Users',
                  subtitle: 'User roles & status',
                  color: const Color(0xFF7B1FA2),
                  onTap: onManageUsers!,
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ), // Empty space to balance the row
            ],
          ),
        ],
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
