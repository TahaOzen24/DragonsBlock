import 'package:flutter/material.dart';

/// 💖 1. Pure GPU-accelerated Vector Heart Icon
/// Renders a crisp, glossy, 3D candy-ruby heart at any resolution.
class VectorHeartIcon extends StatelessWidget {
  final double size;

  const VectorHeartIcon({super.key, this.size = 22.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HeartIconPainter(),
    );
  }
}

class _HeartIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Heart Path via cubic Bézier curves
    final path = Path();
    path.moveTo(w * 0.5, h * 0.85);
    path.cubicTo(w * 0.12, h * 0.62, w * 0.02, h * 0.32, w * 0.25, h * 0.15);
    path.cubicTo(w * 0.38, h * 0.06, w * 0.48, h * 0.16, w * 0.5, h * 0.28);
    path.cubicTo(w * 0.52, h * 0.16, w * 0.62, h * 0.06, w * 0.75, h * 0.15);
    path.cubicTo(w * 0.98, h * 0.32, w * 0.88, h * 0.62, w * 0.5, h * 0.85);
    path.close();

    // 1. Soft Drop Shadow
    final shadowPaint = Paint()..color = const Color(0x66000000);
    canvas.drawPath(path.shift(const Offset(0, 1.6)), shadowPaint);

    // 2. Rich Ruby Gradient Body
    final bodyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFFFF4D6D),
        Color(0xFFE11D48),
        Color(0xFF881337),
      ],
      stops: const [0.0, 0.45, 1.0],
    );
    final bodyPaint = Paint()..shader = bodyGradient.createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, bodyPaint);

    // 3. Top Specular Shine (Left lobe gloss)
    final glossPath = Path();
    glossPath.moveTo(w * 0.25, h * 0.20);
    glossPath.quadraticBezierTo(w * 0.35, h * 0.18, w * 0.42, h * 0.28);
    glossPath.quadraticBezierTo(w * 0.34, h * 0.32, w * 0.24, h * 0.28);
    glossPath.close();

    final glossPaint = Paint()..color = Colors.white.withValues(alpha: 0.60);
    canvas.drawPath(glossPath, glossPaint);

    // 4. Crisp Inner Rim Outline
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 👑 2. Pure GPU-accelerated Vector Crown Icon
/// Renders an authentic imperial 3D gold crown with jewel dots and specular gloss.
class VectorCrownIcon extends StatelessWidget {
  final double size;

  const VectorCrownIcon({super.key, this.size = 22.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CrownIconPainter(),
    );
  }
}

class _CrownIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Crown Base & Peaks Path
    final path = Path();
    path.moveTo(w * 0.14, h * 0.78);
    path.lineTo(w * 0.86, h * 0.78);
    path.lineTo(w * 0.90, h * 0.36); // Right peak
    path.lineTo(w * 0.68, h * 0.54); // Right valley
    path.lineTo(w * 0.50, h * 0.22); // Center peak (tallest)
    path.lineTo(w * 0.32, h * 0.54); // Left valley
    path.lineTo(w * 0.10, h * 0.36); // Left peak
    path.close();

    // 1. Soft Drop Shadow
    final shadowPaint = Paint()..color = const Color(0x66000000);
    canvas.drawPath(path.shift(const Offset(0, 1.8)), shadowPaint);

    // 2. Rich Imperial Gold Gradient Body
    final goldGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFFFEF08A),
        Color(0xFFF59E0B),
        Color(0xFFB45309),
      ],
      stops: const [0.0, 0.45, 1.0],
    );
    final bodyPaint = Paint()..shader = goldGradient.createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, bodyPaint);

    // 3. Headband Rim Bar
    final bandRect = Rect.fromLTWH(w * 0.13, h * 0.68, w * 0.74, h * 0.11);
    final bandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFDE047), Color(0xFFD97706)],
      ).createShader(bandRect);
    canvas.drawRRect(RRect.fromRectAndRadius(bandRect, const Radius.circular(2)), bandPaint);

    // 4. Peak Ball Tips
    final ballPaint = Paint()..color = const Color(0xFFFFFBEB);
    canvas.drawCircle(Offset(w * 0.10, h * 0.34), w * 0.065, ballPaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.20), w * 0.08, ballPaint);
    canvas.drawCircle(Offset(w * 0.90, h * 0.34), w * 0.065, ballPaint);

    // 5. Embedded Headband Gemstone Dots (Ruby in center, Emerald & Sapphire on sides)
    canvas.drawCircle(Offset(w * 0.32, h * 0.735), 1.6, Paint()..color = const Color(0xFF00E676));
    canvas.drawCircle(Offset(w * 0.50, h * 0.735), 2.2, Paint()..color = const Color(0xFFFF2A55));
    canvas.drawCircle(Offset(w * 0.68, h * 0.735), 1.6, Paint()..color = const Color(0xFF00D2FC));

    // 6. Crisp Inner Rim Outline
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🪙 3. Pure GPU-accelerated Vector Coin Icon
/// Renders a 3D gold medallion coin with inner concentric ring and central star glint.
class VectorCoinIcon extends StatelessWidget {
  final double size;

  const VectorCoinIcon({super.key, this.size = 22.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CoinIconPainter(),
    );
  }
}

class _CoinIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);
    final outerRadius = w * 0.46;

    // 1. Soft Drop Shadow
    final shadowPaint = Paint()..color = const Color(0x66000000);
    canvas.drawCircle(center.translate(0, 1.8), outerRadius, shadowPaint);

    // 2. Outer Beveled Gold Coin Disc
    final outerGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [
        Color(0xFFFEF08A),
        Color(0xFFEAB308),
        Color(0xFF854D0E),
      ],
      stops: const [0.0, 0.45, 1.0],
    );
    final outerPaint = Paint()..shader = outerGradient.createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawCircle(center, outerRadius, outerPaint);

    // 3. Inner Concentric Groove Ring
    final innerRadius = outerRadius * 0.76;
    final innerPaint = Paint()
      ..color = const Color(0xFFCA8A04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, innerRadius, innerPaint);

    // 4. Central Diamond Star Emblem
    final starPath = Path();
    final starSize = w * 0.28;
    starPath.moveTo(center.dx, center.dy - starSize);
    starPath.quadraticBezierTo(center.dx + 1.2, center.dy - 1.2, center.dx + starSize, center.dy);
    starPath.quadraticBezierTo(center.dx + 1.2, center.dy + 1.2, center.dx, center.dy + starSize);
    starPath.quadraticBezierTo(center.dx - 1.2, center.dy + 1.2, center.dx - starSize, center.dy);
    starPath.quadraticBezierTo(center.dx - 1.2, center.dy - 1.2, center.dx, center.dy - starSize);
    starPath.close();

    final starPaint = Paint()..color = const Color(0xFFFFFBEB);
    canvas.drawPath(starPath, starPaint);

    // 5. Specular Gloss Arc on the top edge
    final glossRect = Rect.fromLTWH(w * 0.18, h * 0.12, w * 0.64, h * 0.32);
    final glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.65),
          Colors.white.withValues(alpha: 0.05),
        ],
      ).createShader(glossRect);
    canvas.drawOval(glossRect, glossPaint);

    // 6. Crisp Outer Rim Stroke
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, outerRadius, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
