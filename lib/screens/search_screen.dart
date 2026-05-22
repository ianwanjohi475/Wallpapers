import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../data/mock_data.dart';
import '../models/wallpaper_model.dart';
import '../widgets/wallpaper_grid_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  static const _recentSearches = [
    'Real Madrid 4K',
    'World Cup Trophy Neon',
    'Lusail Stadium Aerial',
  ];

  static const _popularTags = [
    _Tag(icon: Icons.local_fire_department_rounded, label: 'Brazil'),
    _Tag(icon: Icons.star_rounded, label: 'Legends'),
    _Tag(icon: Icons.auto_awesome_rounded, label: 'Abstract'),
    _Tag(icon: Icons.dark_mode_rounded, label: 'Amoled'),
    _Tag(icon: Icons.sports_soccer_rounded, label: 'Stadiums'),
  ];

  static const _leftHeights = [240.0, 180.0, 220.0, 200.0, 260.0, 190.0];
  static const _rightHeights = [160.0, 260.0, 200.0, 270.0, 170.0, 230.0];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      setState(() => _query = _ctrl.text);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = MockData.searchAll(_query);
    final hasQuery = _query.trim().isNotEmpty;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;

    final leftItems = <WallpaperModel>[];
    final rightItems = <WallpaperModel>[];
    for (int i = 0; i < results.length; i++) {
      if (i.isEven) leftItems.add(results[i]);
      else rightItems.add(results[i]);
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.maybePop(context);
                      },
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                              width: 1),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            const Icon(Icons.search_rounded,
                                color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                autofocus: false,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Search teams, stadiums, styles...',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    color: AppColors.textTertiary,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (hasQuery)
                              GestureDetector(
                                onTap: () {
                                  _ctrl.clear();
                                  setState(() => _query = '');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                  child: Icon(Icons.close_rounded,
                                      color: AppColors.textSecondary, size: 20),
                                ),
                              )
                            else ...[
                              const SizedBox(width: 16),
                              const Icon(Icons.mic_none_rounded,
                                  color: AppColors.textSecondary, size: 20),
                              const SizedBox(width: 14),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!hasQuery) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      const Text(
                        'RECENT SEARCHES',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xB3FFD700),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => HapticFeedback.lightImpact(),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _ctrl.text = _recentSearches[i];
                      _ctrl.selection = TextSelection.fromPosition(
                        TextPosition(offset: _ctrl.text.length),
                      );
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.history_rounded,
                              color: AppColors.textTertiary, size: 16),
                          const SizedBox(width: 12),
                          Text(
                            _recentSearches[i],
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.north_west_rounded,
                              color: AppColors.textTertiary, size: 14),
                        ],
                      ),
                    ),
                  ),
                  childCount: _recentSearches.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: const Text(
                    'POPULAR TAGS',
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: Color(0xB3FFD700),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popularTags.map((tag) {
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _ctrl.text = tag.label;
                          _ctrl.selection = TextSelection.fromPosition(
                            TextPosition(offset: _ctrl.text.length),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.borderSubtle, width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(tag.icon,
                                  color: AppColors.textTertiary, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                tag.label,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: bottomPadding),
              ),
            ] else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      const Text(
                        'MATCHING RESULTS',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xB3FFD700),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${results.length} Wallpapers',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (results.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.image_search_rounded,
                            color: AppColors.textTertiary, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'No results found',
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
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: List.generate(
                              leftItems.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: WallpaperGridCard(
                                  wallpaper: leftItems[i],
                                  height: _leftHeights[i % _leftHeights.length],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: List.generate(
                              rightItems.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: WallpaperGridCard(
                                  wallpaper: rightItems[i],
                                  height: _rightHeights[i % _rightHeights.length],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tag {
  final IconData icon;
  final String label;
  const _Tag({required this.icon, required this.label});
}
