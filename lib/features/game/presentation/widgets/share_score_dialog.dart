import 'package:flutter/material.dart';
import '../../../../core/haptics/haptic_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/theme/game_theme.dart';

class ShareScoreDialog extends StatelessWidget {
  final int score;
  final int highScore;
  final int linesCleared;
  final int comboStreak;
  final int shards;

  const ShareScoreDialog({
    super.key,
    required this.score,
    required this.highScore,
    required this.linesCleared,
    required this.comboStreak,
    required this.shards,
  });

  String _getRankTitle() {
    if (score >= 8000) {
      return AppStrings.rankGrandmaster;
    } else if (score >= 5000) {
      return AppStrings.rankMasterOfRunes;
    } else if (score >= 2500) {
      return AppStrings.rankMysticBlast;
    } else {
      return AppStrings.rankRunicApprentice;
    }
  }

  Color _getRankColor() {
    if (score >= 8000) return GameTheme.goldAccent;
    if (score >= 5000) return GameTheme.fireOrange;
    if (score >= 2500) return GameTheme.neonCyan;
    return Colors.tealAccent;
  }

  @override
  Widget build(BuildContext context) {
    final rankTitle = _getRankTitle();
    final rankColor = _getRankColor();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: GameTheme.bgDark.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: rankColor, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: rankColor.withValues(alpha: 0.35),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close Icon
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // Glowing Badge Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: rankColor, width: 2),
                    boxShadow: [
                      BoxShadow(color: rankColor.withValues(alpha: 0.5), blurRadius: 18),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.workspace_premium_rounded, color: rankColor, size: 34),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 10),

                // Rank Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: rankColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: rankColor.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    rankTitle,
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Big Score
                Text(
                  '$score',
                  style: GameTheme.scoreHuge.copyWith(fontSize: 44, color: Colors.white),
                ),
                Text(
                  AppStrings.totalScore,
                  style: const TextStyle(color: GameTheme.textMuted, fontSize: 11, letterSpacing: 2),
                ),
                const SizedBox(height: 16),

                // Stats Grid
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: GameTheme.bgSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: GameTheme.gridBorder),
                  ),
                  child: Column(
                    children: [
                      _buildStatLine('🏆 ${AppStrings.bestScoreStat}', '$highScore', GameTheme.goldAccent),
                      const Divider(color: GameTheme.gridBorder, height: 12),
                      _buildStatLine('⚡ ${AppStrings.linesClearedStat}', '$linesCleared', GameTheme.neonCyan),
                      const Divider(color: GameTheme.gridBorder, height: 12),
                      _buildStatLine(AppStrings.maxCombo, 'x$comboStreak', GameTheme.fireOrange),
                      const Divider(color: GameTheme.gridBorder, height: 12),
                      _buildStatLine('🪙 ${AppStrings.shardsEarnedStat}', '+$shards', GameTheme.lightningYellow),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Copy & Share Button
                ElevatedButton.icon(
                  onPressed: () {
                    ProceduralAudio.instance.playRewardClaim();
                    AppHaptics.medium();

                    final shareText = AppStrings.shareScoreText(score, rankTitle);

                    Clipboard.setData(ClipboardData(text: shareText));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: rankColor,
                        content: Text(
                          AppStrings.copiedToClipboard,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 18, color: Colors.black),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppStrings.copyShareScore,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rankColor,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                  ),
                ).animate().shimmer(duration: 1500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatLine(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        Text(
          value,
          style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
