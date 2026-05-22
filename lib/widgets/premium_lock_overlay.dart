import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class PremiumLockOverlay extends StatelessWidget {
  final VoidCallback onUnlock;

  const PremiumLockOverlay({
    super.key,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.lockGold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lockGold, width: 1),
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: AppColors.lockGold,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Premium Wallpaper',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Unlock to download',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onUnlock,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accentGold, AppColors.lockGold],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Go Premium',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
