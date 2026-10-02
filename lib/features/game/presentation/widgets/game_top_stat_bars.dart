import 'package:flutter/material.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../leaderboard/presentation/leaderboard_dialog.dart';
import '../../../rewards/presentation/lives_refill_dialog.dart';
import '../../../rewards/services/lives_manager.dart';
import '../painters/stat_bar_vector_icons.dart';

/// 💖 1. Can Barı (Health / Lives Status Pill)
/// Large, touch-friendly, rendered with pure GPU vector heart.
class HeartLivesBar extends StatelessWidget {
  final VoidCallback? onTap;
  final bool showPlusBadge;
  final double height;

  const HeartLivesBar({
    super.key,
    this.onTap,
    this.showPlusBadge = true,
    this.height = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    final livesManager = LivesManager.instance;

    return AnimatedBuilder(
      animation: livesManager,
      builder: (context, _) {
        final lives = livesManager.currentLives;
        final isMax = livesManager.isFull;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              AppHaptics.light();
              ProceduralAudio.instance.playDialogPop();
              if (onTap != null) {
                onTap!();
              } else {
                showDialog(
                  context: context,
                  builder: (_) => const LivesRefillDialog(),
                );
              }
            },
            borderRadius: BorderRadius.circular(height / 2),
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1022).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(height / 2),
                border: Border.all(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.85),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF43F5E).withValues(alpha: 0.32),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.60),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const VectorHeartIcon(size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$lives',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  if (showPlusBadge && !isMax) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 19,
                      height: 19,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF10B981),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 👑 2. Max Puan Barı (High Score / Best Record Pill)
/// Large, touch-friendly, rendered with pure GPU vector imperial crown.
class MaxScoreBar extends StatelessWidget {
  final int highScore;
  final VoidCallback? onTap;
  final double height;

  const MaxScoreBar({
    super.key,
    required this.highScore,
    this.onTap,
    this.height = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.light();
          ProceduralAudio.instance.playDialogPop();
          if (onTap != null) {
            onTap!();
          } else {
            showDialog(
              context: context,
              builder: (_) => const LeaderboardDialog(),
            );
          }
        },
        borderRadius: BorderRadius.circular(height / 2),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1022).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.90),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.32),
                blurRadius: 12,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.60),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const VectorCrownIcon(size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$highScore',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🪙 3. Altın Barı (Gold Coins / Shards Pill)
/// Large, touch-friendly, rendered with pure GPU vector gold medallion.
class GoldCoinsBar extends StatelessWidget {
  final int goldCoins;
  final VoidCallback? onTap;
  final bool showPlusBadge;
  final double height;

  const GoldCoinsBar({
    super.key,
    required this.goldCoins,
    this.onTap,
    this.showPlusBadge = true,
    this.height = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.light();
          ProceduralAudio.instance.playDialogPop();
          if (onTap != null) onTap!();
        },
        borderRadius: BorderRadius.circular(height / 2),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1022).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(
              color: const Color(0xFFEAB308).withValues(alpha: 0.90),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEAB308).withValues(alpha: 0.30),
                blurRadius: 12,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.60),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const VectorCoinIcon(size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$goldCoins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              if (showPlusBadge) ...[
                const SizedBox(width: 8),
                Container(
                  width: 19,
                  height: 19,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD97706),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFD97706),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
