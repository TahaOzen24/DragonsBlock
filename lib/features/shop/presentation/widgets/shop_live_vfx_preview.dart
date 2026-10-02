import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/clear_fx_style.dart';

/// 💥 Live Animated Clear VFX Explosion Preview
/// Simulates real-time line clear block blasts (Nova explosion, Rainbow shards, Plasma laser, Cosmic vortex)
/// right inside the shop item card.
class ShopLiveVfxPreview extends StatefulWidget {
  final ClearFxStyle fxStyle;
  final double size;

  const ShopLiveVfxPreview({
    super.key,
    required this.fxStyle,
    this.size = 80.0,
  });

  @override
  State<ShopLiveVfxPreview> createState() => _ShopLiveVfxPreviewState();
}

class _ShopLiveVfxPreviewState extends State<ShopLiveVfxPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: const Color(0xFF060B1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.fxStyle.primaryColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _VfxBlastPainter(
                progress: _animController.value,
                fxStyle: widget.fxStyle,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VfxBlastPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final ClearFxStyle fxStyle;

  _VfxBlastPainter({required this.progress, required this.fxStyle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final maxRadius = size.width * 0.46;

    final primary = fxStyle.primaryColor;
    final secondary = fxStyle.secondaryColor;

    // 1. Shockwave Expanding Ring (Early phase: 0.0 to 0.7)
    if (progress < 0.75) {
      final ringNorm = (progress / 0.75).clamp(0.0, 1.0);
      final ringRadius = maxRadius * Curves.easeOutCubic.transform(ringNorm);
      final ringAlpha = (1.0 - ringNorm).clamp(0.0, 1.0);

      final ringPaint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = (3.0 * (1.0 - ringNorm)).clamp(0.5, 3.0)
        ..color = primary.withValues(alpha: ringAlpha * 0.85);

      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // 2. Central Core Flash (Peak at 0.15)
    final flashNorm = progress < 0.3 ? (progress / 0.3) : (1.0 - (progress - 0.3) / 0.7);
    final flashAlpha = Curves.easeInOut.transform(flashNorm.clamp(0.0, 1.0));
    final flashPaint = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: flashAlpha * 0.9),
          secondary.withValues(alpha: flashAlpha * 0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.6));
    canvas.drawCircle(center, maxRadius * 0.6, flashPaint);

    // 3. Radial Particle Sparks
    const particleCount = 8;
    for (int i = 0; i < particleCount; i++) {
      final angle = (i * 2 * math.pi / particleCount) + (progress * 0.4);
      final distanceNorm = Curves.easeOutQuad.transform(progress);
      final dist = maxRadius * 0.85 * distanceNorm;

      final pAlpha = (1.0 - progress).clamp(0.0, 1.0);
      final pColor = (i % 2 == 0) ? primary : secondary;

      final pOffset = Offset(
        center.dx + dist * math.cos(angle),
        center.dy + dist * math.sin(angle),
      );

      final sparkPaint = Paint()
        ..isAntiAlias = true
        ..color = pColor.withValues(alpha: pAlpha * 0.9)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pOffset, (2.8 * (1.0 - progress * 0.5)).clamp(1.0, 3.0), sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VfxBlastPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.fxStyle != fxStyle;
  }
}
