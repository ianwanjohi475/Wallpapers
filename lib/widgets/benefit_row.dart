import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class BenefitRow extends StatelessWidget {
  final String label;

  const BenefitRow({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentGold, width: 0.8),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.accentGold,
              size: 14,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
