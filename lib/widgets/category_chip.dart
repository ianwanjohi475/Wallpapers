import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accentGold
              : colors.isDark
                  ? AppColors.bgGlass
                  : colors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: colors.borderSubtle, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconFor(label),
              size: 13,
              color: isActive ? AppColors.bgPrimary : colors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: isActive ? AppColors.bgPrimary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData iconFor(String cat) {
    switch (cat.toLowerCase()) {
      case 'all':
        return Icons.grid_view_rounded;
      case 'teams':
        return Icons.sports_soccer_rounded;
      case 'stadiums':
        return Icons.stadium_rounded;
      case 'trophies':
        return Icons.emoji_events_rounded;
      case 'abstract':
        return Icons.auto_fix_high_rounded;
      case 'legends':
        return Icons.star_rounded;
      case 'neon':
        return Icons.bolt_rounded;
      case 'dark':
        return Icons.dark_mode_rounded;
      case '4k':
        return Icons.hd_rounded;
      case 'new':
        return Icons.fiber_new_rounded;
      case 'flags':
        return Icons.flag_rounded;
      default:
        return Icons.image_rounded;
    }
  }
}
