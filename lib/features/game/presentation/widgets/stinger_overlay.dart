import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Cinematic multi-line blast banner that flashes over the grid.
class StingerOverlay extends StatelessWidget {
  final String text;
  final Color color;

  const StingerOverlay({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.60), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 220.ms, curve: Curves.easeOut)
          .scale(
            begin: const Offset(0.92, 0.92),
            end: const Offset(1.0, 1.0),
            duration: 260.ms,
            curve: Curves.easeOutCubic,
          )
          .moveY(begin: 8, end: 0, duration: 260.ms, curve: Curves.easeOutCubic),
    );
  }
}
