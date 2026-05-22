import 'package:flutter/material.dart';

class AppColors {
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
