import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import 'legal_screen.dart';
import 'rate_app_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _push(BuildContext context, Widget page) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final maxW = Responsive.contentMaxWidth(context);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, safeTop + 16, 20, 16),
            decoration: const BoxDecoration(
              color: AppColors.bgPrimary,
              border: Border(
                bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Text(
                  'ABOUT',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                  children: [
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.accentGold.withValues(alpha: 0.3),
                              blurRadius: 28,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.sports_soccer_rounded,
                            color: AppColors.bgPrimary, size: 48),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'WC Wallpapers 2026',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Version 1.0.0  (build 100)',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'The ultimate wallpaper app for football fans. '
                      'Premium 4K wallpapers celebrating the biggest '
                      'tournament on Earth — stadiums, trophies, legends '
                      'and more, refreshed every single day.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _AboutTile(
                      icon: Icons.star_rounded,
                      label: 'Rate This App',
                      onTap: () => _push(context, const RateAppScreen()),
                    ),
                    _AboutTile(
                      icon: Icons.privacy_tip_rounded,
                      label: 'Privacy Policy',
                      onTap: () => _push(context, LegalScreen.privacy()),
                    ),
                    _AboutTile(
                      icon: Icons.description_rounded,
                      label: 'Terms of Service',
                      onTap: () => _push(context, LegalScreen.terms()),
                    ),
                    _AboutTile(
                      icon: Icons.code_rounded,
                      label: 'Open Source Licences',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        showLicensePage(
                          context: context,
                          applicationName: 'WC Wallpapers 2026',
                          applicationVersion: '1.0.0',
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_rounded,
                            color: Colors.red.withValues(alpha: 0.7),
                            size: 12),
                        const SizedBox(width: 5),
                        const Text(
                          'Made for football fans worldwide',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        '© 2026 WC Wallpapers. All rights reserved.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AboutTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.accentGold, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textTertiary, size: 13),
          ],
        ),
      ),
    );
  }
}
