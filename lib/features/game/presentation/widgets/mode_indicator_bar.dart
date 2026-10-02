import 'package:flutter/material.dart';
import '../../models/game_mode.dart';

/// Mode-specific status bar shown at the top of the board.
/// Renders cleanly for Classic and Adventure modes.
class ModeIndicatorBar extends StatelessWidget {
  final GameMode gameMode;
  final int blitzSecondsLeft;

  const ModeIndicatorBar({
    super.key,
    required this.gameMode,
    this.blitzSecondsLeft = 0,
  });

  @override
  Widget build(BuildContext context) {
    switch (gameMode) {
      case GameMode.classic:
      case GameMode.adventure:
        return const SizedBox.shrink();
    }
  }
}
