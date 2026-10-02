import 'package:flutter/material.dart';
import '../../../../features/dragon/models/dragon.dart';

/// 🐉 Pure GPU-Accelerated 3D Elemental Dragon Egg Vector Painter.
/// Renders authentic, glowing, textured dragon eggs for all 4 primal elements
/// (Ignis Fire, Glacior Frost, Voltur Storm, Terra Earth) with crack veins,
/// inner molten luminescence, and ambient magical auras.
class VectorDragonEgg extends StatelessWidget {
  final DragonEggType eggType;
  final double size;
  final bool isSelected;
  final double shimmerPhase;

  const VectorDragonEgg({
    super.key,
    required this.eggType,
    this.size = 80.0,
    this.isSelected = false,
    this.shimmerPhase = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.22),
      painter: _DragonEggPainter(
        eggType: eggType,
        isSelected: isSelected,
        shimmerPhase: shimmerPhase,
      ),
    );
  }
}

class _DragonEggPainter extends CustomPainter {
  final DragonEggType eggType;
  final bool isSelected;
  final double shimmerPhase;

  _DragonEggPainter({
    required this.eggType,
    required this.isSelected,
    required this.shimmerPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.54);

    // 1. Egg Path (Classic geometric ovoid)
    final eggPath = Path();
    eggPath.moveTo(w * 0.5, h * 0.06); // Top pointed tip
    eggPath.cubicTo(w * 0.88, h * 0.08, w * 1.00, h * 0.56, w * 0.88, h * 0.86); // Right curve
    eggPath.cubicTo(w * 0.78, h * 1.00, w * 0.22, h * 1.00, w * 0.12, h * 0.86); // Bottom round
    eggPath.cubicTo(w * 0.00, h * 0.56, w * 0.12, h * 0.08, w * 0.5, h * 0.06); // Left curve
    eggPath.close();

    // 2. Outer magical aura glow
    if (isSelected) {
      final glowPaint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..color = _getPrimaryColor(eggType).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      canvas.drawPath(eggPath, glowPaint);
    }

    // 3. Drop Shadow behind egg
    final shadowPaint = Paint()
      ..isAntiAlias = true
      ..color = Colors.black.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, h * 0.92), width: w * 0.72, height: h * 0.16),
      shadowPaint,
    );

    // 4. Egg Body Fill (Radial 3D Light Source Top-Left)
    final bodyPaint = Paint()
      ..isAntiAlias = true
      ..shader = _getBodyGradient(eggType).createShader(
        Rect.fromLTWH(0, 0, w, h),
      );
    canvas.drawPath(eggPath, bodyPaint);

    // 5. Clip for inner details & textures
    canvas.save();
    canvas.clipPath(eggPath);

    // 5a. Element-specific Veins & Textures
    _drawElementalDetails(canvas, w, h, eggType);

    // 5b. Inner Bottom Ambient Occlusion / Shadow
    final innerAoPaint = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        center: const Alignment(0.0, 1.2),
        radius: 0.8,
        colors: [
          Colors.black.withValues(alpha: 0.75),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), innerAoPaint);

    // 5c. Top-Left Primary Gloss Highlight (Pill / Crescent)
    final glossPath = Path();
    glossPath.moveTo(w * 0.28, h * 0.16);
    glossPath.cubicTo(w * 0.44, h * 0.14, w * 0.48, h * 0.26, w * 0.38, h * 0.38);
    glossPath.cubicTo(w * 0.26, h * 0.44, w * 0.18, h * 0.30, w * 0.28, h * 0.16);
    glossPath.close();

    final glossPaint = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.85),
          Colors.white.withValues(alpha: 0.10),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(glossPath, glossPaint);

    // 5d. Shimmer Phase Sweep (if active)
    if (shimmerPhase > 0.0) {
      final shimmerX = w * (shimmerPhase * 2.0 - 0.5);
      final shimmerPaint = Paint()
        ..isAntiAlias = true
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.40),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(shimmerX - w * 0.4, 0, w * 0.8, h));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), shimmerPaint);
    }

    canvas.restore();

    // 6. Crisp Outer Rim Stroke
    final rimPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = _getPrimaryColor(eggType).withValues(alpha: isSelected ? 0.90 : 0.45);
    canvas.drawPath(eggPath, rimPaint);
  }

  Color _getPrimaryColor(DragonEggType type) {
    switch (type) {
      case DragonEggType.fire:
        return const Color(0xFFFF5722);
      case DragonEggType.ice:
        return const Color(0xFF00E5FF);
      case DragonEggType.storm:
        return const Color(0xFFFFEA00);
      case DragonEggType.earth:
        return const Color(0xFF10B981);
    }
  }

  Gradient _getBodyGradient(DragonEggType type) {
    switch (type) {
      case DragonEggType.fire:
        return const RadialGradient(
          center: Alignment(-0.25, -0.3),
          radius: 0.9,
          colors: [
            Color(0xFFFF8A65),
            Color(0xFFD84315),
            Color(0xFF3E1207),
            Color(0xFF1A0502),
          ],
          stops: [0.0, 0.40, 0.85, 1.0],
        );
      case DragonEggType.ice:
        return const RadialGradient(
          center: Alignment(-0.25, -0.3),
          radius: 0.9,
          colors: [
            Color(0xFFE0F7FA),
            Color(0xFF00B0FF),
            Color(0xFF01579B),
            Color(0xFF04182E),
          ],
          stops: [0.0, 0.35, 0.82, 1.0],
        );
      case DragonEggType.storm:
        return const RadialGradient(
          center: Alignment(-0.25, -0.3),
          radius: 0.9,
          colors: [
            Color(0xFFFFFDE7),
            Color(0xFFFFD600),
            Color(0xFF7C3AED),
            Color(0xFF1E0638),
          ],
          stops: [0.0, 0.35, 0.80, 1.0],
        );
      case DragonEggType.earth:
        return const RadialGradient(
          center: Alignment(-0.25, -0.3),
          radius: 0.9,
          colors: [
            Color(0xFFA7F3D0),
            Color(0xFF059669),
            Color(0xFF064E3B),
            Color(0xFF0A2218),
          ],
          stops: [0.0, 0.38, 0.82, 1.0],
        );
    }
  }

  void _drawElementalDetails(Canvas canvas, double w, double h, DragonEggType type) {
    final veinPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowVeinPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

    switch (type) {
      case DragonEggType.fire:
        // Glowing Magma Cracks
        glowVeinPaint.color = const Color(0xFFFF6D00).withValues(alpha: 0.75);
        glowVeinPaint.strokeWidth = 3.2;
        veinPaint.color = const Color(0xFFFFEB3B);
        veinPaint.strokeWidth = 1.4;

        final crack1 = Path()
          ..moveTo(w * 0.48, h * 0.32)
          ..lineTo(w * 0.58, h * 0.48)
          ..lineTo(w * 0.52, h * 0.62)
          ..lineTo(w * 0.68, h * 0.74);
        final crack2 = Path()
          ..moveTo(w * 0.58, h * 0.48)
          ..lineTo(w * 0.42, h * 0.56)
          ..lineTo(w * 0.38, h * 0.72);

        canvas.drawPath(crack1, glowVeinPaint);
        canvas.drawPath(crack1, veinPaint);
        canvas.drawPath(crack2, glowVeinPaint);
        canvas.drawPath(crack2, veinPaint);
        break;

      case DragonEggType.ice:
        // Crystalline Glacial Facets
        veinPaint.color = Colors.white.withValues(alpha: 0.65);
        veinPaint.strokeWidth = 1.0;
        final crystalPath = Path()
          ..moveTo(w * 0.50, h * 0.35)
          ..lineTo(w * 0.66, h * 0.48)
          ..lineTo(w * 0.50, h * 0.68)
          ..lineTo(w * 0.34, h * 0.48)
          ..close();
        canvas.drawPath(crystalPath, veinPaint);
        canvas.drawLine(Offset(w * 0.50, h * 0.35), Offset(w * 0.50, h * 0.68), veinPaint);
        canvas.drawLine(Offset(w * 0.34, h * 0.48), Offset(w * 0.66, h * 0.48), veinPaint);
        break;

      case DragonEggType.storm:
        // High-Voltage Lightning Bolts
        glowVeinPaint.color = const Color(0xFFFFEA00).withValues(alpha: 0.85);
        glowVeinPaint.strokeWidth = 3.6;
        veinPaint.color = Colors.white;
        veinPaint.strokeWidth = 1.5;

        final bolt = Path()
          ..moveTo(w * 0.54, h * 0.28)
          ..lineTo(w * 0.44, h * 0.46)
          ..lineTo(w * 0.58, h * 0.50)
          ..lineTo(w * 0.40, h * 0.76);
        canvas.drawPath(bolt, glowVeinPaint);
        canvas.drawPath(bolt, veinPaint);
        break;

      case DragonEggType.earth:
        // Emerald Geode Facets & Ancient Runes
        veinPaint.color = const Color(0xFF6EE7B7).withValues(alpha: 0.75);
        veinPaint.strokeWidth = 1.2;
        final geode1 = Path()
          ..moveTo(w * 0.42, h * 0.40)
          ..lineTo(w * 0.58, h * 0.38)
          ..lineTo(w * 0.64, h * 0.54)
          ..lineTo(w * 0.52, h * 0.66)
          ..lineTo(w * 0.38, h * 0.56)
          ..close();
        canvas.drawPath(geode1, veinPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DragonEggPainter oldDelegate) =>
      oldDelegate.eggType != eggType ||
      oldDelegate.isSelected != isSelected ||
      oldDelegate.shimmerPhase != shimmerPhase;
}
