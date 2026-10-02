import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/audio/procedural_audio.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';
import '../../../core/ui/game_toast.dart';
import '../services/daily_reward_manager.dart';
import '../../quests/presentation/quests_dialog.dart';
import '../../quests/services/quest_manager.dart';

class DailyRewardDialog extends StatefulWidget {
  const DailyRewardDialog({super.key});

  @override
  State<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<DailyRewardDialog> {
  final DailyRewardManager _manager = DailyRewardManager.instance;
  bool _claimed = false;

  @override
  Widget build(BuildContext context) {
    final currentDay = _manager.currentDay;
    final canClaim = _manager.canClaimToday && !_claimed;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GameTheme.bgDark.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: GameTheme.goldAccent.withValues(alpha: 0.6), width: 1.5),
            boxShadow: GameTheme.goldGlow(blur: 28, spread: 2),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset('assets/images/ui/icon_gift.png', width: 26, height: 26, fit: BoxFit.contain, filterQuality: FilterQuality.high),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              AppStrings.dailyRewards,
                              style: GameTheme.titleLarge.copyWith(
                                fontSize: 18,
                                color: GameTheme.goldAccent,
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
                const SizedBox(height: 4),
                Text(
                  AppStrings.dailyRewardsDesc,
                  style: GameTheme.bodyMedium.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 14),

                // 7 Days Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 7,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final reward = DailyRewardManager.schedule[index];
                    final isCurrent = day == currentDay;
                    final isPast = day < currentDay;
                    final isDay7 = day == 7;

                    return Container(
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? GameTheme.goldAccent.withValues(alpha: 0.15)
                            : (isPast
                                ? GameTheme.bgSurface.withValues(alpha: 0.4)
                                : GameTheme.bgSurface),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrent
                              ? GameTheme.goldAccent
                              : (isPast
                                  ? GameTheme.emeraldGreen.withValues(alpha: 0.5)
                                  : GameTheme.gridBorder),
                          width: isCurrent ? 2 : 1,
                        ),
                        boxShadow: isCurrent ? GameTheme.goldGlow(blur: 8) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${AppStrings.day} $day',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? GameTheme.goldAccent : GameTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isPast ? '✅' : reward.icon,
                            style: TextStyle(fontSize: isDay7 ? 20 : 16),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '+${reward.shards}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.white : GameTheme.neonCyan,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Claim Button
                ElevatedButton(
                  onPressed: canClaim
                      ? () async {
                          final success = await _manager.claimToday();
                          if (success) {
                            ProceduralAudio.instance.playRewardClaim();
                            setState(() {
                              _claimed = true;
                            });
                            if (context.mounted) {
                              GameToast.showGold(
                                context,
                                AppStrings.claimedDayReward(
                                    currentDay, DailyRewardManager.schedule[currentDay - 1].shards),
                                title: 'GÜNLÜK ÖDÜL',
                              );
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GameTheme.goldAccent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 6,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      canClaim
                          ? AppStrings.claimDailyReward
                          : (_claimed
                              ? AppStrings.claimedToday
                              : AppStrings.comeBackTomorrow),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ).animate(target: canClaim ? 1 : 0).shimmer(duration: 1200.ms),

                const SizedBox(height: 12),

                // Button to access Daily Quests
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(context: context, builder: (_) => const QuestsDialog());
                  },
                  icon: const Icon(Icons.assignment_turned_in_rounded, size: 18, color: Color(0xFF38BDF8)),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      QuestManager.instance.claimableCount > 0
                          ? 'GÜNLÜK GÖREVLER (${QuestManager.instance.claimableCount} Ödül Hazır!)'
                          : 'GÜNLÜK GÖREVLER',
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0284C7), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size(double.infinity, 42),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
