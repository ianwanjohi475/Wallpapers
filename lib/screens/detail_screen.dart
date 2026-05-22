import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../data/mock_data.dart';
import '../models/wallpaper_model.dart';
import '../widgets/glass_pill.dart';
import '../widgets/shimmer_card.dart';
import 'premium_screen.dart';

class DetailScreen extends StatefulWidget {
  final WallpaperModel wallpaper;

  const DetailScreen({super.key, required this.wallpaper});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  bool _liked = false;
  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _toggleLike() {
    HapticFeedback.lightImpact();
    setState(() => _liked = !_liked);
    _heartCtrl.forward(from: 0);
  }

  void _showSetWallpaperSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SetWallpaperSheet(wallpaper: widget.wallpaper),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final w = widget.wallpaper;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Hero(
            tag: 'wall_${w.id}',
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.65,
              child: CachedNetworkImage(
                imageUrl: w.imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (_, __) => ShimmerCard(
                    height: MediaQuery.of(context).size.height * 0.65),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.bgCard,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded,
                        color: AppColors.textTertiary, size: 48),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.bgPrimary.withValues(alpha: 0.5),
                    AppColors.bgPrimary,
                  ],
                  stops: const [0.0, 0.3, 0.6, 0.85],
                ),
              ),
            ),
          ),
          Positioned(
            top: safeTop + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12), width: 0.5),
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: safeTop + 12,
            right: 16,
            child: GestureDetector(
              onTap: _toggleLike,
              child: ScaleTransition(
                scale: _heartScale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12), width: 0.5),
                      ),
                      child: Icon(
                        _liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _liked ? Colors.red : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 32 + safeBottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      GlassPill(
                        icon: _categoryIcon(w.category),
                        label: w.category.toUpperCase(),
                      ),
                      if (w.resolution == '4K') ...[
                        const SizedBox(width: 8),
                        GlassPill(
                          icon: Icons.hd_rounded,
                          label: '4K',
                          iconColor: AppColors.accentGreen,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    w.title,
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.download_rounded,
                          color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        MockData.formatCount(w.downloadCount),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite_rounded,
                          color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        MockData.formatCount(w.likeCount),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Saved to gallery!'),
                                backgroundColor: AppColors.bgCard,
                              ),
                            );
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentGold.withValues(alpha: 0.35),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download_rounded,
                                    color: AppColors.bgPrimary, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Download',
                                  style: TextStyle(
                                    fontFamily: 'Rajdhani',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.bgPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _showSetWallpaperSheet,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      width: 0.5),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.phone_android_rounded,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Set Wallpaper',
                                      style: TextStyle(
                                        fontFamily: 'Rajdhani',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: GestureDetector(
                            onTap: () => HapticFeedback.lightImpact(),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    width: 0.5),
                              ),
                              child: const Icon(Icons.share_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const PremiumScreen(),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: const BorderSide(
                                  color: AppColors.accentGold, width: 2),
                              top: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  width: 0.5),
                              right: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  width: 0.5),
                              bottom: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  width: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.visibility_rounded,
                                  color: AppColors.accentGold, size: 16),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Watch a short ad to unlock this free',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  color: AppColors.textTertiary, size: 11),
                            ],
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
      ),
    );
  }

  IconData _categoryIcon(String cat) {
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
      case 'dark':
        return Icons.dark_mode_rounded;
      case 'flags':
        return Icons.flag_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }
}

class _SetWallpaperSheet extends StatelessWidget {
  final WallpaperModel wallpaper;

  const _SetWallpaperSheet({required this.wallpaper});

  void _show(BuildContext context, String msg) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.accentGold, size: 18),
            const SizedBox(width: 8),
            Text(msg,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14)),
          ],
        ),
        backgroundColor: AppColors.bgCard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Set As Wallpaper',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.home_rounded,
                color: AppColors.accentGold),
            title: const Text('Home Screen',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.white)),
            onTap: () => _show(context, 'Wallpaper set successfully'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_rounded,
                color: AppColors.accentGold),
            title: const Text('Lock Screen',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.white)),
            onTap: () => _show(context, 'Wallpaper set successfully'),
          ),
          ListTile(
            leading: const Icon(Icons.phone_android_rounded,
                color: AppColors.accentGold),
            title: const Text('Both Screens',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.white)),
            onTap: () => _show(context, 'Wallpaper set successfully'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
