import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/wallpaper_model.dart';
import '../providers/auth_provider.dart';
import '../services/download_service.dart';
import '../widgets/auth_required_sheet.dart';
import '../widgets/responsive_masonry.dart';
import '../widgets/shimmer_card.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  late Future<List<WallpaperModel>> _data;

  @override
  void initState() {
    super.initState();
    _data = DownloadService.instance.recentMine();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final pad = Responsive.pagePadding(context);
    final auth = context.watch<AuthProvider>();

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
                const Expanded(
                  child: Text(
                    'MY DOWNLOADS',
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: !auth.isSignedIn
                ? _guestView(context)
                : FutureBuilder<List<WallpaperModel>>(
                    future: _data,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(pad, 16, pad, 40),
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
                      final downloads = snap.data ?? const <WallpaperModel>[];
                      if (downloads.isEmpty) return _emptyView();
                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(pad, 16, pad, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.borderSubtle, width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGreen
                                          .withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.sd_storage_rounded,
                                        color: AppColors.accentGreen,
                                        size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${downloads.length} wallpaper${downloads.length == 1 ? "" : "s"} downloaded',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ResponsiveMasonry(items: downloads),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.download_done_rounded,
              color: AppColors.textTertiary, size: 60),
          SizedBox(height: 16),
          Text(
            'No downloads yet',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Wallpapers you download appear here',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _guestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded,
                color: AppColors.textTertiary, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Sign in to see your downloads',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your downloads sync across all your devices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => showAuthRequiredSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Create Account',
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
      ),
    );
  }
}
