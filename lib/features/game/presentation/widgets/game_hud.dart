import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../dragon/models/dragon.dart';
import '../../models/block_skin_style.dart';
import 'game_top_stat_bars.dart';

/// In-Game HUD for DragonsBlock
class GameHUD extends StatelessWidget {
  final int score;
  final int highScore;
  final int combo;
  final int goldShards;
  final BlockSkinStyle? activeSkinStyle;
  final VoidCallback? onStyleTap;
  final VoidCallback onPauseTap;

  // Dragon Companion parameters
  final DragonDefinition? activeDragon;
  final double dragonChargeProgress;
  final bool isDragonPowerReady;
  final VoidCallback? onDragonPowerTap;

  const GameHUD({
    super.key,
    required this.score,
    required this.highScore,
    required this.combo,
    required this.goldShards,
    this.activeSkinStyle,
    this.onStyleTap,
    required this.onPauseTap,
    this.activeDragon,
    this.dragonChargeProgress = 0.0,
    this.isDragonPowerReady = false,
    this.onDragonPowerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main HUD Column
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Status Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: MaxScoreBar(highScore: highScore, height: 42),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GoldCoinsBar(goldCoins: goldShards, showPlusBadge: false, height: 42),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onPauseTap,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF090E1A).withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.70),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.30),
                                blurRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.pause_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Center Score
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: score.toDouble(), end: score.toDouble()),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) {
                  return Text(
                    '${val.round()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                      shadows: [
                        Shadow(color: Color(0xFF0284C7), blurRadius: 18, offset: Offset(0, 2)),
                        Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 3)),
                      ],
                    ),
                  );
                },
              ).animate(key: ValueKey(score)).scale(
                    begin: const Offset(1.08, 1.08),
                    end: const Offset(1.0, 1.0),
                    duration: 180.ms,
                    curve: Curves.easeOutBack,
                  ),

              // Combo Badge
              if (combo > 1)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3.5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEA580C), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDE047), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEA580C).withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        'KOMBO x$combo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1))],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 150.ms).scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
            ],
          ),
        ),

        if (activeDragon != null)
          Positioned(
            right: 14,
            top: 50,
            child: GestureDetector(
              onTap: isDragonPowerReady ? onDragonPowerTap : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDragonPowerReady
                        ? [activeDragon!.themeColor, Colors.white.withValues(alpha: 0.85)]
                        : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                  ),
                  border: Border.all(
                    color: isDragonPowerReady
                        ? activeDragon!.themeColor
                        : Colors.white.withValues(alpha: 0.18),
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (isDragonPowerReady)
                      BoxShadow(
                        color: activeDragon!.themeColor.withValues(alpha: 0.65),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: dragonChargeProgress.clamp(0.0, 1.0),
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDragonPowerReady ? Colors.white : activeDragon!.themeColor,
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                    ),
                    Text(
                      isDragonPowerReady ? '⚡' : '${(dragonChargeProgress * 100).round()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDragonPowerReady ? 22 : 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
