import 'package:flutter/material.dart';
import '../../../../features/leaderboard/models/league.dart';

/// 🏆 Pure GPU-Accelerated League Crest & Shield Vector Painter.
/// Renders crisp, heraldic, metallic-shaded crest shields for all League Tiers
/// (Bronze Guard, Silver Knight, Gold Conqueror, Diamond Sovereign, Grand Archon Master).
class VectorLeagueCrest extends StatelessWidget {
  final LeagueTier tier;
  final double size;
  final bool showGlow;

  const VectorLeagueCrest({
    super.key,
    required this.tier,
    this.size = 48.0,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.15),
      painter: _LeagueCrestPainter(tier: tier, showGlow: showGlow),
    );
  }
}

class _LeagueCrestPainter extends CustomPainter {
  final LeagueTier tier;
  final bool showGlow;

  _LeagueCrestPainter({required this.tier, required this.showGlow});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Medieval Knight Heraldic Shield Path
    final shieldPath = Path();
    shieldPath.moveTo(w * 0.5, h * 0.98); // Bottom apex point
    shieldPath.cubicTo(w * 0.15, h * 0.82, w * 0.05, h * 0.45, w * 0.08, h * 0.12);
    shieldPath.lineTo(w * 0.5, h * 0.02); // Top chevron peak
    shieldPath.lineTo(w * 0.92, h * 0.12);
    shieldPath.cubicTo(w * 0.95, h * 0.45, w * 0.85, h * 0.82, w * 0.5, h * 0.98);
    shieldPath.close();

    // 2. Drop Shadow
    final shadowPaint = Paint()
      ..isAntiAlias = true
      ..color = Colors.black.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawPath(shieldPath.shift(const Offset(0, 3)), shadowPaint);

    // 3. Ambient Glow
    if (showGlow) {
      final glowPaint = Paint()
        ..isAntiAlias = true
        ..color = _getTierGlowColor(tier).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      canvas.drawPath(shieldPath, glowPaint);
    }

    // 4. Base Metallic Gradient Body
    final bodyGradient = _getTierGradient(tier);
    final bodyPaint = Paint()
      ..isAntiAlias = true
      ..shader = bodyGradient.createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(shieldPath, bodyPaint);

    // Clip to shield for inner heraldic symbols
    canvas.save();
    canvas.clipPath(shieldPath);

    // 5. Left/Right Chiaroscuro Metallic Depth
    final shadowHalf = Path()
      ..moveTo(w * 0.5, h * 0.02)
      ..lineTo(w * 0.92, h * 0.12)
      ..cubicTo(w * 0.95, h * 0.45, w * 0.85, h * 0.82, w * 0.5, h * 0.98)
      ..close();
    final darkShadePaint = Paint()
      ..isAntiAlias = true
      ..color = Colors.black.withValues(alpha: 0.22);
    canvas.drawPath(shadowHalf, darkShadePaint);

    // 6. Inner Bevel Border
    final innerPath = Path();
    innerPath.moveTo(w * 0.5, h * 0.90);
    innerPath.cubicTo(w * 0.20, h * 0.76, w * 0.14, h * 0.42, w * 0.16, h * 0.18);
    innerPath.lineTo(w * 0.5, h * 0.10);
    innerPath.lineTo(w * 0.84, h * 0.18);
    innerPath.cubicTo(w * 0.86, h * 0.42, w * 0.80, h * 0.76, w * 0.5, h * 0.90);
    innerPath.close();

