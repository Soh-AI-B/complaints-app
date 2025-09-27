import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showText;
  final bool compact;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.showText = true,
    this.compact = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final effectiveFontSize = fontSize ?? (compact ? 10.0 : 12.0);
    final iconSize = compact
        ? 12.0
        : (fontSize != null ? fontSize! + 2 : AppDimensions.iconXS);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact
            ? 6
            : (showText ? AppDimensions.paddingS : AppDimensions.paddingXS),
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          compact ? 4 : AppDimensions.radiusS,
        ),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: iconSize),
          if (showText) ...[
            SizedBox(width: compact ? 4 : 4),
            Text(
              compact ? status.toUpperCase() : status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: effectiveFontSize,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'in progress':
      case 'in_progress':
        return Icons.work;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
      case 'canceled':
        return Icons.cancel;
      case 'on hold':
      case 'on_hold':
        return Icons.pause_circle;
      case 'review':
        return Icons.rate_review;
      default:
        return Icons.pending;
    }
  }
}
