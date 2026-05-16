import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';

class CategoryDropdown extends StatelessWidget {
  final String value;
  final List<String> categories;
  final ValueChanged<String?> onChanged;
  final String? label;

  const CategoryDropdown({
    super.key,
    required this.value,
    required this.categories,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            color: AppColors.surface,
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingS,
                vertical: AppDimensions.paddingS,
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: AppDimensions.iconS,
                      color: _getCategoryColor(category),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Text(
                      category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'logistics':
        return Icons.local_shipping;
      case 'general':
        return Icons.info_outline;
      case 'maintenance':
        return Icons.build;
      case 'tools':
        return Icons.hardware;
      case 'transportation':
        return Icons.directions_car;
      case 'safety':
        return Icons.security;
      case 'equipment':
        return Icons.precision_manufacturing;
      case 'communication':
        return Icons.chat;
      case 'documentation':
        return Icons.description;
      case 'it support':
        return Icons.computer;
      case 'facilities':
        return Icons.domain;
      case 'hr':
      case 'human resources':
        return Icons.people;
      case 'quality':
        return Icons.verified;
      case 'security':
        return Icons.shield;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'logistics':
        return const Color(0xFF1b75bc);
      case 'maintenance':
        return Colors.orange;
      case 'tools':
        return Colors.purple;
      case 'transportation':
        return Colors.indigo;
      case 'safety':
        return Colors.red;
      case 'equipment':
        return Colors.brown;
      case 'communication':
        return Colors.cyan;
      case 'documentation':
        return Colors.amber;
      case 'quality':
        return Colors.green;
      case 'it support':
        return Colors.blue;
      case 'facilities':
        return Colors.teal;
      case 'hr':
      case 'human resources':
        return Colors.teal;
      case 'general':
        return AppColors.primary;
      case 'security':
        return Colors.deepOrange;
      case 'other':
        return Colors.grey;
      default:
        return const Color(0xFF253b74);
    }
  }
}
