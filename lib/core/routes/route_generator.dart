import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../injection_container.dart' as di;
import '../../presentation/blocs/notifications/notification_bloc.dart';
import '../../presentation/blocs/tasks/task_bloc.dart';
import '../../presentation/blocs/user/user_bloc.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/firebase_not_available_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/forget_password_page.dart';
import '../../presentation/pages/employee/employee_home_page.dart';
import '../../presentation/pages/employee/add_complaint_page.dart';
import '../../presentation/pages/employee/my_tasks_page.dart';
import '../../presentation/pages/employee/task_detail_page.dart';
import '../../presentation/pages/manager/manager_home_page.dart';
import '../../presentation/pages/manager/dashboard_page.dart';
import '../../presentation/pages/manager/tasks_list_page.dart';
import '../../presentation/pages/manager/task_management_page.dart';
import '../../presentation/pages/manager/analytics_page.dart';
import '../../presentation/pages/manager/manage_users_page.dart';
import '../../presentation/pages/manager/notifications_page.dart';
import '../../presentation/pages/admin/admin_setup_page.dart';
import '../../domain/entities/task.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (context) {
            // Check if Firebase services are available
            try {
              // Use existing AuthBloc from the app-level provider
              return const SplashPage();
            } catch (e) {
              // Firebase not available, show fallback page
              return const FirebaseNotAvailablePage();
            }
          },
        );

      case AppRoutes.login:
        return MaterialPageRoute(builder: (context) => const LoginPage());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (context) => const RegisterPage());

      case AppRoutes.forgetPassword:
        return MaterialPageRoute(
          builder: (context) => const ForgetPasswordPage(),
        );

      case AppRoutes.employeeHome:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<TaskBloc>(),
            child: const EmployeeHomePage(),
          ),
        );

      case AppRoutes.managerHome:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<TaskBloc>(),
            child: const ManagerHomePage(),
          ),
        );

      case AppRoutes.addComplaint:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<TaskBloc>(),
            child: const AddComplaintPage(),
          ),
        );

      case AppRoutes.myTasks:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<TaskBloc>(),
            child: const MyTasksPage(),
          ),
        );

      case AppRoutes.taskDetail:
        final taskId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<TaskBloc>(),
            child: TaskDetailPage(taskId: taskId ?? ''),
          ),
        );

      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<TaskBloc>(),
            child: const DashboardPage(),
          ),
        );

      case AppRoutes.tasksList:
        final arguments = settings.arguments as Map<String, String?>?;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<TaskBloc>(),
            child: TasksListPage(
              initialStatus: arguments?['status'],
              initialPriority: arguments?['priority'],
            ),
          ),
        );

      case AppRoutes.taskManagement:
        final task = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<TaskBloc>(),
            child: TaskManagementPage(task: task as Task?),
          ),
        );

      case AppRoutes.analytics:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<TaskBloc>(),
            child: const AnalyticsPage(),
          ),
        );

      case AppRoutes.manageUsers:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<UserBloc>(),
            child: const ManageUsersPage(),
          ),
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => di.sl<NotificationBloc>(),
            child: const NotificationsPage(),
          ),
        );

      case AppRoutes.adminSetup:
        return MaterialPageRoute(builder: (context) => const AdminSetupPage());

      // TODO: Add other routes as we implement the pages

      default:
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Route not found: ${routeName ?? 'Unknown'}',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.splash, (route) => false),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
