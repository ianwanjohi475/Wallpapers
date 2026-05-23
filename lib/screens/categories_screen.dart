import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/wallpaper_model.dart';
import '../services/wallpaper_service.dart';
import 'browse_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  static const _categories = [
    'Teams',
    'Stadiums',
    'Trophies',
    'Abstract',
    'Legends',
    'Neon',
    'Dark',
    'Flags',
  ];

  late Future<Map<String, List<WallpaperModel>>> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<Map<String, List<WallpaperModel>>> _load() async {
    final entries = await Future.wait(_categories.map((c) async {
      final items = await WallpaperService.instance.getByCategory(c);
      return MapEntry(c, items);
    }));
    return Map.fromEntries(entries);
  }

  static IconData _iconFor(String c) {
    switch (c.toLowerCase()) {
      case 'teams':
        return Icons.sports_soccer_rounded;
      case 'stadiums':
        return Icons.stadium_rounded;
      case 'trophies':
        return Icons.emoji_events_rounded;
      case 'abstract':
        return Icons.auto_fix_high_rounded;
      case 'legends':
        return Icons.star_rounded;
      case 'neon':
        return Icons.bolt_rounded;
      case 'dark':
        return Icons.dark_mode_rounded;
      case 'flags':
        return Icons.flag_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final cols = Responsive.tileColumns(context);
    final pad = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, safeTop + 16, 20, 16),
            decoration: const BoxDecoration(
              color: AppColors.bgPrimary,
              border: Border(
                bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Text(
                  'CATEGORIES',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, List<WallpaperModel>>>(
              future: _data,
              builder: (context, snap) {
                final loading = snap.connectionState != ConnectionState.done;
                final data = snap.data ?? const {};
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                      pad, 16, pad, MediaQuery.of(context).padding.bottom + 40),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.08,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final items = data[cat] ?? const <WallpaperModel>[];
                    return _CategoryCard(
                      name: cat,
                      icon: _iconFor(cat),
                      count: loading ? null : items.length,
                      cover: items.isNotEmpty ? items.first : null,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                BrowseScreen(initialCategory: cat),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(opacity: anim, child: child),
                            transitionDuration:
                                const Duration(milliseconds: 350),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final int? count;
  final WallpaperModel? cover;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.count,
    required this.cover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (cover != null)
              CachedNetworkImage(
                imageUrl: cover!.gridUrl,
                fit: BoxFit.cover,
                memCacheWidth: 500,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (_, __) => Container(color: AppColors.bgCard),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.bgCard),
              )
            else
              Container(color: AppColors.bgCard),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.4),
                          width: 0.5),
                    ),
                    child: Icon(icon, color: AppColors.accentGold, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count == null
                        ? 'Loading...'
                        : '$count wallpaper${count == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
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
