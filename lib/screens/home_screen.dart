import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../core/app_colors.dart';
import '../models/wallpaper_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/notifications_provider.dart';
import '../services/wallpaper_service.dart';
import '../widgets/ad_banner.dart';
import '../widgets/wc_wallpapers_logo.dart';
import '../widgets/glass_pill.dart';
import '../widgets/motion_image.dart';
import '../widgets/responsive_masonry.dart';
import '../widgets/shimmer_card.dart';
import 'browse_screen.dart';
import 'categories_screen.dart';
import 'detail_screen.dart';
import 'notifications_screen.dart';
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
    'Legends', 'Neon', 'Dark', 'Flags',
  ];

  late Future<_HomeData> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
    _scrollCtrl.addListener(_onScroll);
  }

  Future<_HomeData> _load() async {
    final results = await Future.wait([
      WallpaperService.instance.getFeatured(),
      WallpaperService.instance.getNewToday(),
      WallpaperService.instance.getMostDownloaded(),
    ]);
    final featured = results[0];
    final all = [...featured, ...results[1], ...results[2]];
    // Hydrate favourites cache so the Favourites tab can show titles for guests.
    if (mounted) context.read<FavoritesProvider>().hydrateFromList(all);
    return _HomeData(
      featured: featured,
      newToday: results[1],
      mostDownloaded: results[2],
    );
  }

  void _startAutoScroll(int total) {
    if (total <= 1 || _autoScrollTimer != null) return;
    _autoScrollTimer =
        Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (!mounted) return;
      final next = (_carouselPage + 1) % total;
      _carouselCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
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
    final colors = AppThemeColors.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      extendBody: true,
      body: FutureBuilder<_HomeData>(
        future: _data,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const _HomeSkeleton();
          }
          if (snap.hasError) {
            return _HomeError(
              onRetry: () => setState(() => _data = _load()),
              message: 'Could not load wallpapers',
            );
          }
          final data = snap.data!;
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => _startAutoScroll(data.featured.length));

          return Stack(
            children: [
              RefreshIndicator(
                color: AppColors.accentGold,
                backgroundColor: AppColors.bgCard,
                onRefresh: () async {
                  WallpaperService.instance.clearCache();
                  setState(() => _data = _load());
                  await _data;
                },
                child: CustomScrollView(
                  controller: _scrollCtrl,
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      title: Row(
                        children: [
                          const WCWallpapersLogo(size: 36),
                          const SizedBox(width: 10),
                          Text(
                            'WALLPAPERS',
                            style: TextStyle(
                              fontFamily: 'Rajdhani',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: colors.isDark
                                  ? AppColors.accentGold
                                  : colors.textPrimary,
                              letterSpacing: 1.5,
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
                                pageBuilder: (_, __, ___) =>
                                    const SearchScreen(),
                                transitionsBuilder: (_, anim, __, child) =>
                                    FadeTransition(opacity: anim, child: child),
                                transitionDuration:
                                    const Duration(milliseconds: 350),
                              ),
                            );
                          },
                          icon: Icon(Icons.search_rounded,
                              color: colors.textPrimary, size: 22),
                        ),
                        Consumer<NotificationsProvider>(
                          builder: (context, notif, _) {
                            return Stack(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            const NotificationsScreen(),
                                        transitionsBuilder:
                                            (_, anim, __, child) =>
                                                FadeTransition(
                                                    opacity: anim,
                                                    child: child),
                                        transitionDuration: const Duration(
                                            milliseconds: 300),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.notifications_rounded,
                                      color: colors.textPrimary, size: 22),
                                ),
                                if (notif.unreadCount > 0)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppColors.accentOrange,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: colors.bgPrimary,
                                            width: 1.5),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
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
                                Icon(Icons.local_fire_department_rounded,
                                    color: colors.isDark
                                        ? AppColors.accentGold
                                        : colors.accentMuted,
                                    size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'FEATURED',
                                  style: TextStyle(
                                    fontFamily: 'Rajdhani',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: colors.isDark
                                        ? AppColors.accentGold
                                        : colors.accentMuted,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 210,
                            child: PageView.builder(
                              controller: _carouselCtrl,
                              itemCount: data.featured.length,
                              onPageChanged: (i) =>
                                  setState(() => _carouselPage = i),
                              itemBuilder: (context, i) {
                                final w = data.featured[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6),
                                  child: _FeaturedCard(wallpaper: w),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: SmoothPageIndicator(
                              controller: _carouselCtrl,
                              count: data.featured.length,
                              effect: ExpandingDotsEffect(
                                dotWidth: 5,
                                dotHeight: 5,
                                activeDotColor: AppColors.accentGold,
                                dotColor: colors.isDark
                                    ? const Color(0x33FFFFFF)
                                    : const Color(0x33000000),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            child: Row(
                              children: [
                                Text(
                                  'Browse by Category',
                                  style: TextStyle(
                                    fontFamily: 'Rajdhani',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            const CategoriesScreen(),
                                        transitionsBuilder:
                                            (_, anim, __, child) =>
                                                FadeTransition(
                                                    opacity: anim,
                                                    child: child),
                                        transitionDuration:
                                            const Duration(milliseconds: 350),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'See all',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: colors.isDark
                                          ? AppColors.accentGold
                                          : colors.accentMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _categories.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, i) {
                                final cat = _categories[i];
                                final active = _selectedCategory == cat;
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() => _selectedCategory = cat);
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            BrowseScreen(initialCategory: cat),
                                        transitionsBuilder:
                                            (_, anim, __, child) =>
                                                FadeTransition(
                                                    opacity: anim,
                                                    child: child),
                                        transitionDuration:
                                            const Duration(milliseconds: 350),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 9),
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
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: Row(
                              children: [
                                Text(
                                  'New Today',
                                  style: TextStyle(
                                    fontFamily: 'Rajdhani',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              const BrowseScreen(),
                                          transitionsBuilder:
                                              (_, anim, __, child) =>
                                                  FadeTransition(
                                                      opacity: anim,
                                                      child: child),
                                          transitionDuration: const Duration(
                                              milliseconds: 350),
                                        ));
                                  },
                                  child: Text(
                                    'See all',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: colors.isDark
                                          ? AppColors.accentGold
                                          : colors.accentMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (data.newToday.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Text(
                                'No new wallpapers yet — check back tomorrow.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: colors.textTertiary,
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              height: 160,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: data.newToday.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (_, i) =>
                                    _NewTodayCard(wallpaper: data.newToday[i]),
                              ),
                            ),
                          const SizedBox(height: 24),
                          const AdBanner(
                            margin: EdgeInsets.fromLTRB(20, 0, 20, 24),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: Row(
                              children: [
                                Icon(Icons.emoji_events_rounded,
                                    color: colors.isDark
                                        ? AppColors.accentGold
                                        : colors.accentMuted,
                                    size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Most Downloaded',
                                  style: TextStyle(
                                    fontFamily: 'Rajdhani',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              const BrowseScreen(),
                                          transitionsBuilder:
                                              (_, anim, __, child) =>
                                                  FadeTransition(
                                                      opacity: anim,
                                                      child: child),
                                          transitionDuration: const Duration(
                                              milliseconds: 350),
                                        ));
                                  },
                                  child: Text(
                                    'See all',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: colors.isDark
                                          ? AppColors.accentGold
                                          : colors.accentMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: ResponsiveMasonry(
                                items: data.mostDownloaded),
                          ),
                          SizedBox(height: bottomPadding + 60),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                bottom: _showFab
                    ? (64 + MediaQuery.of(context).padding.bottom + 16)
                    : -100,
                right: 24,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    final pool = [
                      ...data.featured,
                      ...data.newToday,
                      ...data.mostDownloaded
                    ];
                    if (pool.isEmpty) return;
                    final w = pool[
                        DateTime.now().millisecondsSinceEpoch % pool.length];
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            DetailScreen(wallpaper: w),
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
          );
        },
      ),
    );
  }
}

class _HomeData {
  final List<WallpaperModel> featured;
  final List<WallpaperModel> newToday;
  final List<WallpaperModel> mostDownloaded;
  const _HomeData(
      {required this.featured,
      required this.newToday,
      required this.mostDownloaded});
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();
  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return ListView(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 56),
      children: [
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ShimmerCard(height: 210, borderRadius: 20),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, __) => Container(
              width: 80,
              decoration: BoxDecoration(
                color: colors.shimmerBase,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: ShimmerCard(height: 200)),
              SizedBox(width: 8),
              Expanded(child: ShimmerCard(height: 240)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: ShimmerCard(height: 220)),
              SizedBox(width: 8),
              Expanded(child: ShimmerCard(height: 180)),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeError extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;
  const _HomeError({required this.onRetry, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded,
              color: colors.textTertiary, size: 48),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: colors.textSecondary)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.bgPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  const _FeaturedCard({required this.wallpaper});

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'stadiums':
        return Icons.stadium_rounded;
      case 'trophies':
        return Icons.emoji_events_rounded;
      case 'teams':
        return Icons.sports_soccer_rounded;
      case 'legends':
        return Icons.star_rounded;
      case 'abstract':
        return Icons.auto_fix_high_rounded;
      case 'neon':
        return Icons.bolt_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final w = wallpaper;
    final isLiked = context.watch<FavoritesProvider>().isLiked(w.id);
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
              MotionImage(
                imageUrl: w.previewUrl,
                height: 210,
                phase: motionPhase(w.id),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7)
                      ],
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
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<FavoritesProvider>().toggleLike(w.id);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.42),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isLiked ? Colors.red : Colors.white,
                          size: 19,
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
                      _formatCount(w.downloadCount),
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
              MotionImage(
                imageUrl: wallpaper.gridUrl,
                height: 160,
                phase: motionPhase(wallpaper.id),
                memCacheWidth: 400,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7)
                      ],
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
