import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../models/wallpaper_model.dart';
import '../widgets/wallpaper_grid_card.dart';

class WallpaperListScreen extends StatelessWidget {
  final String title;
  final List<WallpaperModel> wallpapers;

  const WallpaperListScreen({
    super.key,
    required this.title,
    required this.wallpapers,
  });

  static const _leftHeights = [240.0, 180.0, 220.0, 200.0, 260.0, 190.0];
  static const _rightHeights = [180.0, 250.0, 200.0, 270.0, 170.0, 230.0];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final leftItems = <WallpaperModel>[];
    final rightItems = <WallpaperModel>[];
    for (int i = 0; i < wallpapers.length; i++) {
      if (i.isEven) leftItems.add(wallpapers[i]);
      else rightItems.add(wallpapers[i]);
    }

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
            padding: EdgeInsets.fromLTRB(16, 16, 16, 80 + bottomPadding),
            sliver: SliverToBoxAdapter(
              child: wallpapers.isEmpty
                  ? SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
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
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: List.generate(
                              leftItems.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: WallpaperGridCard(
                                  wallpaper: leftItems[i],
                                  height: _leftHeights[i % _leftHeights.length],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              ...List.generate(
                                rightItems.length,
                                (i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: WallpaperGridCard(
                                    wallpaper: rightItems[i],
                                    height: _rightHeights[i % _rightHeights.length],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
