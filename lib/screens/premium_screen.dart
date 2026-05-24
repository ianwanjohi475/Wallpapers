import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../painters/orb_painter.dart';
import '../services/purchase_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbCtrl;
  late final PurchaseService _purchase;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _purchase = PurchaseService.instance;
    _purchase.addListener(_onPurchaseChanged);
  }

  void _onPurchaseChanged() {
    if (!mounted) return;
    setState(() {});
    if (_purchase.isPremium) {
      _showSuccessAndPop();
    } else if (_purchase.error != null) {
      _showError(_purchase.error!);
      _purchase.clearError();
    }
  }

  void _showSuccessAndPop() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '🏆 Premium unlocked! Enjoy all wallpapers.',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: AppColors.accentGreen,
        duration: Duration(seconds: 3),
      ),
    );
    Navigator.of(context).pop();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    _purchase.removeListener(_onPurchaseChanged);
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final isBusy = _purchase.purchasing || _purchase.loading;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      body: AnimatedBuilder(
        animation: _orbCtrl,
        builder: (context, _) {
          return Stack(
            children: [
              CustomPaint(
                size: size,
                painter: OrbPainter(
                  t: _orbCtrl.value,
                  orbs: purpleOrbs,
                  bgColor: AppColors.bgPrimary,
                ),
              ),
              Positioned(
                top: safeTop + 16,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 22,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: safeTop + 16,
                  bottom: safeBottom + 40,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),

                      // Crown icon with glow
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGold.withValues(alpha: 0.30),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppColors.accentGold,
                          size: 58,
                        ),
                      ),
                      const SizedBox(height: 28),

                      const Text(
                        'GO PREMIUM',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontWeight: FontWeight.w700,
                          fontSize: 36,
                          color: AppColors.accentGold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ONE-TIME PURCHASE · NO SUBSCRIPTION',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.45),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Benefits glass card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                                width: 0.5,
                              ),
                            ),
                            child: const Column(
                              children: [
                                _BenefitRow(
                                  icon: Icons.image_rounded,
                                  label: 'Unlock 800+ premium wallpapers',
                                ),
                                SizedBox(height: 18),
                                _BenefitRow(
                                  icon: Icons.block_rounded,
                                  label: 'Remove all ads forever',
                                ),
                                SizedBox(height: 18),
                                _BenefitRow(
                                  icon: Icons.hd_rounded,
                                  label: '4K ultra-HD quality downloads',
                                ),
                                SizedBox(height: 18),
                                _BenefitRow(
                                  icon: Icons.bolt_rounded,
                                  label: 'Early access to new daily packs',
                                ),
                                SizedBox(height: 18),
                                _BenefitRow(
                                  icon: Icons.all_inclusive_rounded,
                                  label: 'Unlimited downloads, no daily cap',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Price display
                      if (_purchase.loading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.accentGold,
                            strokeWidth: 2,
                          ),
                        )
                      else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _purchase.displayPrice,
                              style: const TextStyle(
                                fontFamily: 'Rajdhani',
                                fontWeight: FontWeight.w700,
                                fontSize: 52,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'One-time · Yours forever',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),

                      // Google Play purchase button
                      GestureDetector(
                        onTap: isBusy ? null : () {
                          HapticFeedback.mediumImpact();
                          _purchase.buyPremium();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: isBusy ? null : AppColors.goldGradient,
                            color: isBusy ? AppColors.bgCard : null,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: isBusy
                                ? null
                                : [
                                    BoxShadow(
                                      color: AppColors.accentGold
                                          .withValues(alpha: 0.35),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: isBusy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: AppColors.accentGold,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_bag_rounded,
                                          color: AppColors.bgPrimary, size: 20),
                                      SizedBox(width: 10),
                                      Text(
                                        'BUY ON GOOGLE PLAY',
                                        style: TextStyle(
                                          fontFamily: 'Rajdhani',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17,
                                          color: AppColors.bgPrimary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Restore purchases
                      GestureDetector(
                        onTap: isBusy
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                _purchase.restorePurchases();
                              },
                        child: Text(
                          'Restore Purchase',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.45),
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Payment badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_rounded,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 13),
                          const SizedBox(width: 6),
                          Text(
                            'Secure payment via Google Play',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Maybe later',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ],
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

class _BenefitRow extends StatelessWidget {
  final String label;
  final IconData icon;
  const _BenefitRow({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.accentGold, size: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
