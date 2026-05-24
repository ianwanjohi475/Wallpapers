import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../painters/orb_painter.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/auth_required_sheet.dart';
import '../widgets/responsive_masonry.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbCtrl;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSync());
  }

  Future<void> _maybeSync() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isSignedIn || _syncing) return;
    setState(() => _syncing = true);
    try {
      await context.read<FavoritesProvider>().syncWithServer();
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final size = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;
    final favProv = context.watch<FavoritesProvider>();
    final auth = context.watch<AuthProvider>();
    final favs = favProv.getLikedWallpapers();
    final isGuest = !auth.isSignedIn;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      extendBody: true,
      body: AnimatedBuilder(
        animation: _orbCtrl,
        builder: (context, _) {
          return Stack(
            children: [
              Opacity(
                opacity: colors.isDark ? 0.4 : 0.15,
                child: CustomPaint(
                  size: size,
                  painter: OrbPainter(
                    t: _orbCtrl.value,
                    orbs: purpleOrbs,
                    bgColor: colors.bgPrimary,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      color: colors.bgPrimary.withValues(alpha: 0.8),
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
                                '${favProv.likedCount} wallpaper${favProv.likedCount == 1 ? "" : "s"} saved',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: colors.textSecondary,
                                ),
                              ),
                              if (auth.isSignedIn) ...[
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: colors.textSecondary,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (auth.isSignedIn)
                Positioned(
                  top: safeTop + 14,
                  right: 24,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _maybeSync();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: colors.borderSubtle, width: 0.5),
                      ),
                      child: _syncing
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                color: AppColors.accentGold,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.sync_rounded,
                              color: colors.textPrimary, size: 22),
                    ),
                  ),
                ),
              Positioned.fill(
                child: favs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border_rounded,
                                  color: colors.textTertiary, size: 64),
                              const SizedBox(height: 16),
                              Text(
                                'No favorites yet',
                                style: TextStyle(
                                  fontFamily: 'Rajdhani',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the heart on any wallpaper\nto save it here',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: colors.textSecondary,
                                ),
                              ),
                              if (isGuest) ...[
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () => showAuthRequiredSheet(
                                    context,
                                    title: 'Sync across devices',
                                    message:
                                        'Sign up to keep your favourites safe and access them on any phone.',
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.goldGradient,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Create account',
                                      style: TextStyle(
                                        fontFamily: 'Rajdhani',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppColors.bgPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: safeTop + 100,
                          bottom: bottomPadding + 24,
                          left: 16,
                          right: 16,
                        ),
                        child: ResponsiveMasonry(
                          items: favs,
                          alwaysLiked: true,
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
