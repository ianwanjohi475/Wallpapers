import 'package:flutter/material.dart';

/// Programmatic app brand mark. Renders entirely with CustomPaint —
/// no image assets required.
///
/// Design (80×80 canvas, all distances scale with [size]):
///   * Dark rounded square background (#08080F, radius 20)
///   * Soft gold radial glow behind everything
///   * Faint outer gold ring
///   * Phone-frame outline in gold containing a gold-tinted image preview
///     and two thin content lines (suggesting a wallpaper)
///   * Glowing gold play/view dot at the bottom with an upward triangle cut
class AppLogo extends StatelessWidget {
  final double size;
  final bool showBackground;

  const AppLogo({super.key, this.size = 80, this.showBackground = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AppLogoPainter(showBackground: showBackground),
      ),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  final bool showBackground;
  _AppLogoPainter({required this.showBackground});

  static const _bg = Color(0xFF08080F);
  static const _gold = Color(0xFFFFD700);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = w / 80;
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
          _gold.withValues(alpha: 0.30),
          _gold.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.55));
    canvas.drawRect(rect, glowPaint);

    // 2. Faint outer ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = _gold.withValues(alpha: 0.10)
      ..strokeWidth = 1.0 * s;
    canvas.drawCircle(center, w * 0.42, ringPaint);

    // 3. Phone frame — outline rounded rectangle 36×44 centered slightly up
    final phoneW = 36.0 * s;
    final phoneH = 44.0 * s;
    final phoneRect = Rect.fromCenter(
      center: Offset(w / 2, h / 2 - 3 * s),
      width: phoneW,
      height: phoneH,
    );
    final phoneRrect =
        RRect.fromRectAndRadius(phoneRect, Radius.circular(4 * s));

    // 3a. Inner image preview — gold gradient at 0.2 alpha
    final innerInset = 3.5 * s;
    final innerBottomTrim = 7.0 * s;
    final innerRect = Rect.fromLTRB(
      phoneRect.left + innerInset,
      phoneRect.top + innerInset,
      phoneRect.right - innerInset,
      phoneRect.bottom - innerInset - innerBottomTrim,
    );
    final innerRrect =
        RRect.fromRectAndRadius(innerRect, Radius.circular(2.5 * s));
    final innerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _gold.withValues(alpha: 0.30),
          _gold.withValues(alpha: 0.08),
        ],
      ).createShader(innerRect);
    canvas.drawRRect(innerRrect, innerPaint);

    // 3b. Two thin content lines below the preview
    final lineStrong = Paint()
      ..color = _gold.withValues(alpha: 0.55)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2 * s;
    final lineFaint = Paint()
      ..color = _gold.withValues(alpha: 0.30)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2 * s;
    final lineY1 = innerRect.bottom + 2.5 * s;
    final lineY2 = lineY1 + 2.6 * s;
    canvas.drawLine(
      Offset(innerRect.left + 1 * s, lineY1),
      Offset(innerRect.right - 1 * s, lineY1),
      lineStrong,
    );
    canvas.drawLine(
      Offset(innerRect.left + 1 * s, lineY2),
      Offset(innerRect.left + innerRect.width * 0.55, lineY2),
      lineFaint,
    );

    // 3c. Phone frame outline last (on top of fill)
    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = _gold
      ..strokeWidth = 1.5 * s;
    canvas.drawRRect(phoneRrect, framePaint);

    // 4. Glowing play/view dot at the bottom
    final dotCenter = Offset(w / 2, h - 13 * s);
    final dotRadius = 5.5 * s;

    final dotGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          _gold.withValues(alpha: 0.50),
          _gold.withValues(alpha: 0.0),
        ],
      ).createShader(
          Rect.fromCircle(center: dotCenter, radius: dotRadius * 2.4));
    canvas.drawCircle(dotCenter, dotRadius * 2.4, dotGlow);

    final dotPath = Path()
      ..addOval(Rect.fromCircle(center: dotCenter, radius: dotRadius));
    final tri = Path();
    final triH = 4.6 * s;
    final triW = 4.2 * s;
    tri.moveTo(dotCenter.dx, dotCenter.dy - triH / 2);
    tri.lineTo(dotCenter.dx - triW / 2, dotCenter.dy + triH / 2);
    tri.lineTo(dotCenter.dx + triW / 2, dotCenter.dy + triH / 2);
    tri.close();
    final play = Path.combine(PathOperation.difference, dotPath, tri);
    canvas.drawPath(play, Paint()..color = _gold);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AppLogoPainter old) =>
      old.showBackground != showBackground;
}
