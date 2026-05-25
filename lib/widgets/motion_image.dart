import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import 'shimmer_card.dart';

/// Wraps a network image with a continuous Ken Burns / parallax effect:
/// slow scale + diagonal drift that gives photos a living, 3D feel.
///
/// [phase] (0.0–1.0) offsets the animation start — derive it from the
/// wallpaper id so every image in a grid drifts independently:
///   phase: (wallpaper.id.hashCode.abs() % 1000) / 1000.0
///
/// [minScale]/[maxScale] control zoom depth. Keep minScale high enough
/// that the image edges never show during the drift (minScale >= 1.04).
///
/// For full-screen views pass softer values (minScale:1.03, maxScale:1.06,
/// larger drift, slower duration) for a more cinematic feel.
class MotionImage extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double phase;
  final int memCacheWidth;
  final double minScale;
  final double maxScale;
  final double driftX;
  final double driftY;
  final Duration cycleDuration;

  const MotionImage({
    super.key,
    required this.imageUrl,
    required this.height,
    this.phase = 0.0,
    this.memCacheWidth = 800,
    // Card defaults — snappy enough to feel alive on small thumbnails.
    this.minScale = 1.06,
    this.maxScale = 1.13,
    this.driftX = 9.0,
    this.driftY = 5.0,
    this.cycleDuration = const Duration(seconds: 9),
  });

  /// Preset for full-screen detail / hero images — slower & more cinematic.
  const MotionImage.fullscreen({
    super.key,
    required this.imageUrl,
    required this.height,
    this.phase = 0.0,
    this.memCacheWidth = 1080,
    this.minScale = 1.03,
    this.maxScale = 1.07,
    this.driftX = 14.0,
    this.driftY = 8.0,
    this.cycleDuration = const Duration(seconds: 14),
  });

  @override
  State<MotionImage> createState() => _MotionImageState();
}

class _MotionImageState extends State<MotionImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _dx;
  late final Animation<double> _dy;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: widget.cycleDuration,
    );

    _scale = Tween(begin: widget.minScale, end: widget.maxScale).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _dx = Tween(begin: -widget.driftX, end: widget.driftX).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _dy = Tween(begin: -widget.driftY, end: widget.driftY).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    // Jump to this image's unique phase so no two images drift in sync.
    _ctrl.value = widget.phase;
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(_scale.value, _scale.value)
            ..translate(_dx.value, _dy.value),
          child: child,
        ),
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: widget.height,
          memCacheWidth: widget.memCacheWidth,
          fadeInDuration: const Duration(milliseconds: 400),
          placeholder: (_, __) => ShimmerCard(height: widget.height),
          errorWidget: (context, __, ___) {
            final colors = AppThemeColors.of(context);
            return Container(
              color: colors.bgCard,
              child: Icon(Icons.broken_image_rounded,
                  color: colors.textTertiary, size: 40),
            );
          },
        ),
      ),
    );
  }
}

/// Returns a deterministic animation phase (0.0–1.0) from a wallpaper id.
/// Every id always maps to the same phase, so the grid never resets.
double motionPhase(String id) => (id.hashCode.abs() % 1000) / 1000.0;
