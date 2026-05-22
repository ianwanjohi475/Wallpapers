import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../models/wallpaper_model.dart';
import '../widgets/glass_pill.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/category_chip.dart';
import '../core/utils/formatters.dart';

class FeaturedCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const FeaturedCard({
    super.key,
    required this.wallpaper,
    required this.isLiked,
    required this.onLike,
    required this.onTap,
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
            CachedNetworkImage(
              imageUrl: wallpaper.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => ShimmerCard(height: 210),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.bgCard,
                child: const Icon(
                  Icons.broken_image_rounded,
                  color: AppColors.textTertiary,
                  size: 40,
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
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
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
