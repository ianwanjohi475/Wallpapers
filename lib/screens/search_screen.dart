import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../models/wallpaper_model.dart';
import '../services/wallpaper_service.dart';
import '../widgets/ad_banner.dart';
import '../widgets/responsive_masonry.dart';
import '../widgets/shimmer_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  Timer? _debounce;
  Future<List<WallpaperModel>>? _results;

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

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final txt = _ctrl.text;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        setState(() {
          _query = txt;
          _results = txt.trim().isEmpty
              ? null
              : WallpaperService.instance.search(txt);
        });
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _setQuery(String s) {
    _ctrl.text = s;
    _ctrl.selection =
        TextSelection.fromPosition(TextPosition(offset: _ctrl.text.length));
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.trim().isNotEmpty;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;

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
                                textInputAction: TextInputAction.search,
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
                                  setState(() {
                                    _query = '';
                                    _results = null;
                                  });
                                },
                                child: const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 14),
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
                      _setQuery(_recentSearches[i]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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
                          _setQuery(tag.label);
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
                child: FutureBuilder<List<WallpaperModel>>(
                  future: _results,
                  builder: (context, snap) {
                    final loading =
                        snap.connectionState != ConnectionState.done;
                    final results = snap.data ?? const <WallpaperModel>[];

                    if (loading) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, bottomPadding),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: ShimmerCard(height: 220)),
                            SizedBox(width: 8),
                            Expanded(child: ShimmerCard(height: 280)),
                          ],
                        ),
                      );
                    }

                    if (results.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 60),
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
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
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
                          const AdBanner(margin: EdgeInsets.only(bottom: 16)),
                          ResponsiveMasonry(items: results),
                        ],
                      ),
                    );
                  },
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
