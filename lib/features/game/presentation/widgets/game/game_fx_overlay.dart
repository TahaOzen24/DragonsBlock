import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../stinger_overlay.dart';

/// Stinger banner + confetti celebration (game_screen Stack üstü).
class GameFxOverlay extends StatelessWidget {
  final String? stingerText;
  final Color stingerColor;
  final double stingerTop;
  final ConfettiController confettiController;

  const GameFxOverlay({
    super.key,
    required this.stingerText,
    required this.stingerColor,
    required this.stingerTop,
    required this.confettiController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (stingerText != null)
          Positioned(
            top: stingerTop,
            child: StingerOverlay(text: stingerText!, color: stingerColor),
          ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.pink,
              Colors.cyan,
            ],
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.1,
            blastDirection: -pi / 2,
          ),
        ),
      ],
    );
  }
}
