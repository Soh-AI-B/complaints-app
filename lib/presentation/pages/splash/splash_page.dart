import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Start authentication check
    context.read<AuthBloc>().add(AuthStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            developer.log(
              'DEBUG SPLASH: User authenticated with role: ${state.user.role}',
            );
            // Navigate based on user role
            if (state.user.role == 'Manager' || state.user.role == 'Admin') {
              developer.log('DEBUG SPLASH: Navigating to manager home');
              Navigator.of(context).pushReplacementNamed(AppRoutes.managerHome);
            } else {
              developer.log('DEBUG SPLASH: Navigating to employee home');
              Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.employeeHome);
            }
          } else if (state is AuthUnauthenticated || state is AuthError) {
            developer.log(
              'DEBUG SPLASH: User not authenticated, navigating to login',
            );
            // Navigate to login
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                width: 120,
                height: 90,
              ),
              const SizedBox(height: 24),

              // App Name
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),

              // App Description
              const Text(
                AppStrings.appDescription,
                style: TextStyle(fontSize: 16, color: AppColors.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.textLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
