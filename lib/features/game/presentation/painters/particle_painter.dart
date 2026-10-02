import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/particles/particle_system.dart';

class ParticlePainter extends CustomPainter {
  final ParticleSystem particleSystem;

  ParticlePainter({required this.particleSystem, super.repaint});

  @override
  void paint(Canvas canvas, Size size) {
    // Flash overlays (full-canvas tint)
    for (final flash in particleSystem.flashes) {
      final paint = Paint()..color = flash.color.withValues(alpha: flash.color.a * flash.life);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }

    // Shockwave rings (Soft fluid ripples)
    for (final wave in particleSystem.shockwaves) {
      final alpha = (wave.life * wave.life).clamp(0.0, 1.0);
      if (wave.isSoft) {
        // Outer soft ambient glow ring (Zero-cost alpha layer, no MaskFilter.blur)
        final glowPaint = Paint()
          ..color = wave.color.withValues(alpha: (alpha * 0.22).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = wave.strokeWidth * 2.4;
        canvas.drawCircle(Offset(wave.x, wave.y), wave.radius, glowPaint);

        // Crisp inner fluid ring
        final corePaint = Paint()
          ..color = Color.lerp(wave.color, Colors.white, 0.45)!.withValues(alpha: (alpha * 0.85).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = wave.strokeWidth;
        canvas.drawCircle(Offset(wave.x, wave.y), wave.radius, corePaint);
      } else {
        final paint = Paint()
          ..color = wave.color.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = wave.strokeWidth;
        canvas.drawCircle(Offset(wave.x, wave.y), wave.radius, paint);
      }
    }

    // Particles
    for (final p in particleSystem.particles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: alpha);

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      switch (p.shape) {
        case ParticleShape.circle:
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
          break;

        case ParticleShape.fluidOrb:
          final double r = p.size / 2;
          // 1. Ethereal outer glow halo (Zero-cost dual circle, 120 FPS without shader stalls)
          final haloPaint = Paint()
            ..color = p.color.withValues(alpha: (alpha * 0.20).clamp(0.0, 1.0));
          canvas.drawCircle(Offset.zero, r * 1.5, haloPaint);

          final glowPaint = Paint()
            ..color = p.color.withValues(alpha: (alpha * 0.45).clamp(0.0, 1.0));
          canvas.drawCircle(Offset.zero, r * 1.15, glowPaint);

          // 2. Translucent liquid body
          final bodyPaint = Paint()
            ..color = p.color.withValues(alpha: (alpha * 0.88).clamp(0.0, 1.0));
          canvas.drawCircle(Offset.zero, r * 0.8, bodyPaint);

          // 3. Hot liquid center glint
          final corePaint = Paint()
            ..color = (p.secondaryColor ?? Colors.white).withValues(alpha: alpha);
          canvas.drawCircle(Offset(-r * 0.2, -r * 0.2), r * 0.35, corePaint);
          break;

        case ParticleShape.lightRay:
          final double length = p.size * 2.6;
          final rayPaint = Paint()
            ..color = p.color.withValues(alpha: (alpha * 0.75).clamp(0.0, 1.0))
            ..strokeWidth = p.size * 0.35
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(Offset(-length / 2, 0), Offset(length / 2, 0), rayPaint);
          final coreRay = Paint()
            ..color = (p.secondaryColor ?? Colors.white).withValues(alpha: alpha)
            ..strokeWidth = p.size * 0.15
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(Offset(-length * 0.35, 0), Offset(length * 0.35, 0), coreRay);
          break;

        case ParticleShape.softPetal:
          final double s = p.size;
          final petalPath = Path()
            ..moveTo(0, -s * 0.6)
            ..quadraticBezierTo(s * 0.5, 0, 0, s * 0.6)
            ..quadraticBezierTo(-s * 0.5, 0, 0, -s * 0.6)
            ..close();
          final petalPaint = Paint()
            ..color = p.color.withValues(alpha: (alpha * 0.85).clamp(0.0, 1.0));
          canvas.drawPath(petalPath, petalPaint);
          break;

        case ParticleShape.square:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
              Radius.circular(p.size * 0.2),
            ),
            paint,
          );
          break;

        case ParticleShape.star:
          _drawStar(canvas, p.size, paint);
          break;

        case ParticleShape.sparkle:
          _drawSparkle(canvas, p.size, paint);
          break;

        case ParticleShape.shatterShard:
          final path = Path();
          final pts = p.polyPoints;
          if (pts != null && pts.isNotEmpty) {
            path.moveTo(pts[0].dx, pts[0].dy);
            for (int i = 1; i < pts.length; i++) {
              path.lineTo(pts[i].dx, pts[i].dy);
            }
            path.close();
          } else {
            path.addRRect(RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
              Radius.circular(p.size * 0.2),
            ));
          }
          // Crystal base fill
          canvas.drawPath(path, paint);
          // Glossy edge highlight
          final borderPaint = Paint()
            ..color = (p.secondaryColor ?? Colors.white).withValues(alpha: alpha * 0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3;
          canvas.drawPath(path, borderPaint);
          break;

        case ParticleShape.glassTriangle:
          final h = p.size;
          final path = Path()
            ..moveTo(0, -h / 2)
            ..lineTo(h / 2, h / 2)
            ..lineTo(-h / 2, h / 2)
            ..close();
          canvas.drawPath(path, paint);
          final borderPaint = Paint()
            ..color = (p.secondaryColor ?? Colors.white).withValues(alpha: alpha * 0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2;
          canvas.drawPath(path, borderPaint);
          break;
      }

      canvas.restore();
    }

    // Floating texts: Distinct arcade combo banners & luminous flying scores
    for (final ft in particleSystem.floatingTexts) {
      final alpha = ft.life.clamp(0.0, 1.0);
      final isComboBanner = ft.targetX == null;

      final textPainter = TextPainter(
        text: TextSpan(
          text: ft.text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: alpha),
            fontSize: ft.fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: isComboBanner ? 1.4 : 0.6,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: (alpha * 0.90).clamp(0.0, 1.0)),
                offset: const Offset(0.0, 2.0),
                blurRadius: 4,
              ),
              if (isComboBanner)
                Shadow(
                  color: ft.color.withValues(alpha: (alpha * 0.85).clamp(0.0, 1.0)),
                  offset: Offset.zero,
                  blurRadius: 14,
                ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(ft.x, ft.y);
      canvas.scale(ft.scale, ft.scale);

      final badgeW = textPainter.width + (isComboBanner ? 24.0 : 14.0);
      final badgeH = textPainter.height + (isComboBanner ? 10.0 : 5.0);
      final badgeRect = Rect.fromCenter(center: Offset.zero, width: badgeW, height: badgeH);
      final badgeRRect = RRect.fromRectAndRadius(badgeRect, Radius.circular(badgeH * 0.5));

      // 1. Deep 3D Drop Shadow
      final shadowPaint = Paint()..color = Colors.black.withValues(alpha: (alpha * 0.45).clamp(0.0, 1.0));
      canvas.drawRRect(badgeRRect.shift(const Offset(0, 3.0)), shadowPaint);

      // 2. Vibrant Jewel Core Gradient
      final coreGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isComboBanner
            ? [
                Color.lerp(Colors.white, ft.color, 0.25)!.withValues(alpha: (alpha * 0.95).clamp(0.0, 1.0)),
                ft.color.withValues(alpha: (alpha * 0.92).clamp(0.0, 1.0)),
                Color.lerp(ft.color, Colors.black, 0.40)!.withValues(alpha: (alpha * 0.92).clamp(0.0, 1.0)),
              ]
            : [
                Color.lerp(ft.color, const Color(0xFF0F172A), 0.55)!.withValues(alpha: (alpha * 0.92).clamp(0.0, 1.0)),
                const Color(0xFF020617).withValues(alpha: (alpha * 0.92).clamp(0.0, 1.0)),
              ],
        stops: isComboBanner ? const [0.0, 0.45, 1.0] : const [0.0, 1.0],
      );
      canvas.drawRRect(badgeRRect, Paint()..shader = coreGradient.createShader(badgeRect));

      // 3. Glowing Outer Rim Border
      final rimPaint = Paint()
        ..color = isComboBanner
            ? Colors.white.withValues(alpha: (alpha * 0.90).clamp(0.0, 1.0))
            : ft.color.withValues(alpha: (alpha * 0.85).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = isComboBanner ? 1.8 : 1.0;
      canvas.drawRRect(badgeRRect, rimPaint);

      // 4. Glossy Top Specular Highlight
      final topHlRect = Rect.fromLTWH(
        badgeRect.left + 5,
        badgeRect.top + 2.0,
        badgeW - 10,
        badgeH * 0.38,
      );
      final topHlPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: (alpha * 0.55).clamp(0.0, 1.0)),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(topHlRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(topHlRect, Radius.circular(topHlRect.height * 0.5)),
        topHlPaint,
      );

      // 5. Centered Typography
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    const int points = 5;
    final outerR = size / 2;
    final innerR = outerR * 0.45;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final r = i.isEven ? outerR : innerR;
      final x = cos(angle) * r;
      final y = sin(angle) * r;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, double size, Paint paint) {
    // 4-pointed cross / diamond sparkle
    final r = size / 2;
    final thin = r * 0.2;
    final path = Path()
      ..moveTo(0, -r)
      ..lineTo(thin, -thin)
      ..lineTo(r, 0)
      ..lineTo(thin, thin)
      ..lineTo(0, r)
      ..lineTo(-thin, thin)
      ..lineTo(-r, 0)
      ..lineTo(-thin, -thin)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
