import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../data/mock_data.dart';
import '../models/wallpaper_model.dart';
import '../widgets/wallpaper_grid_card.dart';
import 'filter_sheet.dart';

class BrowseScreen extends StatefulWidget {
  final String? initialCategory;
  const BrowseScreen({super.key, this.initialCategory});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late String _selectedCategory;
  final _categories = [
    'All', 'Teams', 'Stadiums', 'Trophies', 'Abstract',
    'Legends', 'Neon', 'Dark', '4K', 'New', 'Flags',
  ];

  static const _leftHeights = [260.0, 180.0, 220.0, 240.0, 200.0, 260.0];
  static const _rightHeights = [190.0, 250.0, 170.0, 270.0, 220.0, 190.0];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;
    final items = MockData.getByCategory(_selectedCategory);

    final leftItems = <WallpaperModel>[];
    final rightItems = <WallpaperModel>[];
    for (int i = 0; i < items.length; i++) {
      if (i.isEven) leftItems.add(items[i]);
      else rightItems.add(items[i]);
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BROWSE GALLERY',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${items.length} Wallpapers',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => const FilterSheet(),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.borderSubtle, width: 0.5),
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: AppColors.accentGold, size: 20),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final active = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedCategory = cat);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.accentGold
                              : AppColors.bgGlass,
                          borderRadius: BorderRadius.circular(20),
                          border: active
                              ? null
                              : Border.all(
                                  color: AppColors.borderSubtle,
                                  width: 0.5),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: active
                                ? AppColors.bgPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (items.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.image_search_rounded,
                        color: AppColors.textTertiary, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'No wallpapers in this category',
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
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
              sliver: SliverToBoxAdapter(
                child: Row(
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}
