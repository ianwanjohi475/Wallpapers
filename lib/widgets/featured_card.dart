import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/wallpaper_model.dart';
import '../widgets/glass_pill.dart';
import '../widgets/motion_image.dart';
import '../widgets/category_chip.dart';
import '../core/utils/formatters.dart';

class FeaturedCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onTap;
  /// Offset the parallax animation phase (0.0–1.0) so adjacent cards
  /// are never in sync.
  final double animationPhase;

  const FeaturedCard({
    super.key,
    required this.wallpaper,
    required this.isLiked,
    required this.onLike,
    required this.onTap,
    this.animationPhase = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Motion image — fills the card and animates continuously.
            MotionImage(
              imageUrl: wallpaper.previewUrl,
              height: 210,
              phase: animationPhase,
            ),
            // Gradient overlay so text stays readable.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: GlassPill(
                icon: CategoryChip.iconFor(wallpaper.category),
                label: wallpaper.category[0].toUpperCase() +
                    wallpaper.category.substring(1),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onLike,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.42),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isLiked ? Colors.red : Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 14,
              child: Text(
                wallpaper.title,
                style: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              bottom: 12,
              right: 14,
              child: Row(
                children: [
                  Icon(
                    Icons.download_rounded,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 12,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    formatCount(wallpaper.downloadCount),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
