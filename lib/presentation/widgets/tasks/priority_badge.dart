import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;
  final bool showText;
  final bool compact;
  final double? fontSize;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showText = true,
    this.compact = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = AppColors.getPriorityColor(priority);
    final priorityIcon = _getPriorityIcon(priority);

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
        color: priorityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          compact ? 4 : AppDimensions.radiusS,
        ),
        border: Border.all(
          color: priorityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priorityIcon, color: priorityColor, size: iconSize),
          if (showText) ...[
            SizedBox(width: compact ? 4 : 4),
            Text(
              compact ? priority.toUpperCase() : priority,
              style: TextStyle(
                color: priorityColor,
                fontWeight: FontWeight.w600,
                fontSize: effectiveFontSize,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Icons.priority_high;
      case 'high':
        return Icons.arrow_upward;
      case 'normal':
      case 'medium':
        return Icons.radio_button_unchecked;
      case 'low':
        return Icons.keyboard_arrow_down;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}
