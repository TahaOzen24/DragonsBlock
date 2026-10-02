import 'package:flutter/material.dart';

/// Tahta baskın rengine göre dinamik arka plan gradyanı.
class GameDynamicBackground {
  GameDynamicBackground._();

  static LinearGradient gradient({
    required Color dominantColor,
    required bool isHyperdriveActive,
  }) {
    if (isHyperdriveActive) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF5B21B6),
          Color(0xFF3B0764),
          Color(0xFF1E0B36),
        ],
      );
    }

    final hsv = HSVColor.fromColor(dominantColor);

    final topColor = HSVColor.fromAHSV(
      1.0,
      hsv.hue,
      (hsv.saturation * 0.68).clamp(0.40, 0.62),
      0.68,
    ).toColor();

    final midColor = HSVColor.fromAHSV(
      1.0,
      hsv.hue,
      (hsv.saturation * 0.74).clamp(0.46, 0.66),
      0.60,
    ).toColor();

    final bottomColor = HSVColor.fromAHSV(
      1.0,
      hsv.hue,
      (hsv.saturation * 0.78).clamp(0.50, 0.70),
      0.54,
    ).toColor();

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [topColor, midColor, bottomColor],
      stops: const [0.0, 0.50, 1.0],
    );
  }
}
