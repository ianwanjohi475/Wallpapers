import 'package:flutter/material.dart';

class AppColors {
  // Dark palette (existing constants — unchanged so all existing code compiles)
  static const bgPrimary = Color(0xFF08080F);
  static const bgCard = Color(0xFF0F0F1A);
  static const bgElevated = Color(0xFF161625);
  static const bgGlass = Color(0x0AFFFFFF);
  static const accentGold = Color(0xFFFFD700);
  static const accentOrange = Color(0xFFFF7300);
  static const accentGreen = Color(0xFF00E676);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x8CFFFFFF);
  static const textTertiary = Color(0x40FFFFFF);
  static const borderSubtle = Color(0x0FFFFFFF);
  static const borderGold = Color(0x40FFD700);
  static const lockGold = Color(0xE6FFD700);

  static const goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF7300)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// Theme-aware colour set. Use [AppThemeColors.of(context)] anywhere
/// the colour needs to adapt to light / dark mode.
class AppThemeColors {
  final Color bgPrimary;
  final Color bgCard;
  final Color bgElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color borderSubtle;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color accent;
  final Color accentMuted;
  final bool isDark;

  const AppThemeColors({
    required this.bgPrimary,
    required this.bgCard,
    required this.bgElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.borderSubtle,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.accent,
    required this.accentMuted,
    required this.isDark,
  });

  static AppThemeColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? _dark : _light;
  }

  static const _dark = AppThemeColors(
    bgPrimary: Color(0xFF08080F),
    bgCard: Color(0xFF0F0F1A),
    bgElevated: Color(0xFF161625),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0x8CFFFFFF),
    textTertiary: Color(0x40FFFFFF),
    borderSubtle: Color(0x0FFFFFFF),
    shimmerBase: Color(0xFF141428),
    shimmerHighlight: Color(0xFF2B2B50),
    accent: Color(0xFFFFD700),
    accentMuted: Color(0xCCFFD700),
    isDark: true,
  );

  static const _light = AppThemeColors(
    bgPrimary: Color(0xFFF5F0E8),
    bgCard: Color(0xFFFFFBF0),
    bgElevated: Color(0xFFEDE5D0),
    textPrimary: Color(0xFF2A1F00),
    textSecondary: Color(0xFF664E00),
    textTertiary: Color(0xFF997500),
    borderSubtle: Color(0x33C8A800),
    shimmerBase: Color(0xFFE8DFC0),
    shimmerHighlight: Color(0xFFF5EDD8),
    accent: Color(0xFFB8860B),
    accentMuted: Color(0xFF8C6500),
    isDark: false,
  );
}
