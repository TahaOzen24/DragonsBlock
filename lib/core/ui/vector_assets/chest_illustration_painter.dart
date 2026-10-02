import 'package:flutter/material.dart';

enum ChestTier {
  bronze,
  silver,
  gold,
  astral,
}

/// 📦 Pure GPU-Accelerated 3D RPG Treasure Chest Vector Painter.
/// Renders high-fidelity treasure chests with beveled wooden planks, golden corner brackets,
/// keyholes, specular rivets, and glowing interior luminescence.
class VectorTreasureChest extends StatelessWidget {
  final ChestTier tier;
  final double size;
  final bool isOpened;

  const VectorTreasureChest({
    super.key,
    this.tier = ChestTier.gold,
    this.size = 64.0,
    this.isOpened = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.88),
      painter: _ChestIllustrationPainter(tier: tier, isOpened: isOpened),
    );
  }
}

class _ChestIllustrationPainter extends CustomPainter {
  final ChestTier tier;
  final bool isOpened;

  _ChestIllustrationPainter({required this.tier, required this.isOpened});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Drop Shadow
    final shadowPaint = Paint()
      ..isAntiAlias = true
      ..color = Colors.black.withValues(alpha: 0.50)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.90), width: w * 0.85, height: h * 0.22),
      shadowPaint,
    );

    // 2. Ambient Tier Glow
    final glowPaint = Paint()
      ..isAntiAlias = true
      ..color = _getTierGlow(tier).withValues(alpha: 0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8), glowPaint);

    // 3. Lower Chest Body Box
    final bodyRect = Rect.fromLTWH(w * 0.12, h * 0.38, w * 0.76, h * 0.50);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, const Radius.circular(6.0));

    final woodGradient = _getWoodGradient(tier);
    final woodPaint = Paint()
      ..isAntiAlias = true
      ..shader = woodGradient.createShader(bodyRect);
    canvas.drawRRect(bodyRRect, woodPaint);

    // 4. Chest Lid (Dome Arc)
    final lidPath = Path();
    if (!isOpened) {
      lidPath.moveTo(w * 0.08, h * 0.40);
      lidPath.lineTo(w * 0.92, h * 0.40);
      lidPath.cubicTo(w * 0.94, h * 0.12, w * 0.06, h * 0.12, w * 0.08, h * 0.40);
      lidPath.close();
    } else {
      // Opened Lid angled up
      lidPath.moveTo(w * 0.08, h * 0.28);
      lidPath.lineTo(w * 0.92, h * 0.28);
      lidPath.cubicTo(w * 0.94, -h * 0.05, w * 0.06, -h * 0.05, w * 0.08, h * 0.28);
      lidPath.close();
    }

    final lidPaint = Paint()
      ..isAntiAlias = true
      ..shader = woodGradient.createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(lidPath, lidPaint);

    // 5. Metal Trim Bands & Brackets
    final metalGradient = _getMetalGradient(tier);
    final metalPaint = Paint()
      ..isAntiAlias = true
      ..shader = metalGradient.createShader(Rect.fromLTWH(0, 0, w, h));

    // Left Band
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.24, h * 0.20, w * 0.10, h * 0.68), const Radius.circular(3)),
      metalPaint,
    );
    // Right Band
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.66, h * 0.20, w * 0.10, h * 0.68), const Radius.circular(3)),
      metalPaint,
    );

    // Lid Rim Band
    final rimRect = Rect.fromLTWH(w * 0.06, h * 0.34, w * 0.88, h * 0.08);
    canvas.drawRRect(RRect.fromRectAndRadius(rimRect, const Radius.circular(3)), metalPaint);

    // 6. Center Golden Lock Plate & Keyhole
    final lockRect = Rect.fromLTWH(w * 0.42, h * 0.32, w * 0.16, h * 0.20);
    final lockRRect = RRect.fromRectAndRadius(lockRect, const Radius.circular(4));
    final lockPaint = Paint()
      ..isAntiAlias = true
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFBEB), Color(0xFFF59E0B), Color(0xFF78350F)],
      ).createShader(lockRect);
    canvas.drawRRect(lockRRect, lockPaint);

    // Keyhole
    final keyholePaint = Paint()..color = const Color(0xFF1E0A02);
    canvas.drawCircle(Offset(w * 0.50, h * 0.40), w * 0.024, keyholePaint);
    final keyholeSlot = Path()
      ..moveTo(w * 0.485, h * 0.40)
      ..lineTo(w * 0.515, h * 0.40)
      ..lineTo(w * 0.525, h * 0.47)
      ..lineTo(w * 0.475, h * 0.47)
      ..close();
    canvas.drawPath(keyholeSlot, keyholePaint);

    // 7. Corner Rivet Jewels
    final rivetPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(Offset(w * 0.29, h * 0.26), 1.4, rivetPaint);
    canvas.drawCircle(Offset(w * 0.71, h * 0.26), 1.4, rivetPaint);
    canvas.drawCircle(Offset(w * 0.29, h * 0.76), 1.4, rivetPaint);
    canvas.drawCircle(Offset(w * 0.71, h * 0.76), 1.4, rivetPaint);
  }

  Color _getTierGlow(ChestTier tier) {
    switch (tier) {
      case ChestTier.bronze:
        return const Color(0xFFD97706);
      case ChestTier.silver:
        return const Color(0xFF38BDF8);
      case ChestTier.gold:
        return const Color(0xFFFBBF24);
      case ChestTier.astral:
        return const Color(0xFFA855F7);
    }
  }

  Gradient _getWoodGradient(ChestTier tier) {
    switch (tier) {
      case ChestTier.bronze:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9A3412), Color(0xFF7C2D12), Color(0xFF431407)],
        );
      case ChestTier.silver:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
        );
      case ChestTier.gold:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB45309), Color(0xFF92400E), Color(0xFF451A03)],
        );
      case ChestTier.astral:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6B21A8), Color(0xFF581C87), Color(0xFF2E1065)],
        );
    }
  }

  Gradient _getMetalGradient(ChestTier tier) {
    switch (tier) {
      case ChestTier.bronze:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDBA74), Color(0xFFEA580C), Color(0xFF7C2D12)],
        );
      case ChestTier.silver:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFCBD5E1), Color(0xFF64748B)],
        );
      case ChestTier.gold:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF08A), Color(0xFFF59E0B), Color(0xFF92400E)],
        );
      case ChestTier.astral:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF472B6), Color(0xFFC084FC), Color(0xFF4C1D95)],
        );
    }
  }

  @override
  bool shouldRepaint(covariant _ChestIllustrationPainter oldDelegate) =>
      oldDelegate.tier != tier || oldDelegate.isOpened != isOpened;
}
