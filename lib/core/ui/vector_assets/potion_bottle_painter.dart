import 'package:flutter/material.dart';

/// 🧪 Pure GPU-Accelerated RPG Alchemy Potion Bottle Vector Painter.
/// Renders authentic glass flasks with cork tops, glowing fluid levels, bubbles, and specular reflections.
class VectorPotionBottle extends StatelessWidget {
  final Color liquidColor;
  final double size;
  final double fillAmount; // 0.0 to 1.0

  const VectorPotionBottle({
    super.key,
    required this.liquidColor,
    this.size = 40.0,
    this.fillAmount = 0.78,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 0.78, size),
      painter: _PotionBottlePainter(
        liquidColor: liquidColor,
        fillAmount: fillAmount,
      ),
    );
  }
}

class _PotionBottlePainter extends CustomPainter {
  final Color liquidColor;
  final double fillAmount;

  _PotionBottlePainter({required this.liquidColor, required this.fillAmount});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Cork Stopper (Top)
    final corkRect = Rect.fromLTWH(w * 0.36, h * 0.02, w * 0.28, h * 0.12);
    final corkPaint = Paint()
      ..isAntiAlias = true
      ..shader = const LinearGradient(
        colors: [Color(0xFFD97706), Color(0xFF92400E), Color(0xFF451A03)],
      ).createShader(corkRect);
    canvas.drawRRect(RRect.fromRectAndRadius(corkRect, const Radius.circular(2)), corkPaint);

    // 2. Glass Flask Body Path (Round Bottom Flask / Alembic)
    final flaskPath = Path();
    flaskPath.moveTo(w * 0.32, h * 0.14);
    flaskPath.lineTo(w * 0.68, h * 0.14);
    flaskPath.lineTo(w * 0.68, h * 0.32);
    flaskPath.cubicTo(w * 0.96, h * 0.44, w * 1.00, h * 0.88, w * 0.50, h * 0.98);
    flaskPath.cubicTo(w * 0.00, h * 0.88, w * 0.04, h * 0.44, w * 0.32, h * 0.32);
    flaskPath.close();

    // 3. Ambient Fluid Glow
    final glowPaint = Paint()
      ..isAntiAlias = true
      ..color = liquidColor.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawPath(flaskPath, glowPaint);

    // 4. Glass Base Tint
    final glassBasePaint = Paint()
      ..isAntiAlias = true
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.70);
    canvas.drawPath(flaskPath, glassBasePaint);

    // Clip to flask for liquid
    canvas.save();
    canvas.clipPath(flaskPath);

    // 5. Liquid Fill
    final liquidTopY = h * (0.98 - fillAmount * 0.66);
    final liquidRect = Rect.fromLTWH(0, liquidTopY, w, h);
    final liquidGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        liquidColor.withValues(alpha: 0.95),
        liquidColor,
        const Color(0xFF0F172A),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final liquidPaint = Paint()
      ..isAntiAlias = true
      ..shader = liquidGradient.createShader(liquidRect);
    canvas.drawRect(liquidRect, liquidPaint);

    // Liquid surface meniscus
    final meniscusPaint = Paint()
      ..isAntiAlias = true
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(w * 0.15, liquidTopY), Offset(w * 0.85, liquidTopY), meniscusPaint);

    // Floating Bubbles
    final bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(w * 0.40, liquidTopY + 12), 1.6, bubblePaint);
    canvas.drawCircle(Offset(w * 0.62, liquidTopY + 18), 2.2, bubblePaint);
    canvas.drawCircle(Offset(w * 0.48, liquidTopY + 28), 1.4, bubblePaint);

    // 6. Left Specular Glass Reflection
    final specPath = Path();
    specPath.moveTo(w * 0.18, h * 0.42);
    specPath.cubicTo(w * 0.12, h * 0.60, w * 0.18, h * 0.82, w * 0.32, h * 0.90);
    specPath.cubicTo(w * 0.22, h * 0.80, w * 0.18, h * 0.62, w * 0.24, h * 0.42);
    specPath.close();

    final specPaint = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.60),
          Colors.white.withValues(alpha: 0.05),
        ],
      ).createShader(specPath.getBounds());
    canvas.drawPath(specPath, specPaint);

    canvas.restore();

    // 7. Glass Rim Stroke
    final rimPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.60);
    canvas.drawPath(flaskPath, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _PotionBottlePainter oldDelegate) =>
      oldDelegate.liquidColor != liquidColor || oldDelegate.fillAmount != fillAmount;
}
