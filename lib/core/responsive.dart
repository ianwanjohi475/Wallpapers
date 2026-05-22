import 'package:flutter/material.dart';

/// Centralised breakpoints and sizing helpers so every screen adapts
/// from small phones to large tablets without per-screen guesswork.
class Responsive {
  Responsive._();

  static const double _tablet = 600;
  static const double _largeTablet = 905;
  static const double _desktop = 1240;

  static Size sizeOf(BuildContext c) => MediaQuery.sizeOf(c);
  static double widthOf(BuildContext c) => MediaQuery.sizeOf(c).width;
  static double heightOf(BuildContext c) => MediaQuery.sizeOf(c).height;

  static bool isPhone(BuildContext c) => widthOf(c) < _tablet;
  static bool isTablet(BuildContext c) => widthOf(c) >= _tablet;
  static bool isLargeTablet(BuildContext c) => widthOf(c) >= _largeTablet;

  /// Column count for the wallpaper masonry grids.
  static int gridColumns(BuildContext c) {
    final w = widthOf(c);
    if (w >= _desktop) return 5;
    if (w >= _largeTablet) return 4;
    if (w >= _tablet) return 3;
    return 2;
  }

  /// Column count for square category-style grids.
  static int tileColumns(BuildContext c) {
    final w = widthOf(c);
    if (w >= _largeTablet) return 4;
    if (w >= _tablet) return 3;
    return 2;
  }

  /// Horizontal page padding; grows on wider screens.
  static double pagePadding(BuildContext c) {
    final w = widthOf(c);
    if (w >= _largeTablet) return 40;
    if (w >= _tablet) return 28;
    return 16;
  }

  /// Caps the readable content width so forms and text columns don't
  /// stretch awkwardly wide on tablets.
  static double contentMaxWidth(BuildContext c) {
    final w = widthOf(c);
    if (w >= _desktop) return 720;
    if (w >= _tablet) return 560;
    return w;
  }

  /// A gentle scale factor (~0.88–1.20) derived from the shortest side,
  /// used to nudge fixed hero sizes up on tablets and down on tiny phones.
  static double scale(BuildContext c) {
    final shortest = MediaQuery.sizeOf(c).shortestSide;
    return (shortest / 392).clamp(0.88, 1.20);
  }

  /// Clamped text scaler — honours accessibility settings but blocks
  /// layout-breaking extremes.
  static TextScaler clampedTextScaler(BuildContext c) {
    final raw = MediaQuery.textScalerOf(c).scale(1.0);
    return TextScaler.linear(raw.clamp(0.85, 1.30));
  }
}

/// Convenience accessors so screens can call `context.isTablet` etc.
extension ResponsiveContext on BuildContext {
  bool get isPhone => Responsive.isPhone(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isLargeTablet => Responsive.isLargeTablet(this);
  int get gridColumns => Responsive.gridColumns(this);
  double get pagePadding => Responsive.pagePadding(this);
  double get contentMaxWidth => Responsive.contentMaxWidth(this);
  double get rScale => Responsive.scale(this);
}
