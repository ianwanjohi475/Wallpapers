import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SearchHistoryItem extends StatelessWidget {
  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const SearchHistoryItem({
    super.key,
    required this.term,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.history_rounded,
              color: AppColors.textTertiary,
              size: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                term,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textTertiary,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
