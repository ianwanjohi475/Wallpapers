import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    _Faq(
      'How do I set a wallpaper?',
      'Open any wallpaper, tap "Set Wallpaper", then choose Home Screen, '
          'Lock Screen, or Both. The wallpaper is applied instantly.',
    ),
    _Faq(
      'Where are downloaded wallpapers saved?',
      'Downloads are saved straight to your device gallery in a '
          '"WC Wallpapers" album so you can find them easily.',
    ),
    _Faq(
      'What does Premium include?',
      'Premium is a one-time purchase that unlocks all 800+ wallpapers, '
          'removes every ad, enables 4K downloads, and gives early access '
          'to new daily packs.',
    ),
    _Faq(
      'How do rewarded ads work?',
      'On free wallpapers you can watch a short rewarded ad to unlock a '
          'premium download without upgrading. The reward applies to that '
          'wallpaper only.',
    ),
    _Faq(
      'Will my favourites sync across devices?',
      'Yes — sign in with your account and your favourites are backed up '
          'to the cloud and restored on any device you log in to.',
    ),
    _Faq(
      'How do I restore a previous purchase?',
      'Go to Settings → Premium, then tap "Restore Purchase". Your '
          'Premium unlock will be re-applied to this device.',
    ),
  ];

  void _snack(BuildContext context, String msg) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.bgCard,
      ),
    );
  }

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
                const Text(
                  'HELP & SUPPORT',
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
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
                  children: [
                    const Text(
                      'FREQUENTLY ASKED',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: Color(0xB3FFD700),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final faq in _faqs) _FaqTile(faq: faq),
                    const SizedBox(height: 28),
                    const Text(
                      'STILL NEED HELP?',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: Color(0xB3FFD700),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ContactCard(
                      icon: Icons.mail_outline_rounded,
                      title: 'Email Support',
                      subtitle: 'support@wcwallpapers.app',
                      onTap: () =>
                          _snack(context, 'Opening your email app…'),
                    ),
                    const SizedBox(height: 12),
                    _ContactCard(
                      icon: Icons.bug_report_outlined,
                      title: 'Report a Problem',
                      subtitle: 'Tell us about a bug or crash',
                      onTap: () => _snack(context, 'Thanks — report sent!'),
                    ),
                    const SizedBox(height: 12),
                    _ContactCard(
                      icon: Icons.forum_outlined,
                      title: 'Community Forum',
                      subtitle: 'Tips and requests from other fans',
                      onTap: () => _snack(context, 'Opening community forum…'),
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

class _Faq {
  final String question;
  final String answer;
  const _Faq(this.question, this.answer);
}

class _FaqTile extends StatefulWidget {
  final _Faq faq;
  const _FaqTile({required this.faq});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle, width: 0.5),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _open = !_open);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.accentGold, size: 22),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.faq.answer,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            crossFadeState:
                _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.accentGold, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textTertiary, size: 13),
          ],
        ),
      ),
    );
  }
}
