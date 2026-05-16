import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class AppBottomNavigation extends StatelessWidget {
  final String currentRoute;

  const AppBottomNavigation({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final user = state.user;
        final items = user.canManageTasks
            ? _managerItems(canManageUsers: user.canManageUsers)
            : _employeeItems();
        final currentIndex = items.indexWhere(
          (item) => item.route == currentRoute,
        );

        return NavigationBar(
          selectedIndex: currentIndex < 0 ? 0 : currentIndex,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            final route = items[index].route;
            if (route == currentRoute) return;
            Navigator.of(context).pushReplacementNamed(route);
          },
          destinations: items
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
              )
              .toList(),
        );
      },
    );
  }

  List<_BottomNavItem> _employeeItems() {
    return const [
      _BottomNavItem(
        route: AppRoutes.employeeHome,
        label: 'Home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
      _BottomNavItem(
        route: AppRoutes.addComplaint,
        label: 'New',
        icon: Icons.add_circle_outline,
        selectedIcon: Icons.add_circle,
      ),
      _BottomNavItem(
        route: AppRoutes.myTasks,
        label: 'Tasks',
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment,
      ),
    ];
  }

  List<_BottomNavItem> _managerItems({required bool canManageUsers}) {
    return [
      const _BottomNavItem(
        route: AppRoutes.managerHome,
        label: 'Home',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
      ),
      const _BottomNavItem(
        route: AppRoutes.tasksList,
        label: 'Tasks',
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment,
      ),
      const _BottomNavItem(
        route: AppRoutes.analytics,
        label: 'Analytics',
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics,
      ),
      if (canManageUsers)
        const _BottomNavItem(
          route: AppRoutes.manageUsers,
          label: 'Users',
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
        )
      else
        const _BottomNavItem(
          route: AppRoutes.notifications,
          label: 'Alerts',
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
        ),
    ];
  }
}

class _BottomNavItem {
  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _BottomNavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
