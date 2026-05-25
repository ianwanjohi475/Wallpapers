import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import 'shimmer_card.dart';

/// Wraps a network image with a continuous slow Ken Burns / parallax motion:
/// a subtle scale + drift loop that gives photos a living, 3D feel.
///
/// [phase] (0.0–1.0) offsets the animation start so multiple cards on screen
/// are never perfectly in sync, making the effect look organic.
class MotionImage extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double phase;
  final int memCacheWidth;

  const MotionImage({
    super.key,
    required this.imageUrl,
    required this.height,
    this.phase = 0.0,
    this.memCacheWidth = 1080,
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
      duration: const Duration(seconds: 9),
    );

    // Scale gently from 1.06 → 1.13 so edges never show during the drift.
    _scale = Tween(begin: 1.06, end: 1.13).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    // Drift diagonally — enough to feel alive, not enough to feel jittery.
    _dx = Tween(begin: -9.0, end: 9.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _dy = Tween(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    // Jump to the requested phase so cards are out of sync with each other.
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
