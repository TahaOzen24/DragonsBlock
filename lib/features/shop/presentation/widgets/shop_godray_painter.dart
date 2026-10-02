import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🌟 Rotating Magical Godray / Sunburst Background
/// Adds authentic AAA arcade depth behind chests, legendary items, and hero deals.
class ShopGodrayBackground extends StatefulWidget {
  final Color rayColor;
  final int rayCount;
  final double size;
  final double speed; // rotations per minute
  final Widget? child;

  const ShopGodrayBackground({
    super.key,
    this.rayColor = const Color(0xFFFBBF24),
    this.rayCount = 12,
    this.size = 180.0,
    this.speed = 10.0,
    this.child,
  });

  @override
  State<ShopGodrayBackground> createState() => _ShopGodrayBackgroundState();
}

class _ShopGodrayBackgroundState extends State<ShopGodrayBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final durationSecs = (60.0 / widget.speed).clamp(2.0, 30.0);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (durationSecs * 1000).toInt()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _GodrayPainter(
                    rayColor: widget.rayColor,
                    rayCount: widget.rayCount,
                  ),
                ),
              );
            },
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _GodrayPainter extends CustomPainter {
  final Color rayColor;
  final int rayCount;

  _GodrayPainter({required this.rayColor, required this.rayCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.5;
    final angleStep = (2 * math.pi) / rayCount;
    final rayWidthAngle = angleStep * 0.45;

    final paint = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        colors: [
          rayColor.withValues(alpha: 0.35),
          rayColor.withValues(alpha: 0.12),
          rayColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    for (int i = 0; i < rayCount; i++) {
      final startAngle = i * angleStep;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + radius * math.cos(startAngle),
          center.dy + radius * math.sin(startAngle),
        )
        ..lineTo(
          center.dx + radius * math.cos(startAngle + rayWidthAngle),
          center.dy + radius * math.sin(startAngle + rayWidthAngle),
        )
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GodrayPainter oldDelegate) {
    return oldDelegate.rayColor != rayColor || oldDelegate.rayCount != rayCount;
  }
}
