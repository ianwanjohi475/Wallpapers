import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  int _rating = 0;
  int _hoveredRating = 0;
  final _feedbackCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating first'),
          backgroundColor: AppColors.bgCard,
        ),
      );
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _submitted ? _buildSuccess() : _buildForm(safeTop),
      ),
    );
  }

  Widget _buildForm(double safeTop) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle, width: 0.5),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'RATE APP',
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

          const SizedBox(height: 48),

          // Trophy icon
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: AppColors.accentGold, size: 48),
          ),

          const SizedBox(height: 28),

          const Text(
            'Enjoying WC Wallpapers?',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontWeight: FontWeight.w700,
              fontSize: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Your rating helps us improve and reach more football fans around the world.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              final filled =
                  (_hoveredRating > 0 ? _hoveredRating : _rating) >= star;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _rating = star);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: filled ? 52 : 48,
                    color: filled
                        ? AppColors.accentGold
                        : AppColors.borderSubtle,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Rating label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _rating == 0
                  ? 'Tap to rate'
                  : ['', 'Poor', 'Fair', 'Good', 'Great', 'Amazing!'][_rating],
              key: ValueKey(_rating),
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: _rating == 0
                    ? AppColors.textTertiary
                    : AppColors.accentGold,
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Feedback input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Additional feedback (optional)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _feedbackCtrl,
                  maxLines: 4,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tell us what you love or what we can improve...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.bgCard,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.borderSubtle, width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.borderSubtle, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppColors.accentGold, width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Submit button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: _submit,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: _rating > 0 ? AppColors.goldGradient : null,
                  color: _rating == 0 ? AppColors.bgCard : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _rating > 0
                      ? [
                          BoxShadow(
                            color: AppColors.accentGold.withValues(alpha: 0.35),
                            blurRadius: 20,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'SUBMIT RATING',
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: _rating > 0 ? AppColors.bgPrimary : AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Skip
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text(
              'Maybe Later',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.4), width: 1),
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.accentGreen, size: 48),
            ),
            const SizedBox(height: 28),
            const Text(
              'Thank You! 🙌',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w700,
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your feedback helps us build the best wallpaper app for football fans.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            // Stars display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => Icon(
                  i < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 36,
                  color: i < _rating
                      ? AppColors.accentGold
                      : AppColors.borderSubtle,
                ),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Back to App',
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.bgPrimary,
                    ),
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
