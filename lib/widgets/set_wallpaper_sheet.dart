import 'package:flutter/material.dart';
import '../core/app_colors.dart';

void showSetWallpaperSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.bgCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _SetWallpaperSheet(),
  );
}

class _SetWallpaperSheet extends StatelessWidget {
  const _SetWallpaperSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8, left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SET AS WALLPAPER',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: AppColors.accentGold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            _SheetTile(
              icon: Icons.home_rounded,
              label: 'Home Screen',
              onTap: () {
                Navigator.pop(context);
                _showConfirmation(context, 'Set as Home Screen');
              },
            ),
            Divider(
              height: 1,
              color: AppColors.borderSubtle,
              indent: 56,
            ),
            _SheetTile(
              icon: Icons.lock_rounded,
              label: 'Lock Screen',
              onTap: () {
                Navigator.pop(context);
                _showConfirmation(context, 'Set as Lock Screen');
              },
            ),
            Divider(
              height: 1,
              color: AppColors.borderSubtle,
              indent: 56,
            ),
            _SheetTile(
              icon: Icons.phone_android_rounded,
              label: 'Home & Lock Screen',
              onTap: () {
                Navigator.pop(context);
                _showConfirmation(context, 'Set on Both Screens');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showConfirmation(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label wallpaper applied',
          style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
        ),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.bgGlass,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