    final innerBorderPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.45);
    canvas.drawPath(innerPath, innerBorderPaint);

    // 7. Center Emblem
    _drawTierEmblem(canvas, w, h, tier);

    // 8. Top Specular Gloss
    final glossPath = Path();
    glossPath.moveTo(w * 0.16, h * 0.18);
    glossPath.lineTo(w * 0.5, h * 0.10);
    glossPath.lineTo(w * 0.5, h * 0.45);
    glossPath.lineTo(w * 0.18, h * 0.42);
    glossPath.close();

    final glossPaint = Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.50),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(glossPath, glossPaint);

    canvas.restore();

    // 9. Outer Rim Stroke
    final rimPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _getTierRimColor(tier);
    canvas.drawPath(shieldPath, rimPaint);
  }

  Color _getTierGlowColor(LeagueTier tier) {
    switch (tier) {
      case LeagueTier.bronze:
        return const Color(0xFFCD7F32);
      case LeagueTier.silver:
        return const Color(0xFFE2E8F0);
      case LeagueTier.gold:
        return const Color(0xFFFBBF24);
      case LeagueTier.diamond:
        return const Color(0xFF00E5FF);
      case LeagueTier.master:
        return const Color(0xFFA855F7);
    }
  }

  Color _getTierRimColor(LeagueTier tier) {
    switch (tier) {
      case LeagueTier.bronze:
        return const Color(0xFFFFB74D);
      case LeagueTier.silver:
        return Colors.white;
      case LeagueTier.gold:
        return const Color(0xFFFEF08A);
      case LeagueTier.diamond:
        return const Color(0xFFE0F7FA);
      case LeagueTier.master:
        return const Color(0xFFF3E8FF);
    }
  }

  Gradient _getTierGradient(LeagueTier tier) {
    switch (tier) {
      case LeagueTier.bronze:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD97706),
            Color(0xFF92400E),
            Color(0xFF451A03),
          ],
        );
      case LeagueTier.silver:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF1F5F9),
            Color(0xFF94A3B8),
            Color(0xFF334155),
          ],
        );
      case LeagueTier.gold:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDE047),
            Color(0xFFD97706),
            Color(0xFF78350F),
          ],
        );
      case LeagueTier.diamond:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF67E8F9),
            Color(0xFF0284C7),
            Color(0xFF0C4A6E),
          ],
        );
      case LeagueTier.master:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE879F9),
            Color(0xFF9333EA),
            Color(0xFF3B0764),
          ],
        );
    }
  }

  void _drawTierEmblem(Canvas canvas, double w, double h, LeagueTier tier) {
    final center = Offset(w * 0.5, h * 0.50);
    final emblemPaint = Paint()
      ..isAntiAlias = true
      ..color = Colors.white.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;

    switch (tier) {
      case LeagueTier.bronze:
        // Roman Numerals I / Torch
        final p = Path()
          ..moveTo(center.dx - 3, center.dy - 8)
          ..lineTo(center.dx + 3, center.dy - 8)
          ..lineTo(center.dx + 3, center.dy + 8)
          ..lineTo(center.dx - 3, center.dy + 8)
          ..close();
        canvas.drawPath(p, emblemPaint);
        break;

      case LeagueTier.silver:
        // Silver Chevron Wings
        final p = Path()
          ..moveTo(center.dx, center.dy - 8)
          ..lineTo(center.dx + 10, center.dy + 2)
          ..lineTo(center.dx + 6, center.dy + 6)
          ..lineTo(center.dx, center.dy)
          ..lineTo(center.dx - 6, center.dy + 6)
          ..lineTo(center.dx - 10, center.dy + 2)
          ..close();
        canvas.drawPath(p, emblemPaint);
        break;

      case LeagueTier.gold:
        // Royal 3-Peak Crown
        final p = Path()
          ..moveTo(center.dx - 10, center.dy + 7)
          ..lineTo(center.dx + 10, center.dy + 7)
          ..lineTo(center.dx + 11, center.dy - 3)
          ..lineTo(center.dx + 5, center.dy + 1)
          ..lineTo(center.dx, center.dy - 8)
          ..lineTo(center.dx - 5, center.dy + 1)
          ..lineTo(center.dx - 11, center.dy - 3)
          ..close();
        canvas.drawPath(p, emblemPaint);
        break;

      case LeagueTier.diamond:
        // 8-Facet Prismatic Diamond
        final p = Path()
          ..moveTo(center.dx, center.dy - 10)
          ..lineTo(center.dx + 9, center.dy - 2)
          ..lineTo(center.dx, center.dy + 10)
          ..lineTo(center.dx - 9, center.dy - 2)
          ..close();
        canvas.drawPath(p, emblemPaint);
        break;

      case LeagueTier.master:
        // Archon Star Halo & Cosmic Dragon Eye
        final p = Path()
          ..moveTo(center.dx, center.dy - 12)
          ..lineTo(center.dx + 3, center.dy - 3)
          ..lineTo(center.dx + 12, center.dy)
          ..lineTo(center.dx + 3, center.dy + 3)
          ..lineTo(center.dx, center.dy + 12)
          ..lineTo(center.dx - 3, center.dy + 3)
          ..lineTo(center.dx - 12, center.dy)
          ..lineTo(center.dx - 3, center.dy - 3)
          ..close();
        canvas.drawPath(p, emblemPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _LeagueCrestPainter oldDelegate) =>
      oldDelegate.tier != tier || oldDelegate.showGlow != showGlow;
}
