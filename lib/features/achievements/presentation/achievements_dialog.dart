import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/theme/game_theme.dart';
import '../services/achievement_manager.dart';

class AchievementsDialog extends StatefulWidget {
  const AchievementsDialog({super.key});

  @override
  State<AchievementsDialog> createState() => _AchievementsDialogState();
}

class _AchievementsDialogState extends State<AchievementsDialog> {
  final AchievementManager _manager = AchievementManager.instance;

  @override
  void initState() {
    super.initState();
    _manager.loadAchievements();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTr = LocaleManager.instance.isTurkish;
    final achievements = _manager.achievements;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GameTheme.bgDark.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: GameTheme.goldAccent.withValues(alpha: 0.7), width: 1.8),
          boxShadow: GameTheme.goldGlow(blur: 28, spread: 2),
        ),
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
                      const Text('🎖️', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          AppStrings.achievementsCodex,
                          style: GameTheme.titleLarge.copyWith(
                            fontSize: 16,
                            color: GameTheme.goldAccent,
                            letterSpacing: 1.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: GameTheme.bgSurface,
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
            const SizedBox(height: 12),

            // Scrollable List of Achievements
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: achievements.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final ach = achievements[index];
                  final isDone = ach.isCompleted;
                  final isClaimed = ach.isClaimed;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDone && !isClaimed
                          ? ach.themeColor.withValues(alpha: 0.12)
                          : GameTheme.bgSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDone && !isClaimed
                            ? ach.themeColor
                            : (isClaimed
                                ? GameTheme.emeraldGreen.withValues(alpha: 0.4)
                                : GameTheme.gridBorder),
                        width: isDone && !isClaimed ? 1.5 : 1.0,
                      ),
                      boxShadow: isDone && !isClaimed ? [BoxShadow(color: ach.themeColor.withValues(alpha: 0.25), blurRadius: 8)] : null,
                    ),
                    child: Row(
                      children: [
                        // Icon Container
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: GameTheme.bgDarkest,
                            border: Border.all(
                              color: ach.themeColor.withValues(alpha: 0.6),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isClaimed ? '✅' : ach.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Text & Progress Bar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ach.getTitle(isTr),
                                style: TextStyle(
                                  color: isClaimed ? GameTheme.textMuted : Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ach.getDesc(isTr),
                                style: const TextStyle(
                                  color: GameTheme.textMuted,
                                  fontSize: 10.5,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ach.progressRatio,
                                  backgroundColor: GameTheme.bgDarkest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDone ? GameTheme.emeraldGreen : ach.themeColor,
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Claim or Status Button
                        if (isClaimed) ...[
                          Text(
                            AppStrings.claimedMark,
                            style: TextStyle(
                              color: GameTheme.emeraldGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else if (isDone) ...[
                          ElevatedButton(
                            onPressed: () async {
                              final success = await _manager.claimReward(ach.id);
                              if (success) {
                                AppHaptics.reward();
                                ProceduralAudio.instance.playRewardClaim();
                                setState(() {});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ach.themeColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              '+${ach.rewardShards} 🪙',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                            ),
                          ).animate().shimmer(duration: 1000.ms),
                        ] else ...[
                          Text(
                            '${ach.currentValue}/${ach.targetValue}',
                            style: const TextStyle(
                              color: GameTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
