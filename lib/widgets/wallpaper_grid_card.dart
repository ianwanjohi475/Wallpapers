import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/wallpaper_model.dart';
import '../providers/favorites_provider.dart';
import '../screens/detail_screen.dart';
import 'shimmer_card.dart';

class WallpaperGridCard extends StatefulWidget {
  final WallpaperModel wallpaper;
  final double height;
  final bool alwaysLiked;

  const WallpaperGridCard({
    super.key,
    required this.wallpaper,
    required this.height,
    this.alwaysLiked = false,
  });

  @override
  State<WallpaperGridCard> createState() => _WallpaperGridCardState();
}

class _WallpaperGridCardState extends State<WallpaperGridCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _toggleLike(BuildContext context) {
    HapticFeedback.lightImpact();
    context.read<FavoritesProvider>().toggleLike(widget.wallpaper.id);
    _heartCtrl.forward(from: 0);
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.wallpaper;
    final isLiked = widget.alwaysLiked ||
        context.watch<FavoritesProvider>().isLiked(w.id);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => DetailScreen(wallpaper: w),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: Hero(
        tag: 'wall_${w.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: w.gridUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 600,
                  fadeInDuration: const Duration(milliseconds: 250),
                  placeholder: (_, __) => ShimmerCard(height: widget.height),
                  errorWidget: (context, __, ___) {
                    final colors = AppThemeColors.of(context);
                    return Container(
                      color: colors.bgCard,
                      child: Center(
                        child: Icon(Icons.broken_image_rounded,
                            color: colors.textTertiary, size: 32),
                      ),
                    );
                  },
                ),
                if (w.isPremium)
                  Positioned.fill(
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 0.8, sigmaY: 0.8),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                if (w.isPremium)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.lockGold.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.lockGold, width: 0.8),
                      ),
                      child: const Icon(Icons.lock_rounded,
                          color: AppColors.lockGold, size: 13),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Row(
                    children: [
                      const Icon(Icons.download_rounded,
                          color: AppColors.textSecondary, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        _formatCount(widget.wallpaper.downloadCount),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _toggleLike(context),
                    child: ScaleTransition(
                      scale: _heartScale,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.42),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 0.6,
                          ),
                        ),
                        child: Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isLiked ? Colors.red : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
