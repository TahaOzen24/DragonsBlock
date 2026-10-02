import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/game_theme.dart';
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🐉 High-Resolution Masterpiece App Icon & Glowing Dragon Crest
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD54F).withValues(alpha: 0.40),
                    blurRadius: 40,
                    spreadRadius: 6,
                  ),
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.30),
                    blurRadius: 65,
                    spreadRadius: 14,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.65, 0.65),
                  end: const Offset(1.0, 1.0),
                  duration: 750.ms,
                  curve: Curves.easeOutBack,
                )
                .then()
                .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.35)),

            const SizedBox(height: 32),

            // Title: DRAGONS
            Text(
              'DRAGONS',
              style: GameTheme.outfit(
                size: 34,
                weight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 10,
              ),
            ).animate().fadeIn(delay: 250.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 4),

            // Subtitle: BLOCK with Mythic Gold-Cyan Gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFFF97316), Color(0xFF38BDF8)],
              ).createShader(bounds),
              child: Text(
                'BLOCK',
                style: GameTheme.outfit(
                  size: 17,
                  weight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 60),

            // Loading indicator
            SizedBox(
              width: 100,
              height: 2,
              child: LinearProgressIndicator(
                backgroundColor: GameTheme.bgSurface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  GameTheme.neonCyan.withValues(alpha: 0.6),
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ).animate().fadeIn(delay: 700.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
