import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';

class LegalSection {
  final String heading;
  final String body;
  const LegalSection(this.heading, this.body);
}

/// Reusable long-form legal/policy reader. Use the [LegalScreen.privacy]
/// and [LegalScreen.terms] factories for the bundled documents.
class LegalScreen extends StatelessWidget {
  final String title;
  final String effectiveDate;
  final List<LegalSection> sections;

  const LegalScreen({
    super.key,
    required this.title,
    required this.effectiveDate,
    required this.sections,
  });

  factory LegalScreen.privacy() => const LegalScreen(
        title: 'Privacy Policy',
        effectiveDate: 'Last updated: May 2026',
        sections: [
          LegalSection(
            'Information We Collect',
            'WC Wallpapers 2026 is designed to work without an account. '
                'When you choose to sign in, we store your name and email '
                'so your favourites can sync across devices. The app also '
                'keeps anonymous usage data such as which wallpapers are '
                'opened, to help us improve our collection.',
          ),
          LegalSection(
            'How We Use Your Data',
            'Your data is used solely to deliver and improve the app: '
                'syncing favourites, remembering preferences, and measuring '
                'which packs are popular. We never sell your personal '
                'information to third parties.',
          ),
          LegalSection(
            'Wallpaper Downloads',
            'Downloaded wallpapers are saved to your device gallery. The '
                'app requests storage permission only for this purpose and '
                'does not read other files on your device.',
          ),
          LegalSection(
            'Advertising',
            'The free version of the app shows ads. Ad partners may use '
                'device identifiers to deliver relevant content. Upgrading '
                'to Premium removes all ads and the associated tracking.',
          ),
          LegalSection(
            'Data Security',
            'We use industry-standard encryption for data in transit. While '
                'no system is perfectly secure, we take reasonable steps to '
                'protect the limited information we hold.',
          ),
          LegalSection(
            'Your Rights',
            'You can request deletion of your account data at any time from '
                'Settings, or by contacting support. Removing the app also '
                'clears all locally stored preferences and favourites.',
          ),
          LegalSection(
            'Contact Us',
            'Questions about this policy? Email us at '
                'support@wcwallpapers.app and we\'ll respond within a few '
                'business days.',
          ),
        ],
      );

  factory LegalScreen.terms() => const LegalScreen(
        title: 'Terms of Service',
        effectiveDate: 'Last updated: May 2026',
        sections: [
          LegalSection(
            'Acceptance of Terms',
            'By downloading or using WC Wallpapers 2026 you agree to these '
                'Terms of Service. If you do not agree, please discontinue '
                'use of the app.',
          ),
          LegalSection(
            'Use of the App',
            'The app is provided for personal, non-commercial use. You may '
                'download wallpapers and set them on your own devices. You '
                'may not redistribute, resell, or repackage the content.',
          ),
          LegalSection(
            'Wallpaper Content & Licensing',
            'Wallpapers are licensed for personal device use only. All '
                'imagery remains the property of its respective creators and '
                'WC Wallpapers 2026. The app is not affiliated with FIFA or '
                'any official tournament organiser.',
          ),
          LegalSection(
            'Premium Purchases',
            'Premium is a one-time, non-recurring purchase that unlocks all '
                'wallpapers and removes ads. Purchases are handled by the '
                'app store and are subject to its refund policy.',
          ),
          LegalSection(
            'Prohibited Conduct',
            'You agree not to reverse engineer the app, abuse rewarded ads, '
                'or use automated tools to mass-download content.',
          ),
          LegalSection(
            'Disclaimer',
            'The app is provided "as is" without warranties of any kind. We '
                'are not liable for any damages arising from its use, to the '
                'extent permitted by law.',
          ),
          LegalSection(
            'Changes to These Terms',
            'We may update these terms occasionally. Continued use of the '
                'app after changes take effect constitutes acceptance of the '
                'revised terms.',
          ),
          LegalSection(
            'Contact Us',
            'For any questions regarding these terms, contact '
                'support@wcwallpapers.app.',
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final maxW = Responsive.contentMaxWidth(context);

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
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
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
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
                  children: [
                    Text(
                      effectiveDate,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (var i = 0; i < sections.length; i++) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}.  ',
                            style: const TextStyle(
                              fontFamily: 'Rajdhani',
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: AppColors.accentGold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              sections[i].heading,
                              style: const TextStyle(
                                fontFamily: 'Rajdhani',
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sections[i].body,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      if (i != sections.length - 1) const SizedBox(height: 28),
                    ],
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
