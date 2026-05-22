import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../core/app_colors.dart';
import '../data/mock_data.dart';
import '../models/wallpaper_model.dart';
import '../widgets/glass_pill.dart';
import '../widgets/wallpaper_grid_card.dart';
import '../widgets/shimmer_card.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _carouselCtrl = PageController(viewportFraction: 0.88);
  int _carouselPage = 0;
  Timer? _autoScrollTimer;
  final _scrollCtrl = ScrollController();
  bool _showFab = true;
  double _lastScroll = 0;

  String _selectedCategory = 'All';
  final _categories = [
    'All', 'Teams', 'Stadiums', 'Trophies', 'Abstract',
    'Legends', 'Neon', 'Dark', '4K', 'New'
  ];

  @override
  void initState() {
    super.initState();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (!mounted) return;
      final next = (_carouselPage + 1) % MockData.getFeatured().length;
      _carouselCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final current = _scrollCtrl.offset;
    if (current > _lastScroll + 10 && _showFab) {
      setState(() => _showFab = false);
    } else if (current < _lastScroll - 10 && !_showFab) {
      setState(() => _showFab = true);
    }
    _lastScroll = current;
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _carouselCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featured = MockData.getFeatured();
    final newToday = MockData.getNewToday();
    final mostDl = MockData.getMostDownloaded();
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accentGold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sports_soccer_rounded,
                          color: AppColors.bgPrimary, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'WC WALLPAPERS',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const SearchScreen(),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search_rounded,
                        color: Colors.white, size: 22),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () => HapticFeedback.lightImpact(),
                        icon: const Icon(Icons.notifications_rounded,
                            color: Colors.white, size: 22),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.bgPrimary, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded,
                              color: AppColors.accentGold, size: 14),
                          const SizedBox(width: 4),
                          const Text(
                            'FEATURED',
                            style: TextStyle(
                              fontFamily: 'Rajdhani',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.accentGold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.accentGreen.withValues(alpha: 0.4),
                                  width: 0.5),
                            ),
                            child: const Text(
                              'NEW PACK',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                                color: AppColors.accentGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 210,
                      child: PageView.builder(
                        controller: _carouselCtrl,
                        itemCount: featured.length,
                        onPageChanged: (i) =>
                            setState(() => _carouselPage = i),
                        itemBuilder: (context, i) {
                          final w = featured[i];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6),
                            child: _FeaturedCard(wallpaper: w),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: SmoothPageIndicator(
                        controller: _carouselCtrl,
                        count: featured.length,
                        effect: const ExpandingDotsEffect(
                          dotWidth: 5,
                          dotHeight: 5,
                          activeDotColor: AppColors.accentGold,
                          dotColor: Color(0x33FFFFFF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Text(
                        'Browse by Category',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                  horizontal: 14, vertical: 9),
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
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(
                        children: [
                          const Text(
                            'New Today',
                            style: TextStyle(
                              fontFamily: 'Rajdhani',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => HapticFeedback.lightImpact(),
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: newToday.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final w = newToday[i];
                          return _NewTodayCard(wallpaper: w);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded,
                              color: AppColors.accentGold, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'Most Downloaded',
                            style: TextStyle(
                              fontFamily: 'Rajdhani',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => HapticFeedback.lightImpact(),
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _MasonryGrid(wallpapers: mostDl),
                    SizedBox(height: bottomPadding + 60),
                  ],
                ),
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            bottom: _showFab ? 80 : -80,
            right: 24,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                final w = MockData.getRandom();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => DetailScreen(wallpaper: w),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                    transitionDuration: const Duration(milliseconds: 350),
                  ),
                );
              },
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGold.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shuffle_rounded,
                        color: AppColors.bgPrimary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'RANDOM',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.bgPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  final WallpaperModel wallpaper;
  const _FeaturedCard({required this.wallpaper});

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  bool _liked = false;

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'stadiums': return Icons.stadium_rounded;
      case 'trophies': return Icons.emoji_events_rounded;
      case 'teams': return Icons.sports_soccer_rounded;
      case 'legends': return Icons.star_rounded;
      case 'abstract': return Icons.auto_fix_high_rounded;
      case 'neon': return Icons.bolt_rounded;
      default: return Icons.grid_view_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.wallpaper;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => DetailScreen(wallpaper: w),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: Hero(
        tag: 'wall_${w.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: w.imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (_, __) => const ShimmerCard(height: 210),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.bgCard,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded,
                        color: AppColors.textTertiary),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: GlassPill(
                  icon: _catIcon(w.category),
                  label: w.category.toUpperCase(),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _liked = !_liked);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _liked ? Colors.red : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 14,
                child: Text(
                  w.title,
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 14,
                child: Row(
                  children: [
                    Icon(Icons.download_rounded,
                        color: Colors.white.withValues(alpha: 0.6), size: 12),
                    const SizedBox(width: 3),
                    Text(
                      MockData.formatCount(w.downloadCount),
                      style: TextStyle(
                        fontFamily: 'Inter',
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
      ),
    );
  }
}

class _NewTodayCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  const _NewTodayCard({required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => DetailScreen(wallpaper: wallpaper),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: wallpaper.imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (_, __) =>
                    const ShimmerCard(height: 160),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.bgCard,
                  child: const Icon(Icons.broken_image_rounded,
                      color: AppColors.textTertiary),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 4,
                child: Text(
                  wallpaper.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasonryGrid extends StatelessWidget {
  final List<WallpaperModel> wallpapers;

  const _MasonryGrid({required this.wallpapers});

  static const _leftHeights = [240.0, 160.0, 200.0];
  static const _rightHeights = [180.0, 260.0, 160.0];

  @override
  Widget build(BuildContext context) {
    final left = wallpapers.take(3).toList();
    final right = wallpapers.skip(3).take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: List.generate(left.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WallpaperGridCard(
                  wallpaper: left[i],
                  height: _leftHeights[i],
                ),
              )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 60),
                ...List.generate(right.length, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WallpaperGridCard(
                    wallpaper: right[i],
                    height: _rightHeights[i],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
