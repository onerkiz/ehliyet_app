import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Hafif, paketsiz konfeti efekti. Bir kez oynar (sınav geçince kutlama).
/// CustomPaint + tek AnimationController — offline, bağımlılıksız.
class ConfettiOverlay extends StatefulWidget {
  final int particleCount;
  final Duration duration;
  const ConfettiOverlay({
    super.key,
    this.particleCount = 80,
    this.duration = const Duration(milliseconds: 2600),
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Particle> _particles;

  static const _colors = [
    AppColors.primary,
    AppColors.amber,
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFFEC4899),
    Color(0xFF22C55E),
  ];

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        // Üstten, ekran genişliğine yayılmış başlangıç
        startX: rnd.nextDouble(),
        startY: -0.1 - rnd.nextDouble() * 0.2,
        vx: (rnd.nextDouble() - 0.5) * 0.6,
        vy: 0.6 + rnd.nextDouble() * 0.8,
        size: 6 + rnd.nextDouble() * 8,
        color: _colors[rnd.nextInt(_colors.length)],
        rotation: rnd.nextDouble() * math.pi * 2,
        rotationSpeed: (rnd.nextDouble() - 0.5) * 12,
        wobble: rnd.nextDouble() * math.pi * 2,
      );
    });
    _c = AnimationController(vsync: this, duration: widget.duration)..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(_particles, _c.value),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double startX; // 0..1 (genişlik oranı)
  final double startY; // ekran yüksekliği oranı
  final double vx, vy; // hız (oran/sn)
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final double wobble;
  _Particle({
    required this.startX,
    required this.startY,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.wobble,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t; // 0..1
  _ConfettiPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // Sona doğru sönümle
    final fade = t < 0.8 ? 1.0 : (1 - (t - 0.8) / 0.2);
    for (final p in particles) {
      final x = (p.startX + p.vx * t) * size.width +
          math.sin(p.wobble + t * 8) * 12;
      final y = (p.startY + p.vy * t + 0.5 * t * t) * size.height;
      if (y < -20 || y > size.height + 20) continue;
      paint.color = p.color.withValues(alpha: fade.clamp(0, 1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotationSpeed * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
