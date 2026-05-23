import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../models/wallpaper_model.dart';
import '../widgets/shimmer_card.dart';
import '../core/utils/formatters.dart';

class NewTodayCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  final VoidCallback onTap;

  const NewTodayCard({
    super.key,
    required this.wallpaper,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: wallpaper.gridUrl,
              width: 140,
              height: 200,
              fit: BoxFit.cover,
              memCacheWidth: 400,
              placeholder: (_, __) => const ShimmerCard(height: 200),
              errorWidget: (_, __, ___) => Container(
                height: 200,
                color: AppColors.bgCard,
                child: const Icon(
                  Icons.broken_image_rounded,
                  color: AppColors.textTertiary,
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
                      Colors.black.withValues(alpha: 0.70),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            if (wallpaper.isPremium)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.lockGold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lockGold, width: 0.5),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: AppColors.lockGold,
                    size: 11,
                  ),
                ),
              ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallpaper.title,
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.download_rounded,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        formatCount(wallpaper.downloadCount),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
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
