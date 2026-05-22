import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';

/// Simulates a rewarded video ad. Returns true when the user watches to
/// the end and claims the reward, false if they dismiss early.
Future<bool> showRewardedAdSheet(
  BuildContext context, {
  String rewardLabel = 'wallpaper',
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (_) => _RewardedAdSheet(rewardLabel: rewardLabel),
  );
  return result ?? false;
}

class _RewardedAdSheet extends StatefulWidget {
  final String rewardLabel;
  const _RewardedAdSheet({required this.rewardLabel});

  @override
  State<_RewardedAdSheet> createState() => _RewardedAdSheetState();
}

class _RewardedAdSheetState extends State<_RewardedAdSheet> {
  static const _total = 5;
  int _remaining = _total;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) _remaining--;
        if (_remaining == 0) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = _remaining == 0;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + safeBottom),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text(
                'REWARDED AD',
                style: TextStyle(
                  fontFamily: 'Rajdhani',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context, false);
                },
                child: Icon(Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.4), size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B1B2E), Color(0xFF0F0F1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle, width: 0.5),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            done
                                ? Icons.check_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.accentGold,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          done
                              ? 'Thanks for watching!'
                              : 'Your ad is playing…',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Ad',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            done
                ? 'Reward ready — claim to unlock your ${widget.rewardLabel}.'
                : 'Reward unlocks in $_remaining s',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: done
                ? () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context, true);
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                gradient: done ? AppColors.goldGradient : null,
                color: done ? null : AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  done ? 'CLAIM REWARD' : 'PLEASE WAIT…',
                  style: TextStyle(
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: done ? AppColors.bgPrimary : AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
