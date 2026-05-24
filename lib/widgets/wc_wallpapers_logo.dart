import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Professional shield-based brand mark for WC Wallpapers app.
/// Renders entirely with CustomPaint — no image assets required.
///
/// Design (80×80 canvas, all distances scale with [size]):
///   * Dark rounded square background (#08080F, radius 20)
///   * Soft gold radial glow behind everything
///   * Hexagon shield with gradient stroke (gold to orange)
///   * White checkmark inside shield
///   * "WC" text above shield, "WALLPAPERS" text below
///   * Three small gold accent dots in a row at the bottom
class WCWallpapersLogo extends StatelessWidget {
  final double size;
  final bool showBackground;

  const WCWallpapersLogo({
    super.key,
    this.size = 80,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WCWallpapersLogoPainter(showBackground: showBackground),
      ),
    );
  }
}

class _WCWallpapersLogoPainter extends CustomPainter {
  final bool showBackground;
  _WCWallpapersLogoPainter({required this.showBackground});

  static const _bg = Color(0xFF08080F);
  static const _gold = Color(0xFFFFD700);
  static const _orange = Color(0xFFFF7300);
  static const _white = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = w / 80; // Scale factor

    final rect = Rect.fromLTWH(0, 0, w, h);
    final outerRrect =
        RRect.fromRectAndRadius(rect, Radius.circular(20 * s));

    canvas.save();
    canvas.clipRRect(outerRrect);

    if (showBackground) {
      canvas.drawRect(rect, Paint()..color = _bg);
    }

    final center = Offset(w / 2, h / 2);

    // 1. Soft gold radial glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _gold.withValues(alpha: 0.25),
          _gold.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.50));
    canvas.drawRect(rect, glowPaint);

    // 2. Shield center (shifted up slightly to make room for text below)
    final shieldCenterY = h / 2 - 6 * s;
    final shieldCenter = Offset(w / 2, shieldCenterY);
    final shieldRadius = 18 * s;

    // 3. Draw hexagon shield
    _drawHexagonShield(canvas, shieldCenter, shieldRadius, s);

    // 4. Draw white checkmark inside shield
    _drawCheckmark(canvas, shieldCenter, shieldRadius * 0.55, s);

    // 5. Draw "WC" text above shield
    _drawText(
      canvas,
      'WC',
      Offset(w / 2, shieldCenterY - shieldRadius - 6 * s),
      fontSizePx: 14 * s,
      fontFamily: 'Rajdhani',
      fontWeight: FontWeight.w700,
    );

    // 6. Draw "WALLPAPERS" text below shield
    _drawText(
      canvas,
      'WALLPAPERS',
      Offset(w / 2, shieldCenterY + shieldRadius + 5 * s),
      fontSizePx: 7 * s,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
    );

    // 7. Draw three accent dots at the very bottom
    final dotY = h - 8 * s;
    final dotRadius = 1.5 * s;
    final dotSpacing = 5 * s;
    final dotStartX = w / 2 - dotSpacing;

    final dotPaint = Paint()..color = _gold;
    for (int i = 0; i < 3; i++) {
      final dotX = dotStartX + (i * dotSpacing);
      canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
    }

    canvas.restore();
  }

  void _drawHexagonShield(
    Canvas canvas,
    Offset center,
    double radius,
    double s,
  ) {
    final path = Path();
    const sides = 6;
    final angle = 2 * math.pi / sides;

    for (int i = 0; i < sides; i++) {
      final theta = (i * angle) - math.pi / 2;
      final x = center.dx + radius * math.cos(theta);
      final y = center.dy + radius * math.sin(theta);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _gold.withValues(alpha: 0.15),
          _orange.withValues(alpha: 0.10),
        ],
      ).createShader(path.getBounds());
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * s
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_gold, _orange],
      ).createShader(path.getBounds());
    canvas.drawPath(path, strokePaint);
  }

  void _drawCheckmark(
    Canvas canvas,
    Offset center,
    double radius,
    double s,
  ) {
    final paint = Paint()
      ..color = _white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(center.dx - radius * 0.4, center.dy + radius * 0.1);
    checkPath.lineTo(center.dx - radius * 0.05, center.dy + radius * 0.35);
    checkPath.lineTo(center.dx + radius * 0.45, center.dy - radius * 0.35);

    canvas.drawPath(checkPath, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    required double fontSizePx,
    required String fontFamily,
    required FontWeight fontWeight,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _white,
          fontSize: fontSizePx,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _WCWallpapersLogoPainter old) =>
      old.showBackground != showBackground;
}
