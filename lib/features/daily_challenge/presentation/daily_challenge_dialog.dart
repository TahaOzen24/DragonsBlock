import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';
import '../../../core/audio/procedural_audio.dart';
import '../../../core/settings/settings_dialog.dart';
import '../models/challenge_modifier.dart';
import '../services/daily_challenge_manager.dart';
import '../../game/presentation/screens/game_screen.dart';

class DailyChallengeDialog extends StatefulWidget {
  const DailyChallengeDialog({super.key});

  @override
  State<DailyChallengeDialog> createState() => _DailyChallengeDialogState();
}

class _DailyChallengeDialogState extends State<DailyChallengeDialog> {
  @override
  void initState() {
    super.initState();
    DailyChallengeManager.instance.loadClaimedMedals();
  }

  @override
  Widget build(BuildContext context) {
    final modifier = ChallengeModifier.getTodayModifier();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GameTheme.bgDark.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: modifier.themeColor.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
                color: modifier.themeColor.withValues(alpha: 0.3),
                blurRadius: 28,
                spreadRadius: 2),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            AppStrings.dailyChallengeTitle,
                            style: GameTheme.titleLarge.copyWith(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          AppHaptics.light();
                          ProceduralAudio.instance.playDialogPop();
                          showDialog(
                            context: context,
                            builder: (_) => const SettingsDialog(),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: GameTheme.bgDarkest,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1.0),
                          ),
                          child: const Center(
                            child: Icon(Icons.settings_rounded, color: Colors.white70, size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: GameTheme.bgDarkest,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1.0),
                          ),
                          child: const Center(
                            child: Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Today's Modifier Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: modifier.themeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: modifier.themeColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: GameTheme.bgDark,
                        shape: BoxShape.circle,
                        border: Border.all(color: modifier.themeColor),
                      ),
                      alignment: Alignment.center,
                      child: Text(modifier.icon, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  modifier.title.toUpperCase(),
                                  style: TextStyle(
                                    color: modifier.themeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 0.8,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: modifier.themeColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  AppStrings.mutator,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(modifier.subtitle,
                              style: GameTheme.bodyMedium.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Medal Thresholds
              AnimatedBuilder(
                animation: DailyChallengeManager.instance,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMedalBadge('bronze', '🥉', AppStrings.bronze, '3K', '+100 🪙'),
                      _buildMedalBadge('silver', '🥈', AppStrings.silver, '8K', '+250 🪙'),
                      _buildMedalBadge('gold', '🥇', AppStrings.gold, '15K', '+500 🪙'),
                      _buildMedalBadge('diamond', '💎', AppStrings.diamond, '25K', '+1K 🪙'),
                    ],
                  );
                },
              ),

              const SizedBox(height: 18),

              // Start Challenge Button
              ElevatedButton(
                onPressed: () {
                  AppHaptics.selection();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => GameScreen(dailyModifier: modifier)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: modifier.themeColor,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      '${AppStrings.startColon} ${modifier.title.toUpperCase()}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ).animate().shimmer(duration: 1400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedalBadge(String id, String icon, String label, String target, String reward) {
    final isClaimed = DailyChallengeManager.instance.isMedalClaimed(id);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: isClaimed
          ? BoxDecoration(
              color: GameTheme.emeraldGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GameTheme.emeraldGreen.withValues(alpha: 0.5)),
            )
          : null,
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
                fontSize: 9, fontWeight: FontWeight.bold, color: GameTheme.textMuted),
          ),
          Text(
            target,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 1),
          if (isClaimed)
            const Text(
              '✓ ALINDI',
              style: TextStyle(
                  fontSize: 8, fontWeight: FontWeight.bold, color: GameTheme.emeraldGreen),
            )
          else
            Text(
              reward,
              style: const TextStyle(fontSize: 9, color: GameTheme.neonCyan),
            ),
        ],
      ),
    );
  }
}
