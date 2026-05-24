import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/wallpaper_model.dart';
import '../services/wallpaper_service.dart';
import '../widgets/ad_banner.dart';
import '../widgets/responsive_masonry.dart';
import '../widgets/shimmer_card.dart';
import 'filter_sheet.dart';

class BrowseScreen extends StatefulWidget {
  final String? initialCategory;
  const BrowseScreen({super.key, this.initialCategory});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late String _selectedCategory;
  late Future<List<WallpaperModel>> _items;
  final _categories = [
    'All', 'Teams', 'Stadiums', 'Trophies', 'Abstract',
    'Legends', 'Neon', 'Dark', 'Flags',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _items = _load();
  }

  Future<List<WallpaperModel>> _load() {
    return _selectedCategory.toLowerCase() == 'all'
        ? WallpaperService.instance.getAll()
        : WallpaperService.instance.getByCategory(_selectedCategory);
  }

  void _pick(String cat) {
    if (cat == _selectedCategory) return;
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategory = cat;
      _items = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;
    final pad = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      extendBody: true,
      body: FutureBuilder<List<WallpaperModel>>(
        future: _items,
        builder: (context, snap) {
          final items = snap.data ?? const <WallpaperModel>[];
          final loading = snap.connectionState != ConnectionState.done;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: colors.bgPrimary,
                surfaceTintColor: Colors.transparent,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BROWSE GALLERY',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      loading ? 'Loading...' : '${items.length} Wallpapers',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: colors.textSecondary,
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
                        color: colors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: colors.borderSubtle, width: 0.5),
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
                          onTap: () => _pick(cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.accentGold
                                  : colors.bgCard,
                              borderRadius: BorderRadius.circular(20),
                              border: active
                                  ? null
                                  : Border.all(
                                      color: colors.borderSubtle,
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
                                    : colors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (loading)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, bottomPadding),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        for (var i = 0; i < 3; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                    child: ShimmerCard(height: 200.0 + i * 20)),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: ShimmerCard(height: 240.0 - i * 20)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              else if (items.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_search_rounded,
                            color: colors.textTertiary, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No wallpapers in this category',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: colors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, bottomPadding),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const AdBanner(margin: EdgeInsets.only(bottom: 16)),
                        ResponsiveMasonry(items: items),
                      ],
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}
