import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../data/mock_data.dart';
import '../painters/orb_painter.dart';
import '../widgets/wallpaper_grid_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbCtrl;

  static const _leftHeights = [240.0, 180.0, 260.0];
  static const _rightHeights = [160.0, 220.0, 200.0];

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
    final favs = MockData.getFavorites();
    final left = favs.take(3).toList();
    final right = favs.skip(3).take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
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
                              const Text(
                                '47 wallpapers saved',
                                style: TextStyle(
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
              // Back button
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
              // Grid content
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: safeTop + 100,
                    bottom: bottomPadding + 80,
                    left: 16,
                    right: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: List.generate(
                            left.length,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: WallpaperGridCard(
                                wallpaper: left[i],
                                height: _leftHeights[i],
                                alwaysLiked: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: List.generate(
                            right.length,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: WallpaperGridCard(
                                wallpaper: right[i],
                                height: _rightHeights[i],
                                alwaysLiked: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
