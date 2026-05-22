import 'dart:math';
import 'package:flutter/material.dart';

class OrbConfig {
  final Color color;
  final double base;
  final double driftX;
  final double driftY;
  final double speed;
  final double phase;
  final double wobble;

  const OrbConfig({
    required this.color,
    required this.base,
    required this.driftX,
    required this.driftY,
    required this.speed,
    required this.phase,
    required this.wobble,
  });
}

class OrbPainter extends CustomPainter {
  final double t;
  final List<OrbConfig> orbs;
  final Color bgColor;
  final double opacity;

  OrbPainter({
    required this.t,
    required this.orbs,
    this.bgColor = const Color(0xFF08080F),
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    final cx = size.width / 2;
    final cy = size.height / 2;

    for (final orb in orbs) {
      final x = cx + sin(t * 2 * pi * orb.speed + orb.phase) * orb.driftX;
      final y = cy + cos(t * 2 * pi * orb.speed * 0.73 + orb.phase) * orb.driftY;
      final r = orb.base + sin(t * 2 * pi * 3 + orb.phase) * orb.wobble * orb.base;
      final rect = Rect.fromCircle(center: Offset(x, y), radius: r);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [orb.color.withValues(alpha: 0.85 * opacity), Colors.transparent],
        ).createShader(rect)
        ..blendMode = BlendMode.screen;
      canvas.saveLayer(rect, Paint());
      canvas.drawOval(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(OrbPainter old) => true;
}

const List<OrbConfig> splashOrbs = [
  OrbConfig(color: Color(0xFFC86400), base: 220, driftX: 55, driftY: 40, speed: 0.70, phase: 0.0, wobble: 0.13),
  OrbConfig(color: Color(0xFFB43200), base: 170, driftX: 45, driftY: 60, speed: 0.50, phase: 1.2, wobble: 0.10),
  OrbConfig(color: Color(0xFFFF8C00), base: 150, driftX: 60, driftY: 35, speed: 0.90, phase: 2.4, wobble: 0.15),
  OrbConfig(color: Color(0xFFFFC832), base: 100, driftX: 30, driftY: 45, speed: 0.60, phase: 0.8, wobble: 0.08),
  OrbConfig(color: Color(0xFF783CC8), base: 90, driftX: 40, driftY: 50, speed: 1.10, phase: 3.6, wobble: 0.12),
];

const List<OrbConfig> purpleOrbs = [
  OrbConfig(color: Color(0xFF7832C8), base: 200, driftX: 55, driftY: 40, speed: 0.40, phase: 0.0, wobble: 0.13),
  OrbConfig(color: Color(0xFF5014A0), base: 170, driftX: 45, driftY: 60, speed: 0.30, phase: 1.2, wobble: 0.10),
  OrbConfig(color: Color(0xFF3E1B70), base: 150, driftX: 60, driftY: 35, speed: 0.45, phase: 2.4, wobble: 0.15),
  OrbConfig(color: Color(0xFF0D0520), base: 100, driftX: 30, driftY: 45, speed: 0.35, phase: 0.8, wobble: 0.08),
];
