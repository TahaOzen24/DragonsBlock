import 'package:flutter/material.dart';
import '../../../../../core/audio/procedural_audio.dart';
import '../../../../../core/localization/app_strings.dart';
import '../../../../rewards/presentation/victory_chest_dialog.dart';
import '../game_over_dialog.dart';
import '../pause_menu_dialog.dart';
import '../revive_countdown_dialog.dart';
import '../share_score_dialog.dart';

class GameDialogHelper {
  GameDialogHelper._();

  static void showPauseMenu({
    required BuildContext context,
    required VoidCallback onRestart,
    required VoidCallback onQuit,
  }) {
    ProceduralAudio.instance.playDialogPop();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PauseMenuDialog(
        onRestart: onRestart,
        onQuit: onQuit,
      ),
    );
  }

  static void showShareScoreDialog({
    required BuildContext context,
    required int score,
    required int highScore,
    required int linesCleared,
    required int comboStreak,
    required int shards,
  }) {
    showDialog(
      context: context,
      builder: (_) => ShareScoreDialog(
        score: score,
        highScore: highScore,
        linesCleared: linesCleared,
        comboStreak: comboStreak,
        shards: shards,
      ),
    );
  }

  static Future<void> showVictoryChestDialog({
    required BuildContext context,
    String? title,
    String? subtitle,
    int baseReward = 750,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => VictoryChestDialog(
        title: title ?? AppStrings.newRecordVictory,
        subtitle: subtitle ?? AppStrings.newRecordSubtitle,
        baseReward: baseReward,
      ),
    );
  }

  static void showReviveDialog({
    required BuildContext context,
    required int currentScore,
    required int comboStreak,
    required int totalSeconds,
    required VoidCallback onWatchAd,
    required VoidCallback onPayGold,
    required VoidCallback onTimeoutOrSkip,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ReviveCountdownDialog(
        totalSeconds: totalSeconds,
        currentScore: currentScore,
        comboStreak: comboStreak,
        onWatchAd: onWatchAd,
        onPayGold: onPayGold,
        onTimeoutOrSkip: onTimeoutOrSkip,
      ),
    );
  }

  static void showGameOverDialog({
    required BuildContext context,
    required int finalScore,
    required int highScore,
    required int linesCleared,
    required int shardsEarned,
    required bool isNewHighScore,
    required VoidCallback onShareScore,
    required VoidCallback onDoubleShards,
    required VoidCallback onRestart,
    required VoidCallback onMainMenu,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        finalScore: finalScore,
        highScore: highScore,
        linesCleared: linesCleared,
        shardsEarned: shardsEarned,
        isNewHighScore: isNewHighScore,
        canRevive: false,
        onShareScore: onShareScore,
        onRevive: () {},
        onDoubleShards: onDoubleShards,
        onRestart: onRestart,
        onMainMenu: onMainMenu,
      ),
    );
  }
}
