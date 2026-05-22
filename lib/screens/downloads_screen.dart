import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../data/mock_data.dart';
import '../models/wallpaper_model.dart';
import '../widgets/responsive_masonry.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  List<WallpaperModel> _downloads() {
    final seen = <String>{};
    final out = <WallpaperModel>[];
    for (final w in [
      ...MockData.getMostDownloaded(),
      ...MockData.getNewToday(),
    ]) {
      if (seen.add(w.id)) out.add(w);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final downloads = _downloads();
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MY DOWNLOADS',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${downloads.length} wallpapers saved to gallery',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: downloads.isEmpty
                ? Center(
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
                  )
                : SingleChildScrollView(
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
                                child: const Icon(Icons.sd_storage_rounded,
                                    color: AppColors.accentGreen, size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Stored in WC Wallpapers album · 128 MB used',
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
                        const SizedBox(height: 16),
                        ResponsiveMasonry(items: downloads),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
