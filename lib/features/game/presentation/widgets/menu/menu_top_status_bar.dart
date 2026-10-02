import 'package:flutter/material.dart';
import '../../../../../core/audio/procedural_audio.dart';
import '../../../../../core/haptics/haptic_service.dart';
import '../../../../quests/presentation/quests_dialog.dart';
import '../../../../quests/services/quest_manager.dart';
import '../game_top_stat_bars.dart';

class MenuTopStatusBar extends StatelessWidget {
  final int highScore;
  final int goldCoins;
  final VoidCallback onGoldCoinsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback? onAfterQuest;

  const MenuTopStatusBar({
    super.key,
    required this.highScore,
    required this.goldCoins,
    required this.onGoldCoinsTap,
    required this.onSettingsTap,
    this.onAfterQuest,
  });

  @override
  Widget build(BuildContext context) {
    final claimable = QuestManager.instance.claimableCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 380;
          final barHeight = isNarrow ? 40.0 : 44.0;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: HeartLivesBar(height: barHeight),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: MaxScoreBar(highScore: highScore, height: barHeight),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: GoldCoinsBar(
                    goldCoins: goldCoins,
                    onTap: onGoldCoinsTap,
                    height: barHeight,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _RoundAction(
                size: barHeight,
                borderColor: const Color(0xFFFBBF24),
                badge: claimable > 0 ? '$claimable' : null,
                onTap: () {
                  AppHaptics.light();
                  ProceduralAudio.instance.playDialogPop();
                  showDialog(
                    context: context,
                    builder: (_) => const QuestsDialog(),
                  ).then((_) => onAfterQuest?.call());
                },
                child: Image.asset(
                  'assets/images/ui/icon_tasks.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(width: 4),
              _RoundAction(
                size: barHeight,
                borderColor: const Color(0xFF38BDF8),
                onTap: onSettingsTap,
                child: const Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final double size;
  final Color borderColor;
  final VoidCallback onTap;
  final Widget child;
  final String? badge;

  const _RoundAction({
    required this.size,
    required this.borderColor,
    required this.onTap,
    required this.child,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF0C1322).withValues(alpha: 0.95),
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor.withValues(alpha: 0.7),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.22),
                  blurRadius: 10,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: child,
          ),
          if (badge != null)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
