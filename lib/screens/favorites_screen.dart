import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../painters/orb_painter.dart';
import '../providers/favorites_provider.dart';
import '../widgets/responsive_masonry.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbCtrl;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;
    final favProv = context.watch<FavoritesProvider>();
    final favs = favProv.getLikedWallpapers();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      body: AnimatedBuilder(
        animation: _orbCtrl,
        builder: (context, _) {
          return Stack(
            children: [
              Opacity(
                opacity: 0.4,
                child: CustomPaint(
                  size: size,
                  painter: OrbPainter(
                    t: _orbCtrl.value,
                    orbs: purpleOrbs,
                    bgColor: AppColors.bgPrimary,
                  ),
                ),
              ),
              // Glassmorphism header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      color: AppColors.bgPrimary.withValues(alpha: 0.8),
                      padding: EdgeInsets.fromLTRB(24, safeTop + 16, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'YOUR FAVORITES',
                            style: TextStyle(
                              fontFamily: 'Rajdhani',
                              fontWeight: FontWeight.w700,
                              fontSize: 26,
                              color: AppColors.accentGold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${favs.length} wallpapers saved',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8),
                                decoration: const BoxDecoration(
                                  color: AppColors.textSecondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Text(
                                'Synced to cloud',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.accentGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Sync button
              Positioned(
                top: safeTop + 14,
                right: 24,
                child: GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sync_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
              // Grid content or empty state
              Positioned.fill(
                child: favs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.favorite_border_rounded,
                                color: AppColors.textTertiary, size: 64),
                            SizedBox(height: 16),
                            Text(
                              'No favorites yet',
                              style: TextStyle(
                                fontFamily: 'Rajdhani',
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap the heart on any wallpaper\nto save it here',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: safeTop + 100,
                          bottom: bottomPadding + 80,
                          left: 16,
                          right: 16,
                        ),
                        child: ResponsiveMasonry(
                          items: favs,
                          alwaysLiked: true,
                        ),
                      ),
              ),
              // FAB
              Positioned(
                bottom: bottomPadding - 20,
                right: 32,
                child: GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGold.withValues(alpha: 0.27),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync_rounded,
                            color: AppColors.bgPrimary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'SYNC',
                          style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.bgPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
