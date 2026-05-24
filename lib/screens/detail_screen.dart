import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_colors.dart';
import '../models/wallpaper_model.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/download_service.dart';
import '../widgets/auth_required_sheet.dart';
import '../widgets/glass_pill.dart';
import '../widgets/rewarded_ad_sheet.dart';
import '../widgets/shimmer_card.dart';

String _formatCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}

class DetailScreen extends StatefulWidget {
  final WallpaperModel wallpaper;

  const DetailScreen({super.key, required this.wallpaper});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
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

  void _toggleLike(BuildContext context) {
    HapticFeedback.lightImpact();
    context.read<FavoritesProvider>().toggleLike(widget.wallpaper.id);
    _heartCtrl.forward(from: 0);
  }

  Future<void> _download(BuildContext context) async {
    HapticFeedback.lightImpact();
    final auth = context.read<AuthProvider>();
    if (!auth.isSignedIn) {
      await showAuthRequiredSheet(
        context,
        title: 'Sign in to download',
        message:
            'Create a free account to download wallpapers in full 4K and save them to your gallery.',
      );
      return;
    }
    // Record download (best-effort).
    unawaited(DownloadService.instance.record(widget.wallpaper.id));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.accentGreen, size: 18),
            SizedBox(width: 8),
            Text('Saved to gallery!',
                style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
          ],
        ),
        backgroundColor: AppColors.bgCard,
      ),
    );
  }

  Future<void> _showSetWallpaperSheet() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isSignedIn) {
      await showAuthRequiredSheet(
        context,
        title: 'Sign in to set wallpaper',
        message:
            'Create a free account to set this image as your home or lock screen.',
      );
      return;
    }
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SetWallpaperSheet(wallpaper: widget.wallpaper),
    );
  }

  Future<void> _watchAdToUnlock() async {
    HapticFeedback.lightImpact();
    final rewarded = await showRewardedAdSheet(
      context,
      rewardLabel: widget.wallpaper.title,
    );
    if (!mounted || !rewarded) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.lock_open_rounded,
                color: AppColors.accentGold, size: 18),
            SizedBox(width: 8),
            Text('Unlocked — saved to gallery!',
                style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
          ],
        ),
        backgroundColor: AppColors.bgCard,
      ),
    );
  }

  void _share() {
    HapticFeedback.lightImpact();
    Share.share(
      'Check out "${widget.wallpaper.title}" on WC Wallpapers 2026!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final colors = AppThemeColors.of(context);
    final w = widget.wallpaper;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Hero(
            tag: 'wall_${w.id}',
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: CachedNetworkImage(
                imageUrl: w.previewUrl,
                fit: BoxFit.cover,
                memCacheWidth: 1080,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (_, __) => ShimmerCard(
                    height: MediaQuery.of(context).size.height),
                errorWidget: (context, __, ___) {
                  final c = AppThemeColors.of(context);
                  return Container(
                    color: c.bgCard,
                    child: Center(
                      child: Icon(Icons.broken_image_rounded,
                          color: c.textTertiary, size: 48),
                    ),
                  );
                },
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
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                  stops: const [0.0, 0.45, 0.72, 1.0],
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
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.42),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 0.8),
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
              onTap: () => _toggleLike(context),
              child: ScaleTransition(
                scale: _heartScale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 0.8),
                      ),
                      child: Builder(
                        builder: (ctx) {
                          final liked = ctx.watch<FavoritesProvider>().isLiked(w.id);
                          return Icon(
                            liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: liked ? Colors.red : Colors.white,
                            size: 22,
                          );
                        },
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
                        _formatCount(w.downloadCount),
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
                        _formatCount(w.likeCount),
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
                          onTap: () => _download(context),
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
                            onTap: _share,
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
                    onTap: _watchAdToUnlock,
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
    final colors = AppThemeColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.bgElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                color: colors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Set As Wallpaper',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.home_rounded,
                color: AppColors.accentGold),
            title: Text('Home Screen',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: colors.textPrimary)),
            onTap: () => _show(context, 'Wallpaper set successfully'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_rounded,
                color: AppColors.accentGold),
            title: Text('Lock Screen',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: colors.textPrimary)),
            onTap: () => _show(context, 'Wallpaper set successfully'),
          ),
          ListTile(
            leading: const Icon(Icons.phone_android_rounded,
                color: AppColors.accentGold),
            title: Text('Both Screens',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: colors.textPrimary)),
            onTap: () => _show(context, 'Wallpaper set successfully'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
