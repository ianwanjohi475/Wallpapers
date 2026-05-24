import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<String> _history = [];

  static const _historyKey = 'search_history';
  static const _maxHistory = 10;

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
    _loadHistory();
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

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _history = prefs.getStringList(_historyKey) ?? []);
    }
  }

  Future<void> _saveToHistory(String q) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = [
      trimmed,
      ..._history.where((h) => h.toLowerCase() != trimmed.toLowerCase()),
    ].take(_maxHistory).toList();
    await prefs.setStringList(_historyKey, updated);
    if (mounted) setState(() => _history = updated);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    if (mounted) setState(() => _history = []);
  }

  Future<void> _removeHistoryItem(String item) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = _history.where((h) => h != item).toList();
    await prefs.setStringList(_historyKey, updated);
    if (mounted) setState(() => _history = updated);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _setQuery(String s, {bool saveHistory = false}) {
    _ctrl.text = s;
    _ctrl.selection =
        TextSelection.fromPosition(TextPosition(offset: _ctrl.text.length));
    if (saveHistory) _saveToHistory(s);
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.trim().isNotEmpty;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.bgPrimary,
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
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: colors.textPrimary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: colors.borderSubtle,
                              width: 1),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(Icons.search_rounded,
                                color: colors.textSecondary, size: 20),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                autofocus: false,
                                textInputAction: TextInputAction.search,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  color: colors.textPrimary,
                                ),
                                onSubmitted: (v) {
                                  if (v.trim().isNotEmpty) {
                                    _saveToHistory(v.trim());
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'Search teams, stadiums, styles...',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    color: colors.textTertiary,
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
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 14),
                                  child: Icon(Icons.close_rounded,
                                      color: colors.textSecondary, size: 20),
                                ),
                              )
                            else ...[
                              const SizedBox(width: 16),
                              Icon(Icons.mic_none_rounded,
                                  color: colors.textSecondary, size: 20),
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
              // Recent searches — only shown when the user has actually searched.
              if (_history.isNotEmpty) ...[
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
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _clearHistory();
                          },
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
                    (context, i) {
                      final item = _history[i];
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _setQuery(item, saveHistory: false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            children: [
                              Icon(Icons.history_rounded,
                                  color: colors.textTertiary, size: 16),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _removeHistoryItem(item);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Icon(Icons.close_rounded,
                                      color: colors.textTertiary, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _history.length,
                  ),
                ),
              ],
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
                          _setQuery(tag.label, saveHistory: true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.bgCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: colors.borderSubtle, width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(tag.icon,
                                  color: colors.textTertiary, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                tag.label,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: colors.textSecondary,
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
                            children: [
                              Icon(Icons.image_search_rounded,
                                  color: colors.textTertiary, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'No results found',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: colors.textSecondary,
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
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: colors.textSecondary,
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
