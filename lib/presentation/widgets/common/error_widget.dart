import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: AppDimensions.iconXXL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingM,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Network Error Widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message:
          'No internet connection. Please check your network settings and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

// Server Error Widget
class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      message: 'Server is temporarily unavailable. Please try again later.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
    );
  }
}

// Not Found Error Widget
class NotFoundErrorWidget extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onGoBack;

  const NotFoundErrorWidget({super.key, this.customMessage, this.onGoBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: AppDimensions.iconXXL,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Not Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              customMessage ??
                  'The content you are looking for could not be found.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onGoBack != null) ...[
              const SizedBox(height: AppDimensions.spacingL),
              ElevatedButton.icon(
                onPressed: onGoBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingM,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: AppDimensions.iconXXL,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: AppDimensions.spacingL),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingM,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
