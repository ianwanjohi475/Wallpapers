import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The official multi-colour Google "G" mark, drawn with a painter so
/// it stays crisp at any size without bundling an image asset.
class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  double _rad(double deg) => deg * math.pi / 180.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final center = Offset(w / 2, w / 2);
    final stroke = w * 0.255;
    final arcRadius = w / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: arcRadius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    // Ring segments, clockwise, leaving a gap on the right for the bar.
    paint.color = _green;
    canvas.drawArc(rect, _rad(12), _rad(99), false, paint);
    paint.color = _yellow;
    canvas.drawArc(rect, _rad(111), _rad(94), false, paint);
    paint.color = _red;
    canvas.drawArc(rect, _rad(205), _rad(94), false, paint);
    paint.color = _blue;
    canvas.drawArc(rect, _rad(299), _rad(49), false, paint);

    // Blue crossbar of the G.
    final barHeight = stroke;
    final bar = Rect.fromLTWH(
      center.dx - barHeight * 0.05,
      center.dy - barHeight / 2,
      w / 2 + barHeight * 0.05,
      barHeight,
    );
    canvas.drawRect(
      bar,
      Paint()
        ..color = _blue
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter oldDelegate) => false;
}
