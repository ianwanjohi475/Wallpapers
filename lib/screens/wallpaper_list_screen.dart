import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/wallpaper_model.dart';
import '../widgets/responsive_masonry.dart';

class WallpaperListScreen extends StatelessWidget {
  final String title;
  final List<WallpaperModel> wallpapers;

  const WallpaperListScreen({
    super.key,
    required this.title,
    required this.wallpapers,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final pad = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bgPrimary,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${wallpapers.length} wallpapers',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(pad, 16, pad, 80 + bottomPadding),
            sliver: SliverToBoxAdapter(
              child: wallpapers.isEmpty
                  ? const SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_search_rounded,
                                color: AppColors.textTertiary, size: 48),
                            SizedBox(height: 12),
                            Text(
                              'No wallpapers found',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ResponsiveMasonry(items: wallpapers),
            ),
          ),
        ],
      ),
    );
  }
}
