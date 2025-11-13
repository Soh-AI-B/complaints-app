import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routes/route_generator.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/colors.dart';
import 'core/constants/strings.dart';
import 'core/services/navigation_service.dart';
import 'core/services/web_redirect_service.dart';
import 'core/services/platform_service.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'injection_container.dart' as di;

class ComplaintsApp extends StatefulWidget {
  const ComplaintsApp({super.key});

  @override
  State<ComplaintsApp> createState() => _ComplaintsAppState();
}

class _ComplaintsAppState extends State<ComplaintsApp> {
  bool _hasCheckedRedirect = false;

  @override
  void initState() {
    super.initState();
    _checkPlatformAndRedirect();
  }

  Future<void> _checkPlatformAndRedirect() async {
    // Small delay to ensure context is available
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted && !_hasCheckedRedirect) {
      _hasCheckedRedirect = true;

      // Check for device compatibility issues
      final hasDeviceIssues =
          await PlatformService.hasDeviceCompatibilityIssues();

      // Check if redirect is needed
      final shouldRedirect = await WebRedirectService.checkAndHandleRedirect(
        context,
        hasDeviceIssues: hasDeviceIssues,
      );

      if (shouldRedirect) {
        // The redirect service will handle showing the dialog and redirecting
        // The app will continue to run but users will be prompted to use web
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>(),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );
  }
}
