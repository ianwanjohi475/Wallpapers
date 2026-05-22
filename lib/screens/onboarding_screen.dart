import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../core/app_colors.dart';
import '../painters/orb_painter.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  late AnimationController _orbCtrl;
  late AnimationController _iconPulse2;
  late AnimationController _iconPulse3;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();

    _iconPulse2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _iconPulse3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _pageCtrl.dispose();
    _iconPulse2.dispose();
    _iconPulse3.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_done', 'true');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: anim, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_page < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _done();
    }
  }

  Widget _buildPage1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.network(
          'https://dimg.dreamflow.cloud/v1/lottie/spinning+golden+trophy+animation',
          width: 240,
          height: 240,
          animate: true,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.emoji_events_rounded,
            size: 120,
            color: AppColors.accentGold,
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          '1000+ Epic Wallpapers',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            fontSize: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'AI-generated 4K wallpapers updated every day for the biggest tournament on Earth',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.08).animate(
            CurvedAnimation(parent: _iconPulse2, curve: Curves.easeInOut),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.4),
                  blurRadius: 40,
                ),
              ],
            ),
            child: const Icon(
              Icons.phone_android_rounded,
              size: 120,
              color: AppColors.accentGold,
            ),
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'One Tap to Set',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            fontSize: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Download and set as home or lock screen in seconds — no hassle',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.08).animate(
            CurvedAnimation(parent: _iconPulse3, curve: Curves.easeInOut),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.4),
                  blurRadius: 40,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 120,
              color: AppColors.accentGold,
            ),
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Fresh Every Day',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w700,
            fontSize: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'New wallpaper packs drop daily. Be the first fan to rep your team in style',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: AnimatedBuilder(
        animation: _orbCtrl,
        builder: (context, _) {
          return Stack(
            children: [
              Opacity(
                opacity: 0.45,
                child: CustomPaint(
                  size: size,
                  painter: OrbPainter(t: _orbCtrl.value, orbs: splashOrbs),
                ),
              ),
              SafeArea(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _buildPage1(),
                    _buildPage2(),
                    _buildPage3(),
                  ],
                ),
              ),
              if (_page < 2)
                Positioned(
                  top: safeTop + 12,
                  right: 20,
                  child: TextButton(
                    onPressed: _done,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 48,
                left: 24,
                right: 24,
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _pageCtrl,
                      count: 3,
                      effect: WormEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        activeDotColor: AppColors.accentGold,
                        dotColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: _next,
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGold.withValues(alpha: 0.35),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _page == 2
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              color: AppColors.bgPrimary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _page == 2 ? 'Get Started' : 'Next',
                              style: const TextStyle(
                                fontFamily: 'Rajdhani',
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: AppColors.bgPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
