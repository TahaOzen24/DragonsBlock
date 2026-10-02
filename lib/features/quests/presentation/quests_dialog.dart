import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/audio/procedural_audio.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/settings/settings_dialog.dart';
import '../../../core/theme/game_theme.dart';
import '../services/quest_manager.dart';
import '../../game/presentation/painters/stat_bar_vector_icons.dart';

class QuestsDialog extends StatefulWidget {
  const QuestsDialog({super.key});

  @override
  State<QuestsDialog> createState() => _QuestsDialogState();
}

class _QuestsDialogState extends State<QuestsDialog> {
  final QuestManager _questManager = QuestManager.instance;

  @override
  void initState() {
    super.initState();
    _questManager.addListener(_onUpdated);
  }

  @override
  void dispose() {
    _questManager.removeListener(_onUpdated);
    super.dispose();
  }

  void _onUpdated() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.82),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: GameTheme.bgDark.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: GameTheme.neonCyan.withValues(alpha: 0.5), width: 1.5),
          boxShadow: GameTheme.cyanGlow(blur: 24, spread: 2),
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
                      Image.asset('assets/images/ui/icon_tasks.png', width: 26, height: 26, fit: BoxFit.contain, filterQuality: FilterQuality.high),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          AppStrings.dailyQuests,
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

            // Quests List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _questManager.quests.length,
                itemBuilder: (context, index) {
                  final quest = _questManager.quests[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GameTheme.bgSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: quest.isCompleted && !quest.isClaimed
                            ? GameTheme.goldAccent
                            : GameTheme.gridBorder,
                        width: quest.isCompleted && !quest.isClaimed ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(quest.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(quest.title,
                                  style: GameTheme.labelBold.copyWith(fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(quest.description,
                                  style: GameTheme.bodyMedium.copyWith(fontSize: 10)),
                              const SizedBox(height: 6),
                              // Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: quest.progressRatio,
                                  backgroundColor: GameTheme.gridBorder,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    quest.isCompleted
                                        ? GameTheme.emeraldGreen
                                        : GameTheme.neonCyan,
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (quest.isClaimed)
                          Text(
                            AppStrings.claimed,
                            style: const TextStyle(
                                color: GameTheme.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          )
                        else if (quest.isCompleted)
                          ElevatedButton(
                            onPressed: () async {
                              AppHaptics.reward();
                              await _questManager.claimReward(quest);
                              ProceduralAudio.instance.playQuestComplete();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GameTheme.goldAccent,
                              foregroundColor: Colors.black,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const VectorCoinIcon(size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${quest.rewardShards}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ],
                                ),
                                if (quest.rewardXp > 0)
                                  Text(
                                    '+${quest.rewardXp} XP',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9,
                                      color: Color(0xFF5D4037),
                                    ),
                                  ),
                              ],
                            ),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(
                                  begin: const Offset(1, 1),
                                  end: const Offset(1.05, 1.05))
                        else
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${quest.currentValue}/${quest.targetValue}',
                                style: GameTheme.bodyMedium.copyWith(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const VectorCoinIcon(size: 10),
                                  const SizedBox(width: 2),
                                  Text(
                                    '+${quest.rewardShards}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: GameTheme.goldAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (quest.rewardXp > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${quest.rewardXp}XP',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: GameTheme.neonCyan,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
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
